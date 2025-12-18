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
    let presence: Presence?
    
    let status: String // active, join me, busy... (ソーシャルステータス)
    let state: String  // offline, active, online (接続状態)
    let statusDescription: String
    let statusHistory: [String]
    let pronouns: String?
    let pronounsHistory: [String]?
    let userLanguage: String?
    let userLanguageCode: String?
    
    let emailVerified: Bool
    let obfuscatedEmail: String
    let twoFactorAuthEnabled: Bool
    let allowAvatarCopying: Bool
    let date_joined: String
    let last_login: String
    let last_platform: String
    let developerType: String
    
    let tags: [String]
    let badges: [Badge]?
    let onlineFriends: [String]?
    let activeFriends: [String]?
    let offlineFriends: [String]?
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
        guard let p = presence else { return nil }
        if p.world == "offline" || p.instance == "offline" {
            return nil
        }
        return "\(p.world):\(p.instance)"
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
    @State private var activeSheet: ProfileEditTarget? = nil
    
    @State private var prefilledText: String? = nil
    
    // 画像保存用
    @State private var showSaveAlert = false
    @State private var saveMessage = ""

    var body: some View {
        NavigationStack {
            Group {
                if let user = currentUser {
                    ScrollView {
                    VStack(spacing: 0) {
                        // ヘッダー画像
                        headerImageSection(user: user)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // 1. 基本情報 (名前・ランク・ステータス)
                            basicInfoSection(user: user)
                            
                            Divider()
                            
                            // 2. 状態・ステータス詳細 (State & Status)
                            Button {
                                self.prefilledText = nil
                                activeSheet = .status
                            } label: {
                                statusDetailSection(user: user)
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundStyle(.white, .blue)
                                            .font(.title2)
                                            .offset(x: 10, y: -10)
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                            
                            // 3. アカウント情報 (メール・2FA)
                            accountInfoSection(user: user)
                            
                            // 4. フレンド数
                            friendsCountSection(user: user)
                            
                            // 5. Bio
                            Button {
                                activeSheet = .bio
                            } label: {
                                bioSection(user: user)
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundStyle(.white, .blue)
                                            .font(.title2)
                                            .offset(x: 10, y: -10)
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // 6. 履歴・詳細
                            if !user.statusHistory.isEmpty {
                                Divider()
                                statusHistorySection(user: user)
                            }
                            
                            if let proHistory = user.pronounsHistory, !proHistory.isEmpty {
                                Divider()
                                pronounsHistorySection(history: proHistory)
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
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                } else if isLoading {
                    ProgressView("Loading Profile...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(uiColor: .systemBackground))
                } else {
                    Text(errorMessage.isEmpty ? "Failed to load profile" : errorMessage)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(uiColor: .systemBackground))
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadMyProfile()
            }
            .refreshable {
                loadMyProfile()
            }
            .sheet(item: $activeSheet) { target in
                if let user = currentUser {
                    GenericProfileEditor(target: target, user: user, initialText: prefilledText) { _ in
                        self.loadMyProfile(isSilent: true)
                        self.prefilledText = nil
                    }
                }
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
    
    func loadMyProfile(isSilent: Bool = false) {
        if !isSilent {
            self.isLoading = true
        }
        
        NetworkManager.request(endpoint: "auth/user") { (result: Result<CurrentUser, Error>) in
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
                
                Button {
                    self.prefilledText = nil
                    self.activeSheet = .pronouns
                } label: {
                    if let pronouns = user.pronouns, !pronouns.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "quote.bubble.fill")
                                .font(.caption2)
                                .foregroundColor(.secondary.opacity(0.8))
                            Text(pronouns)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 2)
                    } else {
                        Text("Add Pronouns")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.vertical, 2)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
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
                NavigationLink(destination: FriendCategoryLoader(
                    title: "Online",
                    targetIds: user.onlineFriends ?? [],
                    includeOffline: false
                )) {
                    FriendCountCard(
                        title: "Online",
                        count: user.onlineFriends?.count ?? 0,
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink(destination: FriendCategoryLoader(
                    title: "Active",
                    targetIds: user.activeFriends ?? [],
                    includeOffline: false
                )) {
                    FriendCountCard(
                        title: "Active",
                        count: user.activeFriends?.count ?? 0,
                        color: .orange
                    )
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink(destination: FriendCategoryLoader(
                    title: "Offline",
                    targetIds: user.offlineFriends ?? [],
                    includeOffline: true
                )) {
                    FriendCountCard(
                        title: "Offline",
                        count: user.offlineFriends?.count ?? 0,
                        color: .gray
                    )
                }
                .buttonStyle(PlainButtonStyle())
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
                        Button {
                            self.prefilledText = status
                            self.activeSheet = .status
                        } label: {
                            Text(status)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    func pronounsHistorySection(history: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Recent Pronouns", systemImage: "quote.bubble").font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(history, id: \.self) { pronoun in
                        Button {
                            self.prefilledText = pronoun
                            self.activeSheet = .pronouns
                        } label: {
                            Text(pronoun)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
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

enum ProfileEditTarget: Identifiable {
    case status       // ステータス & メッセージ
    case bio          // 自己紹介
    case bioLinks     // リンク
    case pronouns     // 代名詞 (he/him 等)
//    case userIcon  // VRC+限定
    
    var id: Int { hashValue }
    
    var title: String {
        switch self {
        case .status: return "Edit Status"
        case .bio: return "Edit Biography"
        case .bioLinks: return "Edit Links"
        case .pronouns: return "Edit Pronouns"
//        case .userIcon: return "Edit User Icon"
        }
    }
}

struct GenericProfileEditor: View {
    let target: ProfileEditTarget
    let user: CurrentUser
    
    let initialText: String?
    
    let onUpdate: (CurrentUser) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var status: String = ""
    @State private var statusDescription: String = ""
    @State private var bio: String = ""
    @State private var pronouns: String = ""
    @State private var bioLinks: [String] = []
    
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    // ステータスの選択肢
    let statusOptions = ["active", "join me", "ask me", "busy", "offline"]
    
    init(target: ProfileEditTarget, user: CurrentUser, initialText: String? = nil, onUpdate: @escaping (CurrentUser) -> Void) {
        self.target = target
        self.user = user
        self.initialText = initialText
        self.onUpdate = onUpdate
        
        // Stateの初期
        _status = State(initialValue: user.status)

        let statusDescValue = (target == .status && initialText != nil) ? initialText! : user.statusDescription
        _statusDescription = State(initialValue: statusDescValue)
        
        _bio = State(initialValue: user.bio)
        
        let pronounsValue = (target == .pronouns && initialText != nil) ? initialText! : (user.pronouns ?? "")
        _pronouns = State(initialValue: pronounsValue)
        _bioLinks = State(initialValue: user.bioLinks)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                contentForTarget
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(target.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Save") {
                            handleSave()
                        }
                        .fontWeight(.bold)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    @ViewBuilder
    var contentForTarget: some View {
        switch target {
        case .status:
            Section("Status Indicator") {
                Picker("Status", selection: $status) {
                    ForEach(statusOptions, id: \.self) { option in
                        HStack {
                            Circle().fill(statusColor(option)).frame(width: 8, height: 8)
                            Text(option.capitalized)
                        }
                        .tag(option)
                    }
                }
                .pickerStyle(.menu)
            }
            Section("Status Message") {
                HStack {
                    TextField("What are you doing?", text: $statusDescription)

                    // クリアボタン (入力がある時だけ表示)
                    if !statusDescription.isEmpty {
                        Button {
                            statusDescription = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            if !user.statusHistory.isEmpty {
                historySection(items: user.statusHistory, currentText: statusDescription) { selected in
                    self.statusDescription = selected
                }
            }
            
        case .bio:
            Section {
                TextEditor(text: $bio)
                    .frame(minHeight: 200)
            } footer: {
                Text("Markdown is partially supported.")
            }
            
        case .pronouns:
            Section {
                HStack {
                    TextField("e.g. they/them", text: $pronouns)
                    if !pronouns.isEmpty {
                        Button { pronouns = "" } label: { Image(systemName: "xmark.circle.fill").foregroundColor(.gray) }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
            if let history = user.pronounsHistory, !history.isEmpty {
                historySection(items: history, currentText: pronouns) { selected in
                    self.pronouns = selected
                }
            }
            
        case .bioLinks:
            Section("Links") {
                ForEach($bioLinks.indices, id: \.self) { index in
                    TextField("https://...", text: $bioLinks[index])
                }
                // ※追加・削除ロジックは長くなるので省略、必要なら追加します
            }
        }
    }
    
    func historySection(items: [String], currentText: String, onSelect: @escaping (String) -> Void) -> some View {
        Section("History") {
            ForEach(items, id: \.self) { item in
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    onSelect(item)
                } label: {
                    HStack {
                        Text(item).foregroundColor(.primary)
                        Spacer()
                        if currentText == item {
                            Image(systemName: "checkmark").foregroundColor(.blue).fontWeight(.bold)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - API Logic
    
    func handleSave() {
        if !hasChanges() {
            dismiss()
            return
        }
        saveChanges()
    }
    
    func hasChanges() -> Bool {
        switch target {
        case .status:
            return status != user.status || statusDescription != user.statusDescription
        case .bio:
            return bio != user.bio
        case .pronouns:
            return pronouns != (user.pronouns ?? "")
        case .bioLinks:
            return bioLinks != user.bioLinks
        }
    }
    
    func saveChanges() {
        isLoading = true
        errorMessage = ""
        
        // 変更するパラメータだけを作成
        var body: [String: Any] = [:]
        
        switch target {
        case .status:
            body["status"] = status
            body["statusDescription"] = statusDescription
        case .bio:
            body["bio"] = bio
        case .pronouns:
            body["pronouns"] = pronouns
        case .bioLinks:
            body["bioLinks"] = bioLinks
        }
        
        NetworkManager.action(
            endpoint: "users/\(user.id)",
            method: "PUT",
            body: body
        ) { (result: Result<CurrentUser, Error>) in
            
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let updatedUser):
                    // 成功したら親Viewへ通知して閉じる
                    self.onUpdate(updatedUser)
                    dismiss()
                    
                case .failure(let error):
                    self.errorMessage = "Update failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func statusColor(_ status: String) -> Color {
        switch status {
        case "join me": return .blue
        case "active": return .green
        case "ask me": return .orange
        case "busy": return .red
        default: return .gray
        }
    }
}

struct FriendCategoryLoader: View {
    let title: String
    let targetIds: [String] // Profileから渡された「オンラインの人のIDリスト」など
    let includeOffline: Bool
    
    @State private var filteredUsers: [User]? = nil // nilならロード中
    
    var body: some View {
        ZStack {
            if let users = filteredUsers {
                if users.isEmpty {
                    emptyStateView
                } else {
                    UserListView(
                        users: users,
                        isLoading: false,
                        mode: .local,
                        onLoadMore: {},
                        hasMoreData: false,
                        onRefresh: {
                            await fetchAndFilterFriends()
                        }
                    )
                }
            } else {
                ProgressView("Loading friends...")
            }
        }
        .navigationTitle("\(title) (\(targetIds.count))")
        .task {
            await fetchAndFilterFriends()
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No Friends Found")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    func fetchAndFilterFriends() async {
        // APIからフレンド一覧を取得 (オフラインが必要かどうかでクエリを変える)
        let query = [
            URLQueryItem(name: "offline", value: includeOffline ? "true" : "false")
        ]
        
        await withCheckedContinuation { continuation in
            NetworkManager.fetchAll(endpoint: "auth/user/friends", baseQueryItems: query) { (result: Result<[User], Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let allFriends):
                        // 取得した全フレンドの中から、targetIds に含まれる人だけを抽出
                        let filtered = allFriends.filter { user in
                            self.targetIds.contains(user.id)
                        }
                        
                        self.filteredUsers = filtered.sorted { $0.safeDisplayName < $1.safeDisplayName }
                        
                    case .failure(let error):
                        print("Error fetching friends: \(error)")
                        self.filteredUsers = [] // エラー時は空表示
                    }
                    continuation.resume()
                }
            }
        }
    }
}

//#Preview {
//    ProfileView()
//}
