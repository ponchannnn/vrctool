//
//  AvatarView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/12/07.
//

import Foundation
import SwiftUI

struct Avatar: Codable, Identifiable {
    let acknowledgements: String?
    let assetUrl: String?
    let assetUrlObject: [String: String]?
    let authorId: String
    let authorName: String
    let created_at: String
    let description: String?
    let featured: Bool?
    let highestPrice: Int?
    let id: String
    let imageUrl: String?
    let listingDate: String?
    let lock: Bool?
    let lowestPrice: Int?
    let name: String
    let performance: AvatarPerformance?
    let productId: String?
    let publishedListings: [PublishedListing]?
    let releaseStatus: String
    let searchable: Bool
    let styles: AvatarStyles
    let tags: [String]?
    let thumbnailImageUrl: String?
    let unityPackageUrl: String
    let unityPackageUrlObject: UnityPackageUrlObject?
    let unityPackages: [UnityPackage]?
    let updated_at: String
    let version: Int?
    
    var safeName: String { name }
    var safeAuthorName: String { authorName }
    var safeDescription: String { description ?? "" }
    
    var displayImageUrl: String {
        return thumbnailImageUrl ?? imageUrl ?? ""
    }
    
    var canBeFallback: Bool {
        let hasFallbackTag = tags?.contains("author_tag_fallback") ?? false
        var isPerformanceOK = false
        
        // Quest対応していて、かつランクがGood以上か？
        if !hasFallbackTag {
            guard let questRank = getPerformance(on: "android")?.lowercased() else { return false }
            isPerformanceOK = (questRank == "excellent" || questRank == "good")
        }
        
        return isPerformanceOK
    }
    
    var statusColor: Color {
        switch releaseStatus {
        case "public": return .green
        case "private": return .red
        default: return .orange
        }
    }
    
    func getPerformanceRank(on platform: String) -> PerformanceRank {
        let rankString = getPerformance(on: platform)
        return PerformanceRank.from(rankString)
    }
    
    func getPerformance(on platform: String) -> String? {
        // トップレベルの performance オブジェクトを確認
        if let perf = performance {
            switch platform {
            case "standalonewindows":
                if let rank = perf.standalonewindows, rank != "None" { return rank }
            case "android":
                if let rank = perf.android, rank != "None" { return rank }
            case "ios":
                if let rank = perf.ios, rank != "None" { return rank }
            default:
                break
            }
        }
        
        guard let packages = unityPackages else { return nil }
        
        // 指定プラットフォームのパッケージを抽出
        let targetPackages = packages.filter { $0.platform == platform }
        
        // 上から順に見ていき、"None" ではない有効なランクがあればそれを返す
        let sortedPackages = targetPackages.sorted {
            ($0.created_at ?? "") > ($1.created_at ?? "")
        }
        for package in sortedPackages {
            if let rating = package.performanceRating,
               !rating.isEmpty,
               rating.lowercased() != "none" {
                return rating
            }
        }
        return nil
    }
    
    var hasPC: Bool { getPerformanceRank(on: "standalonewindows").isValid }
    var hasQuest: Bool { getPerformanceRank(on: "android").isValid }
    var hasMobile: Bool { getPerformanceRank(on: "ios").isValid }
}

enum PerformanceRank: String, CaseIterable, Identifiable {
    case excellent = "Excellent"
    case good = "Good"
    case medium = "Medium"
    case poor = "Poor"
    case veryPoor = "VeryPoor"
    case none = "None"
    case unknown = "Unknown"

    var id: String { rawValue }

    // APIの文字列から安全に変換
    static func from(_ rawString: String?) -> PerformanceRank {
        guard let str = rawString else { return .unknown }
        
        let normalized = str.lowercased().replacingOccurrences(of: " ", with: "")
        
        switch normalized {
        case "excellent": return .excellent
        case "good": return .good
        case "medium": return .medium
        case "poor": return .poor
        case "verypoor": return .veryPoor
        case "none": return .none
        default: return .unknown
        }
    }
    
    var isValid: Bool {
            return self != .unknown && self != .none
        }

    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .green
        case .medium: return .orange
        case .poor: return .pink
        case .veryPoor: return .red
        case .none, .unknown: return .gray
        }
    }
}

// パフォーマンス情報
struct AvatarPerformance: Codable {
    let android: String?
    let androidSort: Int?
    let ios: String?
    let iosSort: Int?
    let standalonewindows: String?
    let standaloneWindowsSort: Int?
    
    enum CodingKeys: String, CodingKey {
        case android
        case ios
        case standalonewindows
        
        // ハイフンが含まれるキーを、Swiftの変数名にマッピング
        case iosSort = "ios-sort"
        case androidSort = "android-sort"
        case standaloneWindowsSort = "standalonewindows-sort"
    }
}

// 公開リスト情報
struct PublishedListing: Codable {
    let description: String
    let displayName: String
    let imageId: String
    let listingId: String
    let listingType: String
    let priceTokens: Int
}

struct AvatarStyles: Codable {
    let primary: String?
    let secondary: String?
    let supplementary: [String]?
}

struct UnityPackageUrlObject: Codable {
    let unityPackageUrl: String?
}

struct AvatarView: View {
    // データ保持
    @State var avatar: Avatar?
    let avatarId: String?
    
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    // アクション結果用
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // イニシャライザ
    init(avatarId: String) {
        self.avatarId = avatarId
        self._avatar = State(initialValue: nil)
    }
    
