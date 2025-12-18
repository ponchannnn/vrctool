//
//  AvatarListView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/12/07.
//
import SwiftUI

enum AvatarSortOption: String, CaseIterable, Identifiable {
    case updatedNewest = "更新日 (新しい順)"
    case updatedOldest = "更新日 (古い順)"
    case createdNewest = "作成日 (新しい順)"
    case createdOldest = "作成日 (古い順)"
    case nameAsc       = "名前 (A-Z)"
    var id: String { rawValue }
}

struct AvatarFilter: Equatable {
    var platformPC: Bool = false
    var platformAndroid: Bool = false
    var platformiOS: Bool = false
    var publicOnly: Bool = false
    
    var performanceRanks: Set<String> = []
    
    func matches(_ avatar: Avatar) -> Bool {
        // 公開設定フィルタ
        if publicOnly && avatar.releaseStatus != "public" { return false }
        
        // プラットフォーム & パフォーマンス複合フィルタ
        
        // ユーザーがチェックを入れたプラットフォームのリストを作成
        var targetPlatforms: [String] = []
        if platformPC { targetPlatforms.append("standalonewindows") }
        if platformAndroid { targetPlatforms.append("android") }
        if platformiOS { targetPlatforms.append("ios") }
        
        if targetPlatforms.isEmpty {
            targetPlatforms = ["standalonewindows", "android", "ios"]
        }
        
        for platform in targetPlatforms {
            // そのプラットフォームのパッケージを持っているか？
            if let rating = avatar.getPerformance(on: platform) {
                
                // ランク指定がない場合 -> そのプラットフォームに対応していればOK
                if performanceRanks.isEmpty {
                    return true
                }
                
                // ランク指定がある場合 -> そのプラットフォームのランクが指定に含まれていればOK
                if performanceRanks.contains(rating) {
                    return true
                }
            }
        }
        
        return false
    }
}

enum AvatarListMode {
    case local
    case api(onSearch: (String) -> Void)
}

struct AvatarListView: View {
    let avatars: [Avatar]
    let isLoading: Bool
    let mode: AvatarListMode
    
    let onLoadMore: () -> Void
    let hasMoreData: Bool
    let onRefresh: () async -> Void
    
    var emptyMessage: String = "No avatars found."
    
    @State private var searchText = ""
    
    @State private var filter = AvatarFilter()
    @State private var sortOption: AvatarSortOption = .updatedNewest

    @State private var showFilterSheet = false
    
