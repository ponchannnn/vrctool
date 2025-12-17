import SwiftUI

// MARK: - Models

struct Instance: Codable {
    let active: Bool
    let canRequestInvite: Bool
    let capacity: Int
    let clientNumber: String
    let closedAt: String?
    let displayName: String?
    let full: Bool
    let hardClose: String?
    let hasCapacityForYou: Bool
    let id: String
    let instanceId: String
    let instancePersistenceEnabled: Bool?
    let location: String
    let n_users: Int
    let name: String
    let ownerId: String?
    let creatorId: String?
    let permanent: Bool
    let photonRegion: String
    let platforms: InstancePlatforms
    let playerPersistenceEnabled: Bool?
    let queueEnabled: Bool
    let queueSize: Int
    let recommendedCapacity: Int
    let region: String
    let secureName: String
    let shortName: String?
    let strict: Bool
    let tags: [String]
    let type: String
    let userCount: Int
    let world: World
    let worldId: String
    

    var typeInfo: (String, Color) {
        switch type {
        case "public": return ("Public", .green)
        case "hidden": return ("Friends+", .orange)
        case "friends": return ("Friends", .yellow)
        case "private": return ("Invite", .red)
        default: return (type.capitalized, .gray)
        }
    }
    
    // リージョンに応じた国旗
    var regionFlag: String {
        if region.lowercased().contains("jp") { return "🇯🇵 JP" }
        if region.lowercased().contains("us") { return "🇺🇸 US" }
        if region.lowercased().contains("eu") { return "🇪🇺 EU" }
        return "🌐 \(region.uppercased())"
    }
}

struct InstancePlatforms: Codable {
    let android: Int
    let ios: Int
    let standalonewindows: Int
    
    // 対応プラットフォームがあるか
    var hasPC: Bool { standalonewindows > 0 }
    var hasQuest: Bool { android > 0 }
    var hasMobile: Bool { ios > 0 || android > 0 }
}

// MARK: - Views
struct InstanceView: View {
    @State var instance: Instance?
    let instanceId: String?
    
    @State private var group: UserGroup?
    
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showInviteSheet = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(instanceId: String) {
        self.instanceId = instanceId
        self._instance = State(initialValue: nil)
    }
    
