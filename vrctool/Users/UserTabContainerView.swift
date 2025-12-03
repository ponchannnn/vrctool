//
//  UserTabContainerView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//

import SwiftUI
enum UserListMode {
    case local
    case api(onSearch: (String) -> Void)
}

enum FriendListTab: String, CaseIterable, Identifiable {
    case all = "All"
    case favorites = "Favorites"
    case search = "Search"
    
    var id: String { rawValue }
}

struct FavoriteGroup: Codable, Identifiable {
    let id: String
    let name: String
    let displayName: String
    let type: String
    let visibility: String
    
    var label: String { displayName.isEmpty ? name : displayName }
}

struct Favorite: Codable, Identifiable {
    let id: String
    let favoriteId: String
    let tags: [String]
}

struct UserTabContainerView: View {
    @State private var allFriends: [User] = []
    @State private var searchResults: [User] = []
    @State private var favorites: [User] = []
    
    @State private var favoriteGroups: [FavoriteGroup] = []
    @State private var selectedGroupTag: String? = nil
    @State private var currentGroupName: String = "Select Group"
    @State private var loadedGroupTag: String? = nil
    
    @State private var searchOffset = 0
    @State private var searchHasMore = false
    
    @State private var isLoading = true
    
    @AppStorage("selectedFriendListTab") private var selectedTab: FriendListTab = .all

    @State private var currentApiSearchQuery = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Mode", selection: $selectedTab) {
                    ForEach(FriendListTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(uiColor: .systemBackground))
                .onChange(of: selectedTab) { newValue in
                    handleTabChange(tab: newValue)
                }
                
