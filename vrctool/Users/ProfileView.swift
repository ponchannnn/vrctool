import Foundation
import SwiftUI

// 自分の詳細情報用モデル
struct CurrentUser: Codable, Identifiable {
    let id: String
    let username: String
    let displayName: String
    let userIcon: String
    let bio: String
    let bioLinks: [String]
    let profilePicOverride: String
    let currentAvatarImageUrl: String
    let currentAvatarThumbnailImageUrl: String
    let presence: Presence
    
    let status: String // active, join me, busy... (ソーシャルステータス)
    let state: String  // offline, active, online (接続状態)
    let statusDescription: String
    let statusHistory: [String]
    
    let emailVerified: Bool
    let obfuscatedEmail: String
    let twoFactorAuthEnabled: Bool
    let allowAvatarCopying: Bool
    let date_joined: String
    let last_login: String
    let last_platform: String
    let developerType: String
    
    let tags: [String]
    let badges: [Badge]
    let onlineFriends: [String]
    let activeFriends: [String]
    let offlineFriends: [String]
    let friends: [String]
    let friendGroupNames: [String]
    
    // --- 履歴・連携 ---
    let pastDisplayNames: [PastDisplayName]
    let steamId: String
    let discordId: String
    
    // ネストされた構造体
    struct PastDisplayName: Codable {
        let displayName: String
        let updated_at: String
    }
    
    // --- 表示用ヘルパー ---
    var mainImageUrl: String {
        return !profilePicOverride.isEmpty ? profilePicOverride : currentAvatarImageUrl
    }
    
    var currentAvatarThumbnail: String {
        return currentAvatarThumbnailImageUrl
    }
    
    var currentInstanceLocation: String? {
        if presence.world == "offline" || presence.instance == "offline" {
            return nil
        }
        return "\(presence.world):\(presence.instance)"
    }
    
    var trustRank: (String, Color) {
            if tags.contains("system_trust_legend") { return ("Legendary", Color(red: 1.0, green: 0.8, blue: 0.0)) }
            if tags.contains("system_trust_veteran") { return ("Veteran", Color(red: 0.6, green: 0.0, blue: 0.8)) }
            if tags.contains("system_trust_trusted") { return ("Trusted", Color(red: 1.0, green: 0.45, blue: 0.0)) }
            if tags.contains("system_trust_known") { return ("Known", Color(red: 0.0, green: 0.8, blue: 0.2)) }
            if tags.contains("system_trust_basic") { return ("User", Color(red: 0.2, green: 0.5, blue: 1.0)) }
            return ("Visitor", Color.gray)
        }

    var computedStatusColor: Color {
            switch status {
            case "join me": return .blue
            case "active": return .green
            case "busy": return .red
            default: return .green
            }
        }
}

struct Presence: Codable {
    let id: String
    let world: String
    let instance: String
    let status: String
    let platform: String
    let groups: [String]
}

