import SwiftUI

struct Badge: Codable, Identifiable {
    let badgeId: String
    let badgeName: String?
    let badgeDescription: String?
    let badgeImageUrl: String?
    let showcased: Bool?
    
    var id: String { badgeId }
}

struct User: Codable, Identifiable {
    let id: String
    let displayName: String?
    let username: String?
    let userIcon: String?
    let bio: String?
    let bioLinks: [String]?
    let tags: [String]?
    let currentAvatarImageUrl: String?
    let currentAvatarThumbnailImageUrl: String?
    let currentAvatarTags: [String]?
    let profilePicOverride: String?
    let profilePicOverrideThumbnail: String?
    let status: String?
    let statusDescription: String?
    let location: String?
    let developerType: String?
    let last_login: String?
    let last_platform: String?
    let last_activity: String?
    let last_mobile: String?
    let isFriend: Bool?
    
    // userにだけ
    let badges: [Badge]?
    let pronouns: String?
    let note: String?
    let ageVerificationStatus: String?
    let ageVerified: Bool?
    let allowAvatarCopying: Bool?
    let date_joined: String?
    let friendKey: String?
    let friendRequestStatus: String? // "incoming", "outgoing", etc.
    let platform: String?
    let state: String? // "offline", "active", "online"
    let travelingToInstance: String?
    let travelingToLocation: String?
    let travelingToWorld: String?
    
    // friendにだけ
    let imageUrl: String?
    
    
    var safeDisplayName: String { displayName ?? username ?? "Unknown" }
    
    var safeStatus: String {
        return status ?? "offline"
    }
    
    var safeStatusDescription: String {
        return statusDescription ?? ""
    }
    
    var safeThumbnailUrl: String {
        return currentAvatarThumbnailImageUrl ?? userIcon ?? ""
    }
    
    var safeLocation: String {
        return location ?? "offline"
    }
    
    var worldId: String? {
        guard let loc = location, !loc.isEmpty else { return nil }
        if loc == "private" || loc == "offline" { return nil }
        return loc.components(separatedBy: ":").first
    }
    
    var instanceId: String? {
        guard let loc = location, !loc.isEmpty else { return nil }
        if loc == "private" || loc == "offline" { return nil }
        return loc
    }
    
    var statusColor: Color {
        if safeLocation == "offline" { return .gray }
        
        switch safeStatus {
        case "join me": return .blue
        case "active": return .green
        case "busy": return .red
        default: return .green
        }
    }
    
    var mainImageUrl: String {
        if let pic = profilePicOverride, !pic.isEmpty { return pic }
        return currentAvatarImageUrl ?? ""
    }
    
    var trustRank: (String, Color) {
        let t = tags ?? []
        if t.contains("system_trust_legend") { return ("Legendary", Color(red: 1.0, green: 0.8, blue: 0.0)) }
        if t.contains("system_trust_veteran") { return ("Veteran", Color(red: 0.6, green: 0.0, blue: 0.8)) }
        if t.contains("system_trust_trusted") { return ("Trusted", Color(red: 1.0, green: 0.45, blue: 0.0)) }
        if t.contains("system_trust_known") { return ("Known", Color(red: 0.0, green: 0.8, blue: 0.2)) }
        if t.contains("system_trust_basic") { return ("User", Color(red: 0.2, green: 0.5, blue: 1.0)) }
        return ("Visitor", Color.gray)
    }
    
    var isInInstance: Bool {
        guard let loc = location else { return false }
        return loc != "offline" && loc != "private" && !loc.isEmpty
    }
}

struct UserView: View {
    var userId: String
    @State private var user: User?
    @State private var isLoading = true
    @State private var scale: CGFloat = 1.0
    
    // バッジ詳細表示用
    @State private var selectedBadge: Badge?
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showSaveAlert = false
    @State private var saveMessage = ""
    
    @State private var showActionSheet = false
    
