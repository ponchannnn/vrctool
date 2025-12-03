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
                .id(selectedCategory)   // IDをつけることで、タブが変わるたびにWorldListViewの状態をリセットする
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle("Worlds")
            .onChange(of: selectedCategory) { _ in
                resetAndFetch()
            }
            .onAppear {
                if worlds.isEmpty && selectedCategory != .search {
                    resetAndFetch()
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
    
    func resetAndFetch(searchQuery: String? = nil) {
        self.worlds = []
        self.offset = 0
        self.hasMoreData = true
        self.isLoading = true

        if let query = searchQuery {
            fetchData(isLoadMore: false, searchQuery: query)
        } else {
            fetchData(isLoadMore: false, searchQuery: nil)
        }
    }

    func loadMoreData() {
        guard hasMoreData && !isLoading else { return }
        fetchData(isLoadMore: true)
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
        } else {
            NetworkManager.fetchAll(endpoint: selectedCategory.apiPath) { (result: Result<[World], Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let allWorlds):
                        self.worlds = allWorlds
                        self.hasMoreData = false
                        self.offset = allWorlds.count
                    case .failure(let error):
                        print("FetchAll Error: \(error)")
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