    init(instance: Instance) {
        self.instanceId = instance.id
        self._instance = State(initialValue: instance)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let instance = instance {
                    VStack(spacing: 20) {
                        // ヘッダー (ワールド画像 + インスタンス名)
                        headerSection(instance: instance)
                        
                        // インスタンス情報 (人数、Region、Type)
                        instanceInfoSection(instance: instance)
                        
                        if let group = group {
                            groupInfoSection(group: group)
                        }
                        
                        Divider()
                        
                        // ワールド情報
                        worldDetailsSection(world: instance.world)
                    }
                } else if isLoading {
                    ProgressView("Loading Instance...")
                        .padding(.top, 100)
                } else {
                    Text("Failed to load instance.")
                        .foregroundColor(.secondary)
                        .padding(.top, 100)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if instanceId != nil {
                    fetchData()
                }
            }
            .refreshable {
                fetchData()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let instance = instance {
                        Menu {
                            Section {
                                Button(action: inviteMyself) {
                                    Label("自分を招待", systemImage: "arrow.uturn.left")
                                }
                                
                                Button(action: { showInviteSheet = true }) {
                                    Label("フレンドを招待...", systemImage: "person.badge.plus")
                                }
                            }
                            
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .sheet(isPresented: $showInviteSheet) {
                if let instance = instance {
                    InviteFriendSheet(instanceId: instance.id)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Logic
    
    func fetchData() {
        guard let id = instanceId else { return }
        isLoading = true
        
        NetworkManager.request(endpoint: "instances/\(id)") { (result: Result<Instance, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.instance = data
                    self.checkAndFetchGroup(instance: data)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print(error)
                }
                self.isLoading = false
            }
        }
    }
    
    func checkAndFetchGroup(instance: Instance) {
        // instanceIdの中に "grp_" が含まれていればグループインスタンス
        if let range = instance.instanceId.range(of: "grp_[a-zA-Z0-9\\-]+", options: .regularExpression) {
            let groupId = String(instance.instanceId[range])
            NetworkManager.request(endpoint: "groups/\(groupId)") { (result: Result<UserGroup, Error>) in
                DispatchQueue.main.async {
                    if case .success(let info) = result {
                        self.group = info
                    }
                }
            }
        }
    }
    
    func inviteMyself() {
        guard let id = instance?.id else { return }
        NetworkManager.action(endpoint: "instances/\(id)/invite", method: "POST") { (result: Result<String, Error>) in
            DispatchQueue.main.async {
                if case .success = result {
                    self.alertMessage = "招待を送りました"
                } else {
                    self.alertMessage = "送信失敗"
                }
                self.showAlert = true
            }
        }
    }
    
    // MARK: - Subviews
    
    func headerSection(instance: Instance) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if let url = URL(string: instance.world.imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: geometry.size.width, height: 300)
                    }
                }
                
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(instance.world.name):\(instance.name)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .shadow(radius: 4)
                        
                        HStack {
                            if instance.active {
                                Label("\(instance.n_users) / \(instance.capacity) Users", systemImage: "person.2.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.green.opacity(0.8))
                                    .cornerRadius(20)
                            } else {
                                Label("OFFLINE", systemImage: "wifi.slash")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.gray.opacity(0.8))
                                    .cornerRadius(20)
                            }
                            
                            if instance.full {
                                Text("FULL(\(instance.n_users) / \(instance.capacity) Users)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.red)
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(height: 300)
    }
    
    func instanceInfoSection(instance: Instance) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 0) {
                // 人数
                VStack {
                    Text("\(instance.n_users) / \(instance.capacity)")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(instance.full ? .red : .primary)
                    
                    // プラットフォーム内訳
                    HStack(spacing: 6) {
                        if instance.platforms.android > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "circle.grid.2x2.fill").font(.caption2).foregroundColor(.green)
                                Text("\(instance.platforms.android)").font(.caption2)
                            }
                        }
                        if instance.platforms.standalonewindows > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "pc").font(.caption2).foregroundColor(.blue)
                                Text("\(instance.platforms.standalonewindows)").font(.caption2)
                            }
                        }
                        if instance.platforms.ios > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "iphone").font(.caption2).foregroundColor(.orange)
                                Text("\(instance.platforms.ios)").font(.caption2)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 40)
                
                // Region
                VStack {
                    Text(instance.regionFlag).font(.title2)
                    Text("Region").font(.caption).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 40)
                
                // Access
                VStack {
                    Text(instance.typeInfo.0)
                        .font(.headline).foregroundColor(instance.typeInfo.1)
                    Text("Access").font(.caption).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            if let closedAt = instance.closedAt {
                Divider()
                HStack {
                    Image(systemName: "lock.fill").foregroundColor(.red)
                    Text("Closed at: \(formatDate(closedAt))")
                        .font(.subheadline).bold().foregroundColor(.red)
                    Spacer()
                }
            }
            
            if instance.type == "group" || instance.instanceId.contains("groupAccessType(public)") {
                if instance.closedAt == nil { Divider() }
                HStack {
                    Image(systemName: "person.3.fill").foregroundColor(.blue)
                    Text("Public Group Instance")
                        .font(.subheadline).bold().foregroundColor(.blue)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    func groupInfoSection(group: UserGroup) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Group").font(.headline)
            NavigationLink(destination: Text("Group Detail: \(group.safeName)")) {
                HStack(spacing: 12) {
                    if let iconId = group.iconId, !iconId.isEmpty,
                       let url = URL(string: "https://api.vrchat.cloud/api/1/file/\(iconId)/1/file") {
                        
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                        
                    } else {
                        // アイコンがない場合のプレースホルダー
                        Image(systemName: "person.3.fill")
                            .frame(width: 50, height: 50)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(group.safeName).font(.headline).foregroundColor(.primary)
                        Text(group.fullCode)
                            .font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.gray)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    func worldDetailsSection(world: World) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("World Details").font(.headline)
            
            if let desc = world.description {
                Text(desc)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(10)
            }
            
            VStack(spacing: 0) {
                NavigationLink(destination: UserView(userId: world.authorId)) {
                    HStack {
                        Text("Author").foregroundColor(.secondary)
                        Spacer()
                        Text(world.authorName).fontWeight(.bold).foregroundColor(.blue)
                        Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                    }
                    .padding()
                }
                Divider()
                DetailRow(key: "Visits", value: world.formatNumber(world.visits))
                Divider()
                DetailRow(key: "Favorites", value: world.formatNumber(world.favorites))
                Divider()
                DetailRow(key: "Updated", value: String(world.updated_at.prefix(10)))
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(10)
            
            if let tags = world.tags {
                TagsView(tags: tags)
            }
        }
        .padding()
    }
    
    func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd HH:mm"
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Invite Sheet (フレンド招待用モーダル)

struct InviteFriendSheet: View {
    let instanceId: String
    @Environment(\.dismiss) var dismiss
    
    @State private var friends: [User] = []
    @State private var isLoading = true
    @State private var searchText = ""
    
    @State private var showResultAlert = false
    @State private var resultMessage = ""
    
    var filteredFriends: [User] {
        if searchText.isEmpty { return friends }
        return friends.filter { $0.safeDisplayName.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    ProgressView()
                } else {
                    ForEach(filteredFriends) { friend in
                        Button {
                            sendInvite(to: friend.id)
                        } label: {
                            HStack {
                                if let urlString = friend.currentAvatarThumbnailImageUrl,
                                   let url = URL(string: urlString) {
                                    AsyncImage(url: url) { i in i.resizable() } placeholder: { Color.gray }
                                        .frame(width: 40, height: 40).clipShape(Circle())
                                }
                                Text(friend.safeDisplayName)
                                Spacer()
                                Image(systemName: "paperplane")
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search online friends")
            .navigationTitle("Invite Friend")
            .toolbar {
                Button("Close") { dismiss() }
            }
            .onAppear {
                let query = [URLQueryItem(name: "offline", value: "false")]
                NetworkManager.request(endpoint: "auth/user/friends", queryItems: query) { (result: Result<[User], Error>) in
                    DispatchQueue.main.async {
                        if case .success(let data) = result { self.friends = data }
                        self.isLoading = false
                    }
                }
            }
            .alert("Result", isPresented: $showResultAlert) {
                Button("OK") {}
            } message: {
                Text(resultMessage)
            }
        }
    }
    
    func sendInvite(to userId: String) {
        let body: [String: Any] = ["type": "invite", "details": ["worldId": instanceId]]
        NetworkManager.action(endpoint: "user/\(userId)/notification", method: "POST", body: body) { (result: Result<String, Error>) in
            DispatchQueue.main.async {
                if case .success = result {
                    self.resultMessage = "招待を送りました"
                } else {
                    self.resultMessage = "送信失敗"
                }
                self.showResultAlert = true
            }
        }
    }
}

// 簡易タグビュー
struct TagsView: View {
    let tags: [String]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(formatTag(tag))
                    .font(.caption2)
                    .padding(6)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(6)
            }
        }
    }
    func formatTag(_ tag: String) -> String {
        tag.replacingOccurrences(of: "author_tag_", with: "")
           .replacingOccurrences(of: "system_", with: "").capitalized
    }
}

//#Preview {
//    InstanceView(instanceId: "wrld_beddab1e-fee1-cafe-f00d-ca7c0dd1eca7:73880~hidden(usr_27e495f4-b619-41ca-b451-2a6399196182)~region(jp)")
//}
//#Preview {
//    InstanceView(instanceId: "wrld_bf51e60f-f372-48b1-a757-88ba8331d926:19225~group(grp_cda05c57-88f2-4514-8f06-ff9ff2db6f5b)~groupAccessType(public)~region(jp)")
//}
