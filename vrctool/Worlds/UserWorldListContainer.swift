//
//  UserWorldListContainer.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//
import SwiftUI

enum UserWorldTab: String, CaseIterable, Identifiable {
    case uploaded = "Uploaded"
    case favorites = "Favorites"
    var id: String { rawValue }
}

struct UserWorldListContainer: View {
    let userId: String
    let userName: String
    let isFriend: Bool
    
    @State private var selectedTab: UserWorldTab = .uploaded

    // --- Uploaded Worlds Data ---
    @State private var uploadedWorlds: [World] = []
    @State private var isUploadedLoading = true
    
    // --- Favorite Worlds Data ---
    @State private var favoriteWorlds: [World] = []
    @State private var favoriteGroups: [FavoriteGroup] = []
    @State private var selectedGroupTag: String? = nil
    @State private var currentGroupName: String = "Select Group"
    @State private var isFavoritesLoading = false // 初期はロードしない
    @State private var hasLoadedGroups = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isFriend {
                Picker("Tab", selection: $selectedTab) {
                    ForEach(UserWorldTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(uiColor: .systemBackground))
                .onChange(of: selectedTab) { newValue in
                    if newValue == .favorites && !hasLoadedGroups {
                        loadFavoriteGroups()
                    }
                }
            }
            
            Group {
                switch selectedTab {
                case .uploaded:
                    WorldListView(
                        worlds: uploadedWorlds,
                        isLoading: isUploadedLoading,
                        searchConfig: .localFilter,
                        onRefresh: { await loadUserWorlds() },
                        onLoadMore: { },
                        hasMoreData: false,
                        emptyMessage: "No public worlds found."
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                case .favorites:
                    if favoriteGroups.isEmpty && !isFavoritesLoading && hasLoadedGroups {
                        // ロード済みだがグループが空（非公開など）
                        VStack(spacing: 16) {
                            Image(systemName: "lock.slash")
                                .font(.system(size: 50)).foregroundColor(.gray)
                            Text("公開されているお気に入りがありません")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if selectedGroupTag == nil {
                        // ロード中、または未選択
                        if isFavoritesLoading {
                            ProgressView("Loading Groups...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            Text("Select a group").frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        WorldListView(
                            worlds: favoriteWorlds,
                            isLoading: isFavoritesLoading,
                            searchConfig: .localFilter,
                            onRefresh: { await refreshFavorites() },
                            onLoadMore: { },
                            hasMoreData: false,
                            emptyMessage: "ワールドがありません"
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
            }
        }
        .navigationTitle("\(userName)'s Worlds")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if selectedTab == .favorites && !favoriteGroups.isEmpty {
                ToolbarItem(placement: .principal) {
                    Menu {
                        Text("Select Group")
                        ForEach(favoriteGroups) { group in
                            Button { selectGroup(group) } label: {
                                if group.name == selectedGroupTag {
                                    Label(group.label, systemImage: "checkmark")
                                } else {
                                    Text(group.label)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(currentGroupName).font(.headline).foregroundColor(.primary)
                            Image(systemName: "chevron.down.circle.fill").font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .onAppear {
            if uploadedWorlds.isEmpty {
                Task { await loadUserWorlds() }
            }
        }
    }
    
    // MARK: - Logic: Uploaded
        
    func loadUserWorlds() async {
        await MainActor.run { isUploadedLoading = true }
        await withCheckedContinuation { continuation in
            let queryItems = [
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "sort", value: "updated"),
                URLQueryItem(name: "n", value: "100")
            ]
            NetworkManager.request(endpoint: "worlds", queryItems: queryItems) { (result: Result<[World], Error>) in
                DispatchQueue.main.async {
                    if case .success(let data) = result {
                        self.uploadedWorlds = data
                    }
                    self.isUploadedLoading = false
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Logic: Favorites
    
    func loadFavoriteGroups() {
        isFavoritesLoading = true
        let query = [URLQueryItem(name: "ownerId", value: userId)]
        
        NetworkManager.request(endpoint: "favorite/groups", queryItems: query) { (result: Result<[FavoriteGroup], Error>) in
            DispatchQueue.main.async {
                self.hasLoadedGroups = true
                if case .success(let groups) = result {
                    // type="world" のみ抽出
                    self.favoriteGroups = groups.filter { $0.type == "world" }
                    
                    if let first = self.favoriteGroups.first {
                        self.selectGroup(first) // 自動的に最初のグループをロード
                    } else {
                        self.isFavoritesLoading = false
                    }
                } else {
                    self.isFavoritesLoading = false
                }
            }
        }
    }
    
    func selectGroup(_ group: FavoriteGroup) {
        self.selectedGroupTag = group.name
        self.currentGroupName = group.label
        self.isFavoritesLoading = true
        self.favoriteWorlds = []
        
        let query = [
            URLQueryItem(name: "type", value: "world"),
            URLQueryItem(name: "tag", value: group.name),
            URLQueryItem(name: "ownerId", value: userId),
            URLQueryItem(name: "n", value: "100")
        ]
        
        // IDリスト取得
        NetworkManager.fetchAll(endpoint: "favorites", baseQueryItems: query) { (result: Result<[Favorite], Error>) in
            DispatchQueue.main.async {
                if case .success(let favorites) = result {
                    self.fetchWorldDetails(favorites: favorites)
                } else {
                    self.isFavoritesLoading = false
                }
            }
        }
    }
    
    func fetchWorldDetails(favorites: [Favorite]) {
        if favorites.isEmpty {
            self.isFavoritesLoading = false
            return
        }
        
        Task {
            var fetchedWorlds: [World] = []
            await withTaskGroup(of: World?.self) { group in
                for fav in favorites {
                    group.addTask { await fetchWorldAsync(worldId: fav.favoriteId) }
                }
                for await world in group {
                    if let world = world { fetchedWorlds.append(world) }
                }
            }
            await MainActor.run {
                self.favoriteWorlds = fetchedWorlds
                self.isFavoritesLoading = false
            }
        }
    }
    
    func fetchWorldAsync(worldId: String) async -> World? {
        return await withCheckedContinuation { continuation in
            NetworkManager.request(endpoint: "worlds/\(worldId)") { (result: Result<World, Error>) in
                if case .success(let data) = result { continuation.resume(returning: data) }
                else { continuation.resume(returning: nil) }
            }
        }
    }
    
    func refreshFavorites() async {
        if let tag = selectedGroupTag, let group = favoriteGroups.first(where: { $0.name == tag }) {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    self.selectGroup(group)
                    continuation.resume()
                }
            }
        }
    }
}
