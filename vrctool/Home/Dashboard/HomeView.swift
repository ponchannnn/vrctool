//
//  HomeView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2024/03/17.
//

import SwiftUI

struct HomeView: View {
    @State private var friends: [User] = []
    @State private var worldCache: [String: World] = [:]
    @State private var isLoading = true
    @State private var errorMessage = ""

    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true
    @AppStorage("isTwoFactored") private var isTwoFactored: Bool = true
    @State private var showLoginView = false
    @State private var showLogoutAlert = false
    
    @State private var showMyProfile = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading Friends...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        if friends.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "person.slash.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("フレンドがいません")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                            
                        } else {
                            VStack(spacing: 20) {
                                ForEach(groupedActiveFriends, id: \.key) { (worldId, friendsInWorld) in
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        
                                        if let world = worldCache[worldId] {
                                            NavigationLink(destination: InstanceView(instanceId: friendsInWorld.first?.location ?? worldId)) {
                                                WorldHeaderView(world: world, friendCount: friendsInWorld.count)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        } else {
                                            Text("World ID: \(worldId)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding()
                                        }
                                        
                                        Divider()
                                        
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 12)], spacing: 12) {
                                            ForEach(friendsInWorld) { friend in
                                                FriendCard(friend: friend)
                                            }
                                        }
                                        .padding(15)
                                    }
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                                    .padding(.horizontal)
                                }
                                
                                // Private ワールドにいるフレンド
                                if !privateFriends.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Label("Private / Other", systemImage: "lock.fill")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal)
                                            .padding(.top, 10)
                                        
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 12)], spacing: 12) {
                                            ForEach(privateFriends) { friend in
                                                FriendCard(friend: friend)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 15)
                                    }
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                                    .padding(.horizontal)
                                }
                                
                                // オフラインのフレンド
                                if !offlineFriends.isEmpty {
                                    VStack(alignment: .leading) {
                                        Label("Offline", systemImage: "moon.zzz.fill")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal)
                                        
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 21)], spacing: 20) {
                                            ForEach(offlineFriends) { friend in
                                                FriendCard(friend: friend)
                                                    .opacity(0.6)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .padding(.vertical)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
                .navigationTitle("Home")
                // ツールバー
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(action: { showMyProfile = true }) {
                                Label("マイページ", systemImage: "person.circle")
                            }
                            Button(role: .destructive, action: { showLogoutAlert = true }) {
                                Label("ログアウト", systemImage: "arrow.right.square")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 18))
                        }
                    }
                }
                // 画面遷移
                .navigationDestination(isPresented: $showMyProfile) {
                    ProfileView()
                }
                // 初回読み込み
                .onAppear {
                    fetchData()
                }
                .refreshable {
                    fetchData()
                }
                // アラート類
                .alert("ログアウト", isPresented: $showLogoutAlert) {
                    Button("キャンセル", role: .cancel) {}
                    Button("ログアウト", role: .destructive) { logout() }
                } message: {
                    Text("本当にログアウトしますか？")
                }
                .fullScreenCover(isPresented: $showLoginView) {
                     LoginView()
                    Text("Login View Placeholder")
                }
            }
    }

    func logout() {
        // ログアウト処理
        isLoggedIn = false
        isTwoFactored = false
        
        // クッキーを削除
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if (cookie.name == "auth" || cookie.name == "twoFactorAuth") {
                    HTTPCookieStorage.shared.deleteCookie(cookie);
                }
            }
        }

        // ログイン画面に遷移
        showLoginView = true
    }

    func fetchData() {
        let query = [URLQueryItem(name: "offline", value: "false"), URLQueryItem(name: "n", value: "100")]
        
        NetworkManager.request(endpoint: "auth/user/friends", queryItems: query) { (result: Result<[User], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedFriends):
                    self.friends = fetchedFriends
                    self.isLoading = false
                    self.updateWorldCache(from: fetchedFriends)
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func fetchAllFriendsCombined(completion: @escaping (Result<[User], Error>) -> Void) {
        let group = DispatchGroup()
        var allUsers: [User] = []
        var fetchError: Error?
        
        // オンライン (offline=false) を全件取得
        group.enter()
        NetworkManager.fetchAll(endpoint: "auth/user/friends", baseQueryItems: [URLQueryItem(name: "offline", value: "false")]) { (result: Result<[User], Error>) in
            switch result {
            case .success(let users):
                DispatchQueue.main.async { allUsers.append(contentsOf: users) }
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }
        
        // オフライン (offline=true) を全件取得
        group.enter()
        NetworkManager.fetchAll(endpoint: "auth/user/friends", baseQueryItems: [URLQueryItem(name: "offline", value: "true")]) { (result: Result<[User], Error>) in
            switch result {
            case .success(let users):
                DispatchQueue.main.async { allUsers.append(contentsOf: users) }
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
            } else {
                let uniqueUsers = Array(Set(allUsers.map { $0.id })).compactMap { id in allUsers.first(where: { $0.id == id }) }
                completion(.success(uniqueUsers))
            }
        }
    }
    
    func updateWorldCache(from friends: [User]) {
            // locationから "wrld_xxx" の部分だけを取り出して重複を排除
            let worldIds = Set(friends.compactMap { $0.worldId })
            
            for wid in worldIds {
                if worldCache[wid] != nil { continue }
                
                NetworkManager.fetchWorld(worldId: wid) { result in
                    DispatchQueue.main.async {
                        if case .success(let world) = result {
                            self.worldCache[wid] = world
                        }
                    }
                }
            }
        }
    
    // location文字列から有効なWorldIDを持っているフレンドのみ抽出してグループ化
    var groupedActiveFriends: [(key: String, value: [User])] {
        let active = friends.filter { $0.status != "offline" && $0.worldId != nil }
        let grouped = Dictionary(grouping: active) { $0.worldId! }
        // 人数が多い順にソート
        return grouped.sorted { $0.value.count > $1.value.count }
    }
    
    // Privateにいる人 (ActiveだけどWorldIDがnilの人)
    var privateFriends: [User] {
        return friends.filter { $0.status != "offline" && $0.worldId == nil }
    }
    
    // オフラインの人
    var offlineFriends: [User] {
        return friends.filter { $0.status == "offline" }
    }
}

struct SectionTitle: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.headline)
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

struct WorldHeaderView: View {
    let world: World
    let friendCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // ワールド画像
            if let url = URL(string: world.safeThumbnailImageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 50)
                        .clipped()
                        .cornerRadius(8)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 70, height: 50).cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(world.safeName)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                    Text("\(friendCount)")
                        .fontWeight(.bold)
                    
                    Text("• \(world.safeCapacity) max")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.4))
                .font(.caption)
        }
        .padding()
    }
}

struct FriendCard: View {
    var friend: User
    
    var statusColor: Color {
        switch friend.status {
        case "join me": return .blue
        case "active": return .green
        case "ask me": return .orange
        case "busy": return .red
        case "offline": return .gray
        default: return .green
        }
    }
    
    var body: some View {
        NavigationLink(destination: UserView(userId: friend.id)) {
            VStack(alignment: .leading, spacing: 0) {
                // 画像エリア
                ZStack(alignment: .bottomTrailing) {
                    // アバターサムネイルを使用
                    if let url = URL(string: friend.safeThumbnailUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: .infinity) // 高さを固定
                                .frame(maxWidth: .infinity)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 100)
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 100)
                    }
                    
                    // ステータスランプ
                    Circle()
                        .fill(statusColor)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: -6, y: -6)
                }
                
                // テキストエリア
                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.safeDisplayName)
                        .font(.caption)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    if !friend.safeStatusDescription.isEmpty {
                        Text(friend.safeStatusDescription)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        // レイアウト崩れ防止のための空文字スペース
                        Text(" ")
                            .font(.caption2)
                    }
                }
                .padding(8)
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            .frame(width: 110)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}