    var body: some View {
        ScrollView {
            if let user = user {
                VStack(spacing: 0) {
                    // ヘッダー画像 (Profile Pic Override 優先)
                    headerImageSection(user: user)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // ユーザー基本情報 (名前・アイコン・ランク)
                        userInfoHeader(user: user)
                        
                        Divider()
                        
                        // バッジ一覧 (存在する場合のみ)
                        if let note = user.note, !note.isEmpty {
                            noteSection(note: note)
                            Divider()
                        }
                        
                        // バッジ
                        if let badges = user.badges, !badges.isEmpty {
                            badgesSection(user: user)
                            Divider()
                        }
                        
                        // Bio (自己紹介)
                        bioSection(user: user)
                        
                        // 詳細情報 (入会日など)
                        detailsSection(user: user)
                        
                        // 現在のアバター (ProfilePicとは別の場合に表示)
                        if let thumb = user.currentAvatarThumbnailImageUrl , !thumb.isEmpty && user.currentAvatarImageUrl != user.profilePicOverride {
                            currentAvatarSection(user: user)
                        }
                        
                        // タグ
                        if let tags = user.tags, !tags.isEmpty {
                            tagsSection(user: user)
                        }
                    }
                    .padding()
                }
            } else if isLoading {
                ProgressView("Loading...")
                    .padding(.top, 50)
            } else {
                Text("Failed to load user.")
                    .padding(.top, 50)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(user?.displayName ?? "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let user = user {
                    userActionMenu(user: user)
                }
            }
        }
        .onAppear {
            fetchUser(userId:self.userId)
        }
        // バッジタップ時のアラート
        .alert(item: $selectedBadge) { badge in
            Alert(
                title: Text(badge.badgeName ?? "Badge"),
                message: Text(badge.badgeDescription ?? "No description"),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("画像保存", isPresented: $showSaveAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(saveMessage)
                }
    }
    
    // MARK: - Components
    
    func contextMenuImage(url: String, height: CGFloat? = nil, width: CGFloat? = nil, contentMode: ContentMode = .fill) -> some View {
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: width, height: height)
                    .clipped()
                    .contextMenu {
                        Button {
                            downloadAndSaveImage(url: url)
                        } label: {
                            Label("画像を保存", systemImage: "square.and.arrow.down")
                        }
                    }
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: width, height: height)
                    .overlay(ProgressView())
            }
        }
    
    func userActionMenu(user: User) -> some View {
        Menu {
            Section {
                NavigationLink(destination: UserWorldListContainer(
                    userId: user.id,
                    userName: user.safeDisplayName,
                    isFriend: user.isFriend ?? false
                )) {
                    Label("ワールド一覧", systemImage: "globe")
                }
                NavigationLink(destination: GroupListView(userId: user.id)) {
                    Label("グループ一覧", systemImage: "person.3.fill")
                }
            }
            
            // インスタンス操作 (相手がどこかにいる場合のみ)
            if let location = user.location, user.isFriend == true && !location.isEmpty, location != "offline"{
                Section {
                    if location != "private" {
                        Button(action: { inviteMyself(location: location) }) {
                            Label("自分を招待 (Invite Myself)", systemImage: "arrow.uturn.left")
                        }
                    }
                    Button(action: { requestInvite(userId: user.id) }) {
                        Label("招待をリクエスト (Req Invite)", systemImage: "envelope.fill")
                    }
                    Button(action: { sendInvite(userId: user.id) }) {
                        Label("相手を招待 (Invite)", systemImage: "paperplane.fill")
                    }
                }
            }
            
            // フレンド操作
            Section {
                if user.isFriend == true {
                    Button(role: .destructive, action: { unfriend(userId: user.id) }) {
                        Label("フレンド解除", systemImage: "person.fill.xmark")
                    }
                } else {
                    if user.friendRequestStatus == "outgoing" {
                        Button(action: { cancelFriendRequest(userId: user.id) }) {
                            Label("申請キャンセル", systemImage: "xmark")
                        }
                    } else if user.friendRequestStatus == "incoming" {
                        Button(action: { acceptFriendRequest(userId: user.id) }) {
                            Label("申請を承認", systemImage: "checkmark")
                        }
                    } else {
                        Button(action: { sendFriendRequest(userId: user.id) }) {
                            Label("フレンド申請", systemImage: "person.badge.plus")
                        }
                    }
                }
            }
            
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 18))
        }
    }
    
    
    func performAction(_ label: String, action: @escaping (@escaping (Result<String, Error>) -> Void) -> Void) {
        action { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.saveMessage = "\(label): 成功しました"
                    self.showSaveAlert = true
                    fetchUser(userId: userId)
                case .failure(let error):
                    self.saveMessage = "\(label): 失敗しました\n\(error.localizedDescription)"
                    self.showSaveAlert = true
                }
            }
        }
    }
    
    // --- インスタンス・招待系 ---
    
    // 自分を相手のいる場所に招待 (Invite Myself)
    func inviteMyself(location: String) {
        performAction("自分を招待") { completion in
            NetworkManager.action(endpoint: "instances/\(location)/invite", method: "POST", completion: completion)
        }
    }
    
    // 招待リクエストを送る (Request Invite)
    func requestInvite(userId: String) {
        performAction("招待リクエスト") { completion in
            NetworkManager.action(endpoint: "requestInvite/\(userId)", method: "POST", completion: completion)
        }
    }
    
    // 相手を自分の場所に招待する (Invite)
    func sendInvite(userId: String) {
        NetworkManager.request(endpoint: "auth/user") { (result: Result<CurrentUser, Error>) in
            switch result {
            case .success(let me):
                if let location = me.currentInstanceLocation {
                    let body: [String: Any] = [
                        "details": ["instanceId": location]
                    ]
                    
                    NetworkManager.action(endpoint: "invite/\(userId)", method: "POST", body: body) { (result: Result<CurrentUser, Error>) in
                        DispatchQueue.main.async {
                            if case .failure(let error) = result {
                                self.saveMessage = "招待送信失敗: \(error.localizedDescription)"
                                self.showSaveAlert = true
                            } else {
                                self.saveMessage = "招待を送りました"
                                self.showSaveAlert = true
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.saveMessage = "招待失敗: あなたは現在オフラインか、招待可能なワールドにいません。"
                        self.showSaveAlert = true
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.saveMessage = "自分の情報の取得に失敗: \(error.localizedDescription)"
                    self.showSaveAlert = true
                }
            }
        }
    }
    
    // --- フレンド操作系 ---
    
    // フレンド申請を送る
    func sendFriendRequest(userId: String) {
        performAction("フレンド申請") { completion in
            NetworkManager.action(endpoint: "user/\(userId)/friendRequest", method: "POST", completion: completion)
        }
    }
    
    // フレンド解除 (Unfriend)
    func unfriend(userId: String) {
        performAction("フレンド解除") { completion in
            NetworkManager.action(endpoint: "auth/user/friends/\(userId)", method: "DELETE", completion: completion)
        }
    }
    
    // 申請キャンセル (Cancel Outgoing Request)
    func cancelFriendRequest(userId: String) {
        performAction("申請キャンセル") { completion in
            NetworkManager.action(endpoint: "user/\(userId)/friendRequest", method: "DELETE", completion: completion)
        }
    }
    
    // 申請を承認 (Accept Incoming Request)
    func acceptFriendRequest(userId: String) {
        NetworkManager.request(endpoint: "auth/user/notifications", queryItems: [URLQueryItem(name: "type", value: "friendRequest")]) { (result: Result<[NotificationSimple], Error>) in
            switch result {
            case .success(let notifs):
                // 送信者が一致する通知を探す
                if let target = notifs.first(where: { $0.senderUserId == userId }) {
                    // 通知IDを使って承認
                    performAction("フレンド承認") { completion in
                        NetworkManager.action(endpoint: "auth/user/notifications/\(target.id)/accept", method: "PUT", completion: completion)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.saveMessage = "承認対象の通知が見つかりませんでした"
                        self.showSaveAlert = true
                    }
                }
            case .failure(let error):
                print("通知取得エラー: \(error)")
            }
        }
    }
    
    private func fetchUser(userId: String) {
        NetworkManager.fetchUser(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print(error)
                    self.isLoading = false
                }
            }
        }
    }
    // ヘッダー画像
    func headerImageSection(user: User) -> some View {
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    // 画像部分
                    if let url = URL(string: user.mainImageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 300)
                                .clipped()
                                .contextMenu {
                                    Button {
                                        downloadAndSaveImage(url: user.mainImageUrl)
                                    } label: {
                                        Label("画像を保存", systemImage: "square.and.arrow.down")
                                    }
                                }
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geometry.size.width, height: 300)
                                .overlay(ProgressView())
                        }
                    }
                    
                    // グラデーション
                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
                        .frame(width: geometry.size.width, height: 100) // 幅を固定
                }
            }
            .frame(height: 300) // GeometryReader自体の高さを確保
        }
    
    // ユーザー基本情報
    func userInfoHeader(user: User) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if let iconUrl = user.userIcon, !iconUrl.isEmpty {
                contextMenuImage(url: iconUrl, height: 60, width: 60, contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.safeDisplayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                if let pronouns = user.pronouns, !pronouns.isEmpty {
                    Text(pronouns)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                }
                
                HStack {
                    Text(user.trustRank.0)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(user.trustRank.1.opacity(0.15))
                        .foregroundColor(user.trustRank.1)
                        .cornerRadius(8)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(user.statusColor)
                            .frame(width: 8, height: 8)
                        
                        Text((user.location == "offline" ? "Offline" : user.status?.capitalized) ?? "Offline")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let desc = user.statusDescription, !desc.isEmpty {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
    }
    
    func noteSection(note: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label("Note", systemImage: "note.text")
                .font(.headline)
            Text(note)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // バッジセクション
    func badgesSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Badges")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                ForEach(user.badges ?? []) { badge in
                    if let urlString = badge.badgeImageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            selectedBadge = badge
                        }
                    }
                }
            }
        }
    }
    
    // Bioセクション
    func bioSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Biography", systemImage: "text.alignleft")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(user.bio ?? "Nothing Here")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let links = user.bioLinks, !links.isEmpty {
                    Divider()
                    ForEach(links, id: \.self) { link in
                        if let url = URL(string: link) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "link")
                                    Text(link).lineLimit(1).truncationMode(.middle)
                                }
                                .font(.caption)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    // 詳細情報セクション
    func detailsSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Details", systemImage: "info.circle").font(.headline)
            VStack(spacing: 0) {
                DetailRow(key: "Joined", value: user.date_joined ?? "-")
                if let login = user.last_login {
                    Divider()
                    DetailRow(key: "Last Login", value: login)
                }
                if let platform = user.last_platform {
                    Divider()
                    DetailRow(key: "Platform", value: platform.capitalized)
                }
                Divider()
                DetailRow(key: "Copy Avatar", value: (user.allowAvatarCopying ?? false) ? "Allowed" : "Private")
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    // 現在のアバター（プロフィール画像とは別の場合に表示）
    func currentAvatarSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Current Avatar", systemImage: "person.fill.viewfinder")
                .font(.headline)
            
            HStack {
                contextMenuImage(url: user.currentAvatarThumbnailImageUrl ?? "", height: 80, width: 80)
                    .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text("Avatar Preview")
                        .font(.subheadline)
                        .bold()
                    Text("This is the avatar currently being used.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    // タグセクション
    func tagsSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Tags", systemImage: "tag")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(user.tags ?? [], id: \.self) { tag in
                    Text(tag.replacingOccurrences(of: "system_", with: "").replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(6)
                }
            }
        }
    }
    
    private func downloadAndSaveImage(url: String) {
            guard let imageURL = URL(string: url) else { return }
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try Data(contentsOf: imageURL)
                    if let image = UIImage(data: data) {
                        // フォトライブラリへ保存
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        DispatchQueue.main.async {
                            self.saveMessage = "画像を保存しました"
                            self.showSaveAlert = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.saveMessage = "保存に失敗しました: \(error.localizedDescription)"
                        self.showSaveAlert = true
                    }
                }
            }
        }
}
    
struct DetailRow: View {
    let key: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(key)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .layoutPriority(1)
        }
        .padding()
    }
}

struct NotificationSimple: Codable {
    let id: String
    let senderUserId: String
    let type: String
}

//#Preview {
//    UserView(userId: "usr_bd77ec85-06f6-4f88-9978-4c16dc13a483")
//}