    init(avatar: Avatar) {
        self.avatarId = avatar.id
        self._avatar = State(initialValue: avatar)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let avatar = avatar {
                    VStack(spacing: 20) {
                        // 1. ヘッダー
                        headerSection(avatar: avatar)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // パフォーマンス詳細
                            performanceSection(avatar: avatar)
                            
                            Divider()
                            
                            // 説明文
                            descriptionSection(avatar: avatar)
                            
                            // 詳細リスト
                            detailsListSection(avatar: avatar)
                            
                            // タグ
                            if let tags = avatar.tags, !tags.isEmpty {
                                tagsSection(tags: tags)
                            }
                        }
                        .padding()
                    }
                } else if isLoading {
                    ProgressView("Loading Avatar...")
                        .padding(.top, 100)
                } else {
                    Text("Failed to load avatar.")
                        .foregroundColor(.secondary)
                        .padding(.top, 100)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem (placement: .topBarTrailing) {
                    Menu {
                        Section {
                            Button(action: selectAvatar) {
                                Label("このアバターに着替える", systemImage: "tshirt")
                            }
                            
                            if let avatar = avatar {
                                Button(action: selectFallbackAvatar) {
                                    if avatar.canBeFallback {
                                        Label("フォールバックに設定", systemImage: "figure.stand")
                                    } else {
                                        Label("フォールバック不可 (Quest Good以上が必要)", systemImage: "xmark.circle")
                                    }
                                }
                                .disabled(!avatar.canBeFallback)
                            }
                        }
                        
                        Section {
                            if let avatar = avatar {
                                let url = URL(string: "https://vrchat.com/home/avatar/\(avatar.id)")!
                                Link(destination: url) {
                                    Label("Webで開く", systemImage: "safari")
                                }
                            }
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18))
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .onAppear {
                if avatarId != nil && avatar == nil {
                    fetchData()
                }
            }
            .refreshable {
                fetchData()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Logic
    
    func fetchData() {
        guard let id = avatarId else { return }
        isLoading = true
        
        NetworkManager.request(endpoint: "avatars/\(id)") { (result: Result<Avatar, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.avatar = data
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }
    
    func selectAvatar() {
        guard let id = avatar?.id else { return }
        
        NetworkManager.action(endpoint: "avatars/\(id)/select", method: "PUT") { (result: Result<String, Error>) in
            DispatchQueue.main.async {
                if case .success = result {
                    self.alertMessage = "アバターを変更しました"
                } else {
                    self.alertMessage = "変更に失敗しました"
                }
                self.showAlert = true
            }
        }
    }
    
    func selectFallbackAvatar() {
        guard let id = avatar?.id else { return }
        
        NetworkManager.action(endpoint: "avatars/\(id)/selectFallback", method: "PUT") { (result: Result<String, Error>) in
            DispatchQueue.main.async {
                if case .success = result {
                    self.alertMessage = "フォールバックアバターを変更しました"
                } else {
                    self.alertMessage = "変更に失敗しました"
                }
                self.showAlert = true
            }
        }
    }
    
    // MARK: - Subviews
    
    func headerSection(avatar: Avatar) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if let url = URL(string: avatar.displayImageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 350)
                            .clipped()
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.3))
                    }
                }
                
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(avatar.safeName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .shadow(radius: 4)
                        
                        Text("by \(avatar.safeAuthorName)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        HStack {
                            // 公開ステータス
                            Text(avatar.releaseStatus.capitalized)
                                .font(.caption).bold()
                                .padding(6)
                                .background(avatar.statusColor)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            
                            // Public Listにある場合
                            if avatar.publishedListings?.isEmpty == false {
                                Text("For Sale")
                                    .font(.caption).bold()
                                    .padding(6)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(height: 350)
    }
    
    // パフォーマンス詳細表示
    func performanceSection(avatar: Avatar) -> some View {
        HStack(spacing: 20) {
            perfBadge(platform: "PC", rank: avatar.getPerformanceRank(on: "standalonewindows"))
            perfBadge(platform: "Quest", rank: avatar.getPerformanceRank(on: "android"))
            perfBadge(platform: "Mobile", rank: avatar.getPerformanceRank(on: "ios"))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    func perfBadge(platform: String, rank: PerformanceRank?) -> some View {
        VStack(spacing: 8) {
            Text(platform).font(.caption).bold()
            
            if let rank = rank {
                PerformanceIcon(rank: rank)
                    .frame(width: 40, height: 40)
                Text(rank.rawValue).font(.caption2).foregroundColor(rank.color)
            } else {
                Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .overlay(Text("-").foregroundColor(.gray))
                Text("N/A").font(.caption2).foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    func descriptionSection(avatar: Avatar) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description").font(.headline)
            
            if !avatar.safeDescription.isEmpty {
                Text(avatar.safeDescription)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            } else {
                Text("No description.").font(.caption).foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    func detailsListSection(avatar: Avatar) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Author Link
            NavigationLink(destination: UserView(userId: avatar.authorId)) {
                HStack {
                    Text("Author").foregroundColor(.secondary)
                    Spacer()
                    Text(avatar.safeAuthorName).fontWeight(.bold).foregroundColor(.blue)
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                }
                .padding()
            }
            
            Divider()
            DetailRow(key: "Version", value: "\(avatar.version ?? 0)")
            Divider()
            DetailRow(key: "Updated", value: String(avatar.updated_at.prefix(10)))
            Divider()
            DetailRow(key: "Created", value: String(avatar.created_at.prefix(10)))
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    func tagsSection(tags: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags").font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(6)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(6)
                }
            }
        }
    }
    
    // MARK: - Helpers
}

struct PerformanceIcon: View {
    let rank: PerformanceRank
    
    var body: some View {
        ZStack {
            // 外枠
            Circle()
                .stroke(rank.color, lineWidth: 3)
            
            // 中身
            Circle()
                .fill(rank.color.opacity(0.2))
            
            // 中心点
            Circle()
                .fill(rank.color)
                .frame(width: 10, height: 10)
        }
    }
}
