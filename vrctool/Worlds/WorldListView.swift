import Foundation
import SwiftUI

enum WorldSortOption: String, CaseIterable, Identifiable {
    case updatedNewest = "更新日 (新しい順)"
    case updatedOldest = "更新日 (古い順)"
    case createdNewest = "作成日 (新しい順)"
    case createdOldest = "作成日 (古い順)"
    case popularity    = "人気順 (Visits)"
    case favorites     = "お気に入り数順"
    case capacity      = "定員数順"
    case nameAsc       = "名前 (A-Z)"
    
    var id: String { rawValue }
}

enum SearchConfig {
    case localFilter
    case apiSearch((String) -> Void)
}

struct UnityPackage: Codable {
    let assetUrl: String?
    let assetVersion: Int
    let created_at: String?
    let id: String
    let platform: String
    let unitySortNumber: Int?
    let unityVersion: String
    let performanceRating: String?
}

struct WorldListView: View {
    let worlds: [World]
    let isLoading: Bool
    
    let searchConfig: SearchConfig
    // リフレッシュ操作を親に委譲するためのクロージャー
    let onRefresh: () async -> Void
    let onLoadMore: () -> Void
    let hasMoreData: Bool
    var emptyMessage: String = "No Worlds Found"
    
    @State private var searchText = ""
    @State private var sortOption: WorldSortOption = .updatedNewest
    
    var displayedWorlds: [World] {
        switch searchConfig {
        case .apiSearch:
            return worlds
            
        case .localFilter:
            let filtered: [World]
            if searchText.isEmpty {
                filtered = worlds
            } else {
                filtered = worlds.filter { world in
                    world.safeName.localizedCaseInsensitiveContains(searchText) ||
                    world.safeAuthorName.localizedCaseInsensitiveContains(searchText)
                }
            }
            
            return filtered.sorted { w1, w2 in
                switch sortOption {
                case .updatedNewest:
                    return w1.updated_at ?? "" > w2.updated_at ?? ""
                case .updatedOldest:
                    return w1.updated_at ?? "" < w2.updated_at ?? ""
                case .createdNewest:
                    return w1.created_at ?? "" > w2.created_at ?? ""
                case .createdOldest:
                    return w1.created_at ?? "" < w2.created_at ?? ""
                case .popularity:
                    return (w1.safeVisits) > (w2.safeVisits)
                case .favorites:
                    return (w1.safeFavorites) > (w2.safeFavorites)
                case .capacity:
                    return w1.safeCapacity > w2.safeCapacity
                case .nameAsc:
                    return w1.safeName < w2.safeName
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if isLoading && displayedWorlds.isEmpty {
                ProgressView("Loading Worlds...")
            } else if displayedWorlds.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "globe.asia.australia.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text(emptyMessage)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(displayedWorlds) { world in
                            if let worldId = world.id {
                                NavigationLink(destination: WorldView(worldId: worldId)) {
                                    WorldCardView(world: world)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        if hasMoreData {
                            ProgressView()
                                .padding()
                                .onAppear {
                                    onLoadMore()
                                }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await onRefresh()
                }
            }
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search")
        .onSubmit(of: .search) {
            if case .apiSearch(let performSearch) = searchConfig {
                performSearch(searchText)
            }
        }
        .toolbar {
            if case .localFilter = searchConfig {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $sortOption) {
                            ForEach(WorldSortOption.allCases) { option in
                                if option == sortOption {
                                    Label(option.rawValue, systemImage: "checkmark")
                                        .tag(option)
                                } else {
                                    Text(option.rawValue)
                                        .tag(option)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.system(size: 16))
                    }
                }
            }
        }
    }
}

// MARK: - Components

// ワールドカード（リストの1行分）
struct WorldCardView: View {
    let world: World
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // サムネイル画像
            ZStack(alignment: .topTrailing) {
                if let url = URL(string: world.displayImage) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 180)
                    }
                }
                
                // 人数バッジ (Activeの場合)
                if let occupants = world.occupants {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption2)
                        Text("\(occupants)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                    .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(world.safeName)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text("by \(world.safeAuthorName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Divider()
                
                HStack {
                    Label(world.formatNumber(world.favorites), systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    Spacer()
                    Label(world.formatNumber(world.visits), systemImage: "figure.walk")
                        .foregroundColor(.purple)
                    Spacer()
                    Label("\(world.safeCapacity)", systemImage: "person.3.fill")
                        .foregroundColor(.blue)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

//#Preview {
//    WorldListView()
//}