    var displayedAvatars: [Avatar] {
        var result = avatars
        
        // ローカルモード時のフィルタリング
        if case .local = mode {
            if !searchText.isEmpty {
                result = result.filter { $0.safeName.localizedCaseInsensitiveContains(searchText) }
            }
            result = result.filter { filter.matches($0) }
            
            return result.sorted { w1, w2 in
                switch sortOption {
                case .updatedNewest:
                    return w1.updated_at > w2.updated_at
                case .updatedOldest:
                    return w1.updated_at < w2.updated_at
                case .createdNewest:
                    return w1.created_at > w2.created_at
                case .createdOldest:
                    return w1.created_at < w2.created_at
                case .nameAsc:
                    return w1.name < w2.name
                }
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack {
            if isLoading && displayedAvatars.isEmpty {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemBackground))
            } else if displayedAvatars.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.fill.viewfinder")
                        .font(.system(size: 60)).foregroundColor(.gray.opacity(0.5))
                    Text(emptyMessage).font(.headline).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                        ForEach(displayedAvatars) { avatar in
                            NavigationLink(destination: AvatarView(avatar: avatar)) {
                                AvatarCardView(avatar: avatar)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .refreshable { await onRefresh() }
            }
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search Avatars")
        .onSubmit(of: .search) {
            if case .api(let onSearch) = mode { onSearch(searchText) }
        }
        .sheet(isPresented: $showFilterSheet) {
            AvatarFilterSheet(filter: $filter)
        }
        // ツールバー (ローカルモード時のみフィルタ表示)
        .toolbar {
            if case .local = mode {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section {
                            Picker("Sort", selection: $sortOption) {
                                ForEach(AvatarSortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        }
                        
                        Section {
                            Button {
                                showFilterSheet = true
                            } label: {
                                let isActive = filter != AvatarFilter()
                                Label("絞り込み", systemImage: isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18))
                    }
                }
            }
        }
    }
}

struct OldAvatarCardView: View {
    let avatar: Avatar
    
    var body: some View {
        HStack(spacing: 12) {
            // サムネイル
            ZStack(alignment: .topTrailing) {
                if let url = URL(string: avatar.displayImageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 70, height: 70)
                    .cornerRadius(8)
                } else {
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 70, height: 70).cornerRadius(8)
                }
                
                // Public/Privateインジケータ
                Circle()
                    .fill(avatar.statusColor)
                    .frame(width: 10, height: 10)
                    .offset(x: 3, y: -3)
            }
            
            // 情報
            VStack(alignment: .leading, spacing: 4) {
                Text(avatar.safeName)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text("by \(avatar.safeAuthorName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // プラットフォームバッジ
                HStack(spacing: 6) {
                    if avatar.hasPC {
                        Text("PC").font(.system(size: 9, weight: .bold))
                            .padding(3).background(Color.blue.opacity(0.2)).foregroundColor(.blue).cornerRadius(4)
                    }
                    if avatar.hasQuest {
                        Text("Quest").font(.system(size: 9, weight: .bold))
                            .padding(3).background(Color.green.opacity(0.2)).foregroundColor(.green).cornerRadius(4)
                    }
                    if avatar.hasMobile {
                        Text("Mobile").font(.system(size: 9, weight: .bold))
                            .padding(3).background(Color.orange.opacity(0.2)).foregroundColor(.orange).cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AvatarCardView: View {
    let avatar: Avatar
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. 画像エリア
            ZStack(alignment: .topTrailing) {
                if let url = URL(string: avatar.displayImageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 110)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 110)
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 110)
                }
                if let rank = displayRank {
                    PerformanceBadge(rank: rank)
                        .frame(width: 24, height: 24)
                        .padding(6)
                }
            }
            
            // 2. 情報エリア
            VStack(alignment: .leading, spacing: 4) {
                Text(avatar.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(avatar.authorName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // PC / Quest アイコン
                HStack(spacing: 4) {
                    if avatar.hasPC {
                        Text("PC").font(.system(size: 8)).padding(2)
                            .background(Color.blue.opacity(0.1)).cornerRadius(3)
                    }
                    if avatar.hasQuest {
                        Text("Quest").font(.system(size: 8)).padding(2)
                            .background(Color.green.opacity(0.1)).cornerRadius(3)
                    }
                    if avatar.hasMobile {
                        Text("Mobile").font(.system(size: 8)).padding(2)
                            .background(Color.orange.opacity(0.1)).cornerRadius(3)
                    }
                }
            }
            .padding(8)
            .frame(width: 150, alignment: .leading)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    var displayRank: PerformanceRank? {
            // PC -> Quest -> Mobile の優先順位でランクを表示
        let pc = avatar.getPerformanceRank(on: "standalonewindows")
        if pc.isValid { return pc }
        
        let android = avatar.getPerformanceRank(on: "android")
        if android.isValid { return android }
        
        let ios = avatar.getPerformanceRank(on: "ios")
        if ios.isValid { return ios }
            return nil
        }
}

struct PerformanceBadge: View {
    let rank: PerformanceRank
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.3))
            
            Circle()
                .stroke(rank.color, lineWidth: 3)
                .padding(2)
            
            Circle()
                .fill(rank.color)
                .scaleEffect(0.4)
            
            // Text(rank.prefix(1)).font(.system(size: 8)).foregroundColor(.white)
        }
        .shadow(radius: 2)
    }
}

struct AvatarFilterSheet: View {
    @Binding var filter: AvatarFilter
    @Environment(\.dismiss) var dismiss
    
    let targetRanks: [PerformanceRank] = [.excellent, .good, .medium, .poor, .veryPoor]
    
    var body: some View {
        NavigationStack {
            Form {
                // プラットフォーム
                Section("Target Platform") {
                    Toggle("PC (Windows)", isOn: $filter.platformPC)
                    Toggle("Quest (Android)", isOn: $filter.platformAndroid)
                    Toggle("Mobile (iOS)", isOn: $filter.platformiOS)
                }
                
                // パフォーマンスランク
                Section("Performance Rank") {
                    ForEach(targetRanks) { rank in
                        rankToggle(rank: rank)
                    }
                }
                
                // その他
                Section {
                    Toggle("Public Only", isOn: $filter.publicOnly)
                    
                    Button(role: .destructive) {
                        filter = AvatarFilter()
                    } label: {
                        Text("Reset Filters")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Filter Avatars")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // ランク選択用の行コンポーネント
    func rankToggle(rank: PerformanceRank) -> some View {
        let key = rank.rawValue

        return Button {
            if filter.performanceRanks.contains(key) {
                filter.performanceRanks.remove(key)
            } else {
                filter.performanceRanks.insert(key)
            }
        } label: {
            HStack {
                // 色付きの丸でランクを表現
                Circle()
                    .fill(rank.color)
                    .frame(width: 12, height: 12)
                
                Text(rank.rawValue)
                    .foregroundColor(.primary)
                Spacer()
                
                if filter.performanceRanks.contains(key) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }
            }
        }
    }
}
