//
//  UserListView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/12/03.
//

import SwiftUI

// ソート順
enum UserSortOption: String, CaseIterable, Identifiable {
    case lastLoginNewest = "最終ログイン (新しい順)"
    case lastLoginOldest = "最終ログイン (古い順)"
    case nameAsc = "名前 (A-Z)"
    case joinedNewest = "登録日 (新しい順)"
    case joinedOldest = "登録日 (古い順)"
    var id: String { rawValue }
}

// フィルタ条件
struct UserFilter: Equatable {
    var onlyFriends: Bool = false
    var platforms: Set<String> = []
    var statuses: Set<String> = []
    
    func matches(_ user: User) -> Bool {
        if onlyFriends && (user.isFriend != true) { return false }
        if !platforms.isEmpty {
            let p = user.last_platform ?? "unknown"
            if !platforms.contains(p) { return false }
        }
        
        if !statuses.isEmpty {
            let s = (user.location == "offline" || user.location == nil) ? "offline" : (user.status ?? "offline")
            if !statuses.contains(s) { return false }
        }
        return true
    }
}

struct UserListView: View {
    let users: [User]
    let isLoading: Bool
    let mode: UserListMode
    
    let onLoadMore: () -> Void
    let hasMoreData: Bool
    let onRefresh: () async -> Void
        
    @State private var searchText = ""
    @State private var sortOption: UserSortOption = .lastLoginNewest
    @State private var filter = UserFilter()
    @State private var showFilterSheet = false
    
    var processedUsers: [User] {
        var result = users
        
        if case .local = mode, !searchText.isEmpty {
            result = result.filter {
                $0.safeDisplayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        result = result.filter { filter.matches($0) }
        
        return result.sorted { u1, u2 in
            switch sortOption {
            case .nameAsc:
                return u1.safeDisplayName.localizedCaseInsensitiveCompare(u2.safeDisplayName) == .orderedAscending
            case .lastLoginNewest:
                return (u1.last_login ?? "") > (u2.last_login ?? "")
            case .lastLoginOldest:
                return (u1.last_login ?? "") < (u2.last_login ?? "")
            case .joinedNewest:
                return (u1.date_joined ?? "") > (u2.date_joined ?? "")
            case .joinedOldest:
                return (u1.date_joined ?? "") < (u2.date_joined ?? "")
            }
        }
    }

    var body: some View {
        SimpleUserListView(
            users: processedUsers,
            isLoading: isLoading,
            emptyMessage: emptyMessage,
            onRefresh: onRefresh,
            onLoadMore: onLoadMore,
            hasMoreData: hasMoreData
        )
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Users")
        .onSubmit(of: .search) {
            if case .api(let onSearch) = mode {
                onSearch(searchText)
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            UserFilterSheet(filter: $filter)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Menu {
                        Picker("Sort", selection: $sortOption) {
                            ForEach(UserSortOption.allCases) { option in
                                Label(option.rawValue, systemImage: sortOption == option ? "checkmark" : "").tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    
                    Button {
                        showFilterSheet = true
                    } label: {
                        let isActive = !filter.platforms.isEmpty || !filter.statuses.isEmpty || filter.onlyFriends
                        Label("Filter...", systemImage: isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                }
            }
        }
    }
    
    var emptyMessage: String {
        if case .api = mode, searchText.isEmpty {
            return "キーワードを入力して検索"
        }
        return "ユーザーが見つかりません"
    }
    
    func filterToggle(title: String, key: String, set: Binding<Set<String>>) -> some View {
        Button {
            if set.wrappedValue.contains(key) { set.wrappedValue.remove(key) }
            else { set.wrappedValue.insert(key) }
        } label: {
            Label(title, systemImage: set.wrappedValue.contains(key) ? "checkmark.square.fill" : "square")
        }
    }
}

struct UserFilterSheet: View {
    @Binding var filter: UserFilter
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Status") {
                    filterRow(title: "Online (Join Me)", key: "join me", set: $filter.statuses)
                    filterRow(title: "Online (Active)", key: "active", set: $filter.statuses)
                    filterRow(title: "Online (Busy)", key: "busy", set: $filter.statuses)
                    filterRow(title: "Offline", key: "offline", set: $filter.statuses)
                }
                
                Section("Platform") {
                    filterRow(title: "PC", key: "standalonewindows", set: $filter.platforms)
                    filterRow(title: "Quest/Android", key: "android", set: $filter.platforms)
                }
                
                Section {
                    Toggle(isOn: $filter.onlyFriends) {
                        Label("Friends Only", systemImage: "person.2.fill")
                            .foregroundColor(.primary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        filter = UserFilter()
                    } label: {
                        Text("Reset Filters")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Filter Users")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        // ハーフモーダル (iOS 16+)
        .presentationDetents([.medium, .large])
    }
    
    func filterRow(title: String, key: String, set: Binding<Set<String>>) -> some View {
        Button {
            if set.wrappedValue.contains(key) {
                set.wrappedValue.remove(key)
            } else {
                set.wrappedValue.insert(key)
            }
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if set.wrappedValue.contains(key) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }
            }
        }
    }
}