struct ProfileView: View {
    @State private var currentUser: CurrentUser?
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    // 画像保存用
    @State private var showSaveAlert = false
    @State private var saveMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                if let user = currentUser {
                    VStack(spacing: 0) {
                        // ヘッダー画像
                        headerImageSection(user: user)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // 1. 基本情報 (名前・ランク・ステータス)
                            basicInfoSection(user: user)
                            
                            Divider()
                            
                            // 2. 状態・ステータス詳細 (State & Status)
                            statusDetailSection(user: user)
                            
                            Divider()
                            
                            // 3. アカウント情報 (メール・2FA)
                            accountInfoSection(user: user)
                            
                            // 4. フレンド数
                            friendsCountSection(user: user)
                            
                            // 5. Bio
                            bioSection(user: user)
                            
                            // 6. 履歴・詳細
                            if !user.statusHistory.isEmpty {
                                Divider()
                                statusHistorySection(user: user)
                            }
                            
                            if !user.pastDisplayNames.isEmpty {
                                Divider()
                                pastNamesSection(user: user)
                            }
                            
                            Divider()
                            detailsSection(user: user)
                        }
                        .padding()
                    }
                } else if isLoading {
                    ProgressView("Loading Profile...")
                        .padding(.top, 50)
                } else {
                    Text(errorMessage.isEmpty ? "Failed to load profile" : errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 50)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadMyProfile()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let user = currentUser {
                        Menu {
                            Section {
                                NavigationLink(destination: SimpleWorldListContainer(source: .user(userId: user.id, userName: "My"))) {
                                    Label("マイワールド", systemImage: "globe")
                                }
                                
                                NavigationLink(destination: SimpleWorldListContainer(source: .category(.favorites))) {
                                    Label("お気に入りワールド", systemImage: "star")
                                }
                                
                                NavigationLink(destination: SimpleWorldListContainer(source: .category(.recent))) {
                                    Label("履歴", systemImage: "clock")
                                }
                                
                                Button(action: { print("Open Avatars") }) {
                                    Label("マイアバター", systemImage: "person.fill.viewfinder")
                                }
                            }
                            
                            Section {
                                NavigationLink(destination: GroupListView(userId: user.id)) {
                                    Label("グループ一覧", systemImage: "person.3")
                                }
                                
                                NavigationLink(destination: NotificationListView()) {
                                    Label("通知", systemImage: "bell")
                                }
                            }
                            
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 18))
                        }
                    }
                }
            }
            .alert("画像保存", isPresented: $showSaveAlert) {
                 Button("OK", role: .cancel) {}
            } message: {
                 Text(saveMessage)
            }
        }
    }

    // MARK: - Logic & Components
    
    func loadMyProfile() {
        NetworkManager.fetchMe { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let me):
                    self.currentUser = me
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func headerImageSection(user: CurrentUser) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if let url = URL(string: user.mainImageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                            .contextMenu {
                                Button { downloadAndSaveImage(url: user.mainImageUrl) } label: {
                                    Label("画像を保存", systemImage: "square.and.arrow.down")
                                }
                            }
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.3)).overlay(ProgressView())
                    }
                }
                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
            }
        }
        .frame(height: 300)
    }
    
    func basicInfoSection(user: CurrentUser) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // アイコン
            if !user.userIcon.isEmpty, let iconUrl = URL(string: user.userIcon) {
                AsyncImage(url: iconUrl) { img in img.resizable() } placeholder: { Color.gray }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(user.trustRank.0)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(user.trustRank.1.opacity(0.15))
                        .foregroundColor(user.trustRank.1)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    func statusDetailSection(user: CurrentUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Current State", systemImage: "antenna.radiowaves.left.and.right").font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Connection")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Circle()
                            .fill(user.state == "offline" ? Color.gray : Color.green)
                            .frame(width: 8, height: 8)
                        Text(user.state.capitalized)
                            .fontWeight(.bold)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Social Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Circle()
                            .fill(user.computedStatusColor)
                            .frame(width: 8, height: 8)
                        Text(user.status.capitalized)
                            .fontWeight(.bold)
                    }
                }
            }
            
            if !user.statusDescription.isEmpty {
                Text(user.statusDescription)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
            }
        }
    }
    
    func accountInfoSection(user: CurrentUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Account", systemImage: "lock.shield").font(.headline)
            VStack(spacing: 0) {
                DetailRow(key: "Email", value: user.obfuscatedEmail)
                Divider()
                DetailRow(key: "Email Verified", value: user.emailVerified ? "Yes" : "No")
                Divider()
                DetailRow(key: "2FA Enabled", value: user.twoFactorAuthEnabled ? "Yes" : "No")
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    func friendsCountSection(user: CurrentUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Friends (\(user.friends.count))", systemImage: "person.2").font(.headline)
            HStack(spacing: 10) {
                FriendCountCard(title: "Online", count: user.onlineFriends.count, color: .green)
                FriendCountCard(title: "Active", count: user.activeFriends.count, color: .orange)
                FriendCountCard(title: "Offline", count: user.offlineFriends.count, color: .gray)
            }
        }
    }
    
    func bioSection(user: CurrentUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Bio", systemImage: "text.alignleft").font(.headline)
            VStack(alignment: .leading, spacing: 12) {
                if user.bio.isEmpty {
                    Text("No biography.").foregroundColor(.secondary)
                } else {
                    Text(user.bio).font(.body)
                }
                
                if !user.bioLinks.isEmpty {
                    Divider()
                    ForEach(user.bioLinks, id: \.self) { link in
                        if let url = URL(string: link) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "link")
                                    Text(link).lineLimit(1)
                                }.font(.caption)
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    func statusHistorySection(user: CurrentUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Recent Statuses", systemImage: "clock").font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(user.statusHistory, id: \.self) { status in
                        Text(status)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(15)
                    }
                }
            }
        }
    }
    
    func pastNamesSection(user: CurrentUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Past Names", systemImage: "tag").font(.headline)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(user.pastDisplayNames, id: \.updated_at) { history in
                    HStack {
                        Text(history.displayName)
                        Spacer()
                        Text(history.updated_at.prefix(10)).font(.caption).foregroundColor(.secondary)
                    }
                    .padding()
                    Divider()
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    func detailsSection(user: CurrentUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Details", systemImage: "doc.text").font(.headline)
            VStack(spacing: 0) {
                DetailRow(key: "ID", value: user.id)
                Divider()
                DetailRow(key: "Date Joined", value: String(user.date_joined.prefix(10)))
                Divider()
                DetailRow(key: "Last Login", value: user.last_login) // 修正: String(prefix)等を適宜入れてもOK
                Divider()
                DetailRow(key: "Platform", value: user.last_platform.capitalized)
                Divider()
                DetailRow(key: "Dev Type", value: user.developerType)
                if !user.steamId.isEmpty {
                    Divider()
                    DetailRow(key: "Steam ID", value: user.steamId)
                }
                if !user.discordId.isEmpty {
                    Divider()
                    DetailRow(key: "Discord ID", value: user.discordId)
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    private func downloadAndSaveImage(url: String) {
        guard let imageURL = URL(string: url) else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: imageURL)
                if let image = UIImage(data: data) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    DispatchQueue.main.async {
                        self.saveMessage = "画像を保存しました"
                        self.showSaveAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.saveMessage = "保存失敗"
                    self.showSaveAlert = true
                }
            }
        }
    }
}

// サブビュー: フレンド数カード
struct FriendCountCard: View {
    let title: String
    let count: Int
    let color: Color
    var body: some View {
        VStack {
            Text("\(count)").font(.title2).fontWeight(.bold).foregroundColor(color)
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView()
}