                contentView
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if allFriends.isEmpty && selectedTab != .search {
                    Task { await loadAllFriends() }
                }
            }
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        switch selectedTab {
        case .all:
            UserListView(
                users: allFriends,
                isLoading: isLoading,
                mode: .local,
                onLoadMore: { },
                hasMoreData: false,
                onRefresh: { await loadAllFriends() }
            )
            
        case .favorites:
            if selectedGroupTag == nil {
                VStack {
                    Image(systemName: "arrow.up.right.circle")
                        .font(.system(size: 50)).foregroundColor(.secondary)
                    Text("右上のメニューから\nグループを選択してください")
                        .multilineTextAlignment(.center).foregroundColor(.secondary).padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    favoriteGroupMenu
                }
            } else {
                UserListView(
                    users: favorites,
                    isLoading: isLoading,
                    mode: .local,
                    onLoadMore: { },
                    hasMoreData: false,
                    onRefresh: { await refreshFavorites() }
                )
                .toolbar {
                    favoriteGroupMenu
                }
            }
            
        case .search:
            UserListView(
                users: searchResults,
                isLoading: false,
                mode: .api { query in
                    resetAndSearch(query: query)
                    
                },
                onLoadMore: { loadMoreSearchResults() },
                hasMoreData: searchHasMore,
                onRefresh: { await refreshSearch()}
            )
        }
    }
    
    var navigationTitle: String {
        switch selectedTab {
        case .all: return "All Friends"
        case .favorites: return currentGroupName
        case .search: return "Search"
        }
    }
    
    var favoriteGroupMenu: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Text("Groups")
                ForEach(favoriteGroups) { group in
                    Button { loadFavorites(in: group) } label: {
                        Label(group.label, systemImage: group.name == selectedGroupTag ? "checkmark" : "")
                    }
                }
            } label: {
                HStack {
                    Text(currentGroupName).font(.caption).fontWeight(.bold)
                    Image(systemName: "line.3.horizontal.decrease.circle.fill").font(.title3)
                }
            }
        }
    }
    
    // MARK: - Logic
    
    func handleTabChange(tab: FriendListTab) {
        switch tab {
        case .all:
            if allFriends.isEmpty {
                Task {
                    await loadAllFriends()
                }
            }
        case .favorites:
            if favoriteGroups.isEmpty {
                loadFavoriteGroups()
            } else if let tag = selectedGroupTag, let group = favoriteGroups.first(where: { $0.name == tag }) {
                if favorites.isEmpty && loadedGroupTag != group.name {
                    loadFavorites(in: group)
                }
            }
        case .search:
            break
        }
    }
    
    func loadAllFriends() async {
        await MainActor.run { isLoading = true }
        
        await withCheckedContinuation { continuation in
            NetworkManager.fetchAllFriendsCombined { result in
                DispatchQueue.main.async {
                    if case .success(let data) = result {
                        self.allFriends = data
                    }
                    self.isLoading = false
                    continuation.resume()
                }
            }
        }
    }
    
    func resetAndSearch(query: String) {
        guard !query.isEmpty else { return }
        self.searchResults = []
        self.searchOffset = 0
        self.searchHasMore = true
        self.isLoading = true
        self.currentApiSearchQuery = query
        
        performUserSearch(query: query, isLoadMore: false)
    }
    
    func loadMoreSearchResults() {
        guard searchHasMore && !isLoading else { return }
        performUserSearch(query: currentApiSearchQuery, isLoadMore: true)
    }
    
    func performUserSearch(query: String, isLoadMore: Bool) {
        guard !query.isEmpty else { return }
        isLoading = true
        
        let q = [
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "n", value: "100"),
            URLQueryItem(name: "offset", value: "\(searchOffset)")
        ]
        NetworkManager.request(endpoint: "users", queryItems: q) { (result: Result<[User], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if isLoadMore {
                        self.searchResults.append(contentsOf: data)
                    } else {
                        self.searchResults = data
                    }
                    
                    self.searchOffset += data.count
                    self.searchHasMore = data.count >= 100
                    
                case .failure(let error):
                    print("Search Error: \(error)")
                }
                self.isLoading = false
            }
        }
    }
    
    func refreshFavorites() async {
        if let tag = selectedGroupTag, let group = favoriteGroups.first(where: { $0.name == tag }) {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    self.loadFavorites(in: group)
                    continuation.resume()
                }
            }
        }
    }
    
    func loadFavoriteGroups() {
        NetworkManager.request(endpoint: "favorite/groups") { (result: Result<[FavoriteGroup], Error>) in
            DispatchQueue.main.async {
                if case .success(let groups) = result {
                    self.favoriteGroups = groups.filter { $0.type == "friend" }
                    if let first = self.favoriteGroups.first {
                        self.loadFavorites(in: first)
                    }
                }
            }
        }
    }
    
    // 特定のグループ内のFavoriteを取得し、フレンドリストから抽出
    func loadFavorites(in group: FavoriteGroup) {
        self.selectedGroupTag = group.name
        self.currentGroupName = group.label
        self.isLoading = true
        self.favorites = []
        
        let query = [
            URLQueryItem(name: "type", value: "friend"),
            URLQueryItem(name: "tag", value: group.name),
            URLQueryItem(name: "n", value: "100")
        ]
        
        NetworkManager.fetchAll(endpoint: "favorites", baseQueryItems: query) { (result: Result<[Favorite], Error>) in
            DispatchQueue.main.async {
                if case .success(let favs) = result {
                    self.loadedGroupTag = group.name
                    self.fetchMissingUsersAndMerge(favorites: favs)
                } else {
                    self.isLoading = false
                }
            }
        }
    }
    
    func fetchMissingUsersAndMerge(favorites: [Favorite]) {
            var mergedUsers: [User] = []
            var missingIds: [String] = []
            
            for fav in favorites {
                if let existingUser = allFriends.first(where: { $0.id == fav.favoriteId }) {
                    mergedUsers.append(existingUser)
                } else {
                    missingIds.append(fav.favoriteId)
                }
            }
            
            // 全員キャッシュにいた場合
            if missingIds.isEmpty {
                // オンライン順にソートして表示
                self.favorites = mergedUsers.sorted {
                    ($0.location ?? "offline") != "offline" && ($1.location ?? "offline") == "offline"
                }
                self.isLoading = false
                return
            }
            
            // 足りないIDを並列でAPI取得 (TaskGroup)
            Task {
                await withTaskGroup(of: User?.self) { group in
                    for userId in missingIds {
                        group.addTask {
                            return await fetchUserAsync(userId: userId)
                        }
                    }
                    
                    for await user in group {
                        if let user = user {
                            mergedUsers.append(user)
                        }
                    }
                    
                    await MainActor.run {
                        self.favorites = mergedUsers
                        self.isLoading = false
                    }
                }
            }
        }
    
    func fetchUserAsync(userId: String) async -> User? {
        return await withCheckedContinuation { continuation in
            NetworkManager.request(endpoint: "users/\(userId)") { (result: Result<User, Error>) in
                if case .success(let user) = result {
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func refreshSearch() async {
        if !currentApiSearchQuery.isEmpty {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    self.performUserSearch(query: self.currentApiSearchQuery, isLoadMore: false)
                    continuation.resume()
                }
            }
        }
    }
}

struct UserCardView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                if let url = URL(string: user.currentAvatarThumbnailImageUrl ?? user.userIcon ?? "") {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 60, height: 60)
                }
                
                Circle()
                    .fill(user.statusColor)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: -2, y: -2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.safeDisplayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text(user.trustRank.0)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(user.trustRank.1.opacity(0.15))
                        .foregroundColor(user.trustRank.1)
                        .cornerRadius(4)
                    
                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

//#Preview {
//    UserTabContainerView()
//}
