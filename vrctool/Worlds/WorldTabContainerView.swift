//
//  WorldTabContainerView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//
import SwiftUI

enum WorldCategory: String, CaseIterable, Identifiable {
    case active = "Active"
    case recent = "Recent"
    case favorites = "Favorites"
    case search = "Search"
    
    var id: String { self.rawValue }
    
    // カテゴリごとのAPIエンドポイント
    var apiPath: String {
        switch self {
        case .active: return "worlds/active"
        case .recent: return "worlds/recent"
        case .favorites: return "worlds/favorites"
        case .search: return "worlds"
        }
    }
    
    var label: String {
        switch self {
        case .active: return "Active"
        case .recent: return "Recent"
        case .favorites: return "Faves"
        case .search: return "Search"
        }
    }
    
    // アイコン (必要なら使用)
    var icon: String {
        switch self {
        case .active: return "flame"
        case .recent: return "clock"
        case .favorites: return "star"
        case .search: return "magnifyingglass"
        }
    }
}

struct WorldTabContainerView: View {
    @AppStorage("selectedWorldCategory") private var selectedCategory: WorldCategory = .active
    
    @State private var worlds: [World] = []
    @State private var isLoading = false
    @State private var offset = 0
    @State private var hasMoreData = true
    let limit = 100
    
    @State private var favoriteGroups: [FavoriteGroup] = []
    @State private var selectedGroupTag: String? = nil
    @State private var currentGroupName: String = "Select Group"
    
    @State private var currentApiSearchQuery = ""
    
    @State private var favoriteWorldsCache: [String: [World]] = [:]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(WorldCategory.allCases) { category in
                        Label(category.label, systemImage: category.icon)
                            .tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(uiColor: .systemBackground))
                
                WorldListView(
                    worlds: worlds,
                    isLoading: isLoading,
                    searchConfig: currentSearchConfig,
                    onRefresh: {
                        await refreshData()
                    },
                    onLoadMore: { loadMoreData() },
                    hasMoreData: hasMoreData,
                    emptyMessage: emptyMessage
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle(selectedCategory == .favorites ? "" : "Worlds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if selectedCategory == .favorites {
                    ToolbarItem(placement: .principal) {
                        Menu {
                            if favoriteGroups.isEmpty {
                                Button {
                                    loadFavoriteGroups()
                                } label: {
                                    Label("グループを読み込む", systemImage: "arrow.clockwise")
                                }
                                .onAppear { loadFavoriteGroups() }
                            } else {
                                Text("Select Group")
                                ForEach(favoriteGroups) { group in
                                    Button {
                                        selectFavoriteGroup(group)
                                    } label: {
                                        if group.name == selectedGroupTag {
                                            Label(group.label, systemImage: "checkmark")
                                        } else {
                                            Text(group.label)
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(currentGroupName)
                                    .font(.headline).foregroundColor(.primary)
                                Image(systemName: "chevron.down.circle.fill")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .onChange(of: selectedCategory) { newValue in
                if newValue == .favorites && favoriteGroups.isEmpty {
                    loadFavoriteGroups()
                }
                if newValue == .favorites,
                   let tag = selectedGroupTag,
                   let cached = favoriteWorldsCache[tag] {
                    self.isLoading = false
                    self.worlds = cached
                    return
                }
                resetAndFetch()
            
            }
            .onAppear {
                if worlds.isEmpty && selectedCategory != .search {
                    if selectedCategory == .favorites {
                        loadFavoriteGroups()
                    } else {
                        resetAndFetch()
                    }
                }
            }
        }
    }
        
    var currentSearchConfig: SearchConfig {
        if selectedCategory == .search || selectedCategory == .active {
            return .apiSearch { query in
                resetAndFetch(searchQuery: query)
            }
        } else {
            return .localFilter
        }
    }
    
    var emptyMessage: String {
        if selectedCategory == .search{
            return "キーワードを入力して検索"
        }
        return "ワールドが見つかりません"
    }
    
    func loadFavoriteGroups() {
        isLoading = true
        NetworkManager.request(endpoint: "favorite/groups") { (result: Result<[FavoriteGroup], Error>) in
            DispatchQueue.main.async {
                if case .success(let groups) = result {
                    self.favoriteGroups = groups.filter { $0.type == "world" }
                    if let first = self.favoriteGroups.first {
                        selectFavoriteGroup(first)
                    } else {
                        self.isLoading = false
                    }
                } else {
                    self.isLoading = false
                }
            }
        }
    }
    
    func selectFavoriteGroup(_ group: FavoriteGroup) {
        self.selectedGroupTag = group.name
        self.currentGroupName = group.label
        
        if let cachedWorlds = favoriteWorldsCache[group.name] {
            self.worlds = cachedWorlds
            self.isLoading = false
            return
        }
        resetAndFetch()
    }
    
    func resetAndFetch(searchQuery: String? = nil) {
        self.worlds = []
        self.offset = 0
        self.hasMoreData = true
        self.isLoading = true
        
        if let query = searchQuery {
            self.currentApiSearchQuery = query
        } else {
            self.currentApiSearchQuery = ""
        }
        if self.selectedCategory == .favorites {
            loadFavoriteGroups()
        }
        fetchData(isLoadMore: false, searchQuery: self.currentApiSearchQuery)
    }
    
    func loadMoreData(searchQuery: String? = nil) {
        guard hasMoreData && !isLoading else { return }
        if let query = searchQuery {
            fetchData(isLoadMore: true, searchQuery: query)
        } else {
            fetchData(isLoadMore: true)
        }
    }
    
    func fetchData(isLoadMore: Bool, searchQuery: String? = nil) {
        self.isLoading = true
        if selectedCategory == .search || selectedCategory == .active {
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "n", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "sort", value: "relevance")
            ]
            
            if let query = searchQuery {
                queryItems.append(URLQueryItem(name: "search", value: query))
            }
            
            NetworkManager.request(endpoint: selectedCategory.apiPath, queryItems: queryItems) { (result: Result<[World], Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let newWorlds):
                        if isLoadMore {
                            self.worlds.append(contentsOf: newWorlds)
                        } else {
                            self.worlds = newWorlds
                        }
                        self.offset += newWorlds.count
                        self.hasMoreData = newWorlds.count >= self.limit
                        
                    case .failure(let error):
                        print("Search Fetch Error: \(error)")
                    }
                    self.isLoading = false
                }
            }
        } else if selectedCategory == .favorites {
            guard let tag = selectedGroupTag else { return }
            
            let query = [
                URLQueryItem(name: "type", value: "world"),
                URLQueryItem(name: "tag", value: tag),
                URLQueryItem(name: "n", value: "100")
            ]
            
            NetworkManager.fetchAll(endpoint: selectedCategory.apiPath, baseQueryItems: query) { (result: Result<[World], Error>) in
                DispatchQueue.main.async {
                    if case .success(let favs) = result {
                        self.hasMoreData = false
                        self.favoriteWorldsCache[tag] = favs
                    } else {
                        self.isLoading = false
                    }
                }
            }
        } else if selectedCategory == .recent {
            NetworkManager.fetchAll(endpoint: selectedCategory.apiPath) { (result: Result<[World], Error>) in
                DispatchQueue.main.async {
                    if case .success(let data) = result {
                        self.worlds = data
                        self.hasMoreData = false
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    func refreshData() async {
        await MainActor.run {
            self.offset = 0
            self.hasMoreData = true
        }
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                resetAndFetch()
                continuation.resume()
            }
        }
    }
}
