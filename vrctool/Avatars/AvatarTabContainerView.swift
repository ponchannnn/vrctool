//
//  AvatarTabContainerView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/12/07.
//

import SwiftUI

enum AvatarListTab: String, CaseIterable, Identifiable {
    case mine = "Mine"
    case favorites = "Favorites"
    var id: String { rawValue }
}

struct AvatarTabContainerView: View {
    // データ
    @State private var myAvatars: [Avatar] = []
    @State private var searchResults: [Avatar] = []
    @State private var favoriteAvatars: [Avatar] = []
    
    // お気に入りグループ
    @State private var favoriteGroups: [FavoriteGroup] = []
    @State private var selectedGroupTag: String? = nil
    @State private var currentGroupName: String = "Select Group"
    @State private var loadedGroupTag: String? = nil
    
    // 状態
    @State private var isLoading = false
    @AppStorage("selectedAvatarTab") private var selectedTab: AvatarListTab = .mine
    
    // 検索用
    @State private var apiSearchText = ""
    @State private var searchOffset = 0
    @State private var searchHasMore = true
    let limit = 100
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Picker
                Picker("Mode", selection: $selectedTab) {
                    ForEach(AvatarListTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(uiColor: .systemBackground))
                .onChange(of: selectedTab) { val in handleTabChange(tab: val) }
                
                Group {
                    switch selectedTab {
                    case .mine:
                        AvatarListView(
                            avatars: myAvatars,
                            isLoading: isLoading,
                            mode: .local,
                            onLoadMore: { },
                            hasMoreData: false,
                            onRefresh: { await loadMyAvatars() }
                        )
                        
                    case .favorites:
                        if selectedGroupTag == nil {
                            VStack {
                                Image(systemName: "arrow.up.right.circle")
                                    .font(.system(size: 50)).foregroundColor(.secondary)
                                Text("グループを選択してください").foregroundColor(.secondary).padding()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            AvatarListView(
                                avatars: favoriteAvatars,
                                isLoading: isLoading,
                                mode: .local,
                                onLoadMore: { },
                                hasMoreData: false,
                                onRefresh: { await refreshFavorites() }
                            )
                        }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if selectedTab == .favorites {
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
                                        loadFavorites(in: group)
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
            .onAppear {
                if favoriteGroups.isEmpty && selectedTab == .favorites {
                    loadFavoriteGroups()
                }
            }
        }
    }
    
    var navigationTitle: String {
        switch selectedTab {
        case .mine: return "My Avatars"
        case .favorites: return ""
        }
    }
    
    // MARK: - Logic
    
    func handleTabChange(tab: AvatarListTab) {
        isLoading = false
        
        switch tab {
        case .mine:
            if myAvatars.isEmpty { Task { await loadMyAvatars() } }
        case .favorites:
            if favoriteGroups.isEmpty { loadFavoriteGroups() }
            else if let tag = selectedGroupTag, let group = favoriteGroups.first(where: { $0.name == tag }) {
                if favoriteAvatars.isEmpty && loadedGroupTag != tag { loadFavorites(in: group) }
            }
        }
    }
    
    // My Avatars (user=me)
    func loadMyAvatars() async {
        await MainActor.run { isLoading = true }
        await withCheckedContinuation { continuation in
            // user=me で自分のアバターを取得
            let query = [URLQueryItem(name: "user", value: "me"), URLQueryItem(name: "releaseStatus", value: "all")]
            // 全件取得
            NetworkManager.fetchAll(endpoint: "avatars", baseQueryItems: query) { (result: Result<[Avatar], Error>) in
                DispatchQueue.main.async {
                    if case .success(let data) = result { self.myAvatars = data }
                    self.isLoading = false
                    continuation.resume()
                }
            }
        }
    }
    
    // Favorites
    func loadFavoriteGroups() {
        isLoading = true
        NetworkManager.request(endpoint: "favorite/groups") { (result: Result<[FavoriteGroup], Error>) in
            DispatchQueue.main.async {
                if case .success(let groups) = result {
                    self.favoriteGroups = groups.filter { $0.type == "avatar" } // avatarタイプのみ
                    if let first = self.favoriteGroups.first {
                        self.loadFavorites(in: first)
                    } else { self.isLoading = false }
                } else { self.isLoading = false }
            }
        }
    }
    
    func loadFavorites(in group: FavoriteGroup) {
        self.selectedGroupTag = group.name
        self.currentGroupName = group.label
        self.isLoading = true
        self.favoriteAvatars = []
        
        let query = [URLQueryItem(name: "tag", value: group.name)]
        
        NetworkManager.fetchAll(endpoint: "avatars/favorites", baseQueryItems: query) { (result: Result<[Avatar], Error>) in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    self.favoriteAvatars = data
                    self.loadedGroupTag = group.name
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
}

#Preview {
    AvatarTabContainerView()
}
