//
//  WorldView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/12/01.
//
import SwiftUI

struct World: Codable, Identifiable {
    let id: String?
    let name: String?
    let authorId: String?
    let authorName: String?
    let capacity: Int?
    let imageUrl: String?
    let thumbnailImageUrl: String?
    let created_at: String?
    let updated_at: String?
    let instances: [WorldInstanceEntry]?
    
    let occupants: Int?
    let privateOccupants: Int?
    let publicOccupants: Int?
    
    let favoriteId: String?
    let favoriteGroup: String?
    
    let description: String?
    let visits: Int?
    let favorites: Int?
    let popularity: Int?
    let heat: Int?
    let recommendedCapacity: Int?
    let releaseStatus: String?
    let version: Int?
    let organization: String?
    let previewYoutubeId: String?
    let featured: Bool?
    
    let tags: [String]?
    let udonProducts: [String]?
    // let unityPackages: [UnityPackage]?
    
    let labsPublicationDate: String?
    let publicationDate: String?
    
    var safeId: String { id ?? UUID().uuidString }
    var safeName: String { name ?? "Unknown World" }
    var safeAuthorName: String { authorName ?? "Unknown Author" }
    var safeDescription: String { description ?? "" }
    var safeImageUrl: String { imageUrl ?? "" }
    var safeThumbnailImageUrl: String { thumbnailImageUrl ?? safeImageUrl }
    
    var displayImage: String {
        if let thumb = thumbnailImageUrl, !thumb.isEmpty { return thumb }
        return safeImageUrl
    }
    
    var safeCapacity: Int { capacity ?? 0 }
    var safeVisits: Int { visits ?? 0 }
    var safeFavorites: Int { favorites ?? 0 }
    var safeHeat: Int { heat ?? 0 }
    var safeOccupants: Int { occupants ?? 0 }
    
    var safeTags: [String] { tags ?? [] }
    var safeInstances: [WorldInstanceEntry] { instances ?? [] }
    
    // 日付整形
    var formattedUpdatedDate: String {
        formatDate(originalDate: updated_at)
    }
    
    var formattedCreatedDate: String {
        formatDate(originalDate: created_at)
    }

    
    func formatDate (originalDate: String?) -> String {
        guard let dateStr = originalDate else { return "-" }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateStr) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return String(dateStr.prefix(10))
    }
    
    // タグの整形
    var cleanTags: [String] {
        return safeTags.compactMap { tag -> String? in
            if tag.starts(with: "author_tag_") {
                return tag.replacingOccurrences(of: "author_tag_", with: "").capitalized
            }
            if tag.starts(with: "system_") {
                return tag.replacingOccurrences(of: "system_", with: "").replacingOccurrences(of: "_", with: " ").capitalized
            }
            // admin系はnil
            return nil
        }
    }
    
    func formatNumber(_ num: Int?) -> String {
        guard let num = num else { return "-" }
        if num >= 1000000 {
            return String(format: "%.1fM", Double(num)/1000000)
        } else if num >= 1000 {
            return String(format: "%.1fk", Double(num)/1000)
        }
        return "\(num)"
    }
}

struct WorldInstanceEntry: Codable, Identifiable {
    let id: String // instanceId
    let userCount: Int
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.id = try container.decode(String.self)
        self.userCount = try container.decode(Int.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(id)
        try container.encode(userCount)
    }
    
    var region: String {
        if id.contains("region(jp)") { return "jp" }
        if id.contains("region(use)") { return "use" }
        if id.contains("region(usw)") { return "usw" }
        if id.contains("region(eu)") { return "eu" }
        return "us"
    }
    
    var regionFlag: String {
        LanguageHelper.flag(for: region)
    }
    
    // アクセスタイプ (Public, Friends+, etc)
    var typeInfo: (String, Color) {
        if id.contains("hidden") { return ("Friends+", .orange) }
        if id.contains("friends") { return ("Friends", .yellow) }
        if id.contains("private") { return ("Invite", .red) }
        if id.contains("canRequestInvite") { return ("Invite+", .red) }
        if id.contains("groupAccessType") { return ("Group", .purple) }
        return ("Public", .green)
    }
}

struct LanguageHelper {
    static func name(for code: String) -> String {
        let locale = Locale.current
        return locale.localizedString(forLanguageCode: code) ?? code.uppercased()
    }
    
    static func flag(for code: String) -> String {
        let targetLocale = Locale(identifier: code)
        let lang = targetLocale.language.languageCode?.identifier ?? code.lowercased()
        
        switch lang {
        case "ja": return "🇯🇵"
        case "en": return "🇺🇸"
        case "ko": return "🇰🇷"
        case "zh": return "🇨🇳"
        case "de": return "🇩🇪"
        case "fr": return "🇫🇷"
        case "es": return "🇪🇸"
        case "ru": return "🇷🇺"
        case "uk": return "🇺🇦"
        case "pt": return "🇧🇷"
        default: return "🌐"
        }
    }
}

struct WorldView: View {
    @State var world: World?
    let worldId: String?
    
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    init(worldId: String) {
        self.worldId = worldId
        self._world = State(initialValue: nil)
    }
    
    init(world: World) {
        self.worldId = world.id
        self._world = State(initialValue: world)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if let world = world {
                    VStack(spacing: 20) {
                        headerSection(world: world)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            
                            actionButtonsSection(world: world)
                            
                            statsGridSection(world: world)
                            
                            Divider()
                            
                            descriptionSection(world: world)
                            
                            if !world.safeInstances.isEmpty {
                                VStack(alignment: .leading) {
                                    Text("Active Instances (\(world.safeInstances.count))")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(world.safeInstances) { instanceEntry in
                                                let fullLocation = "\(world.safeId):\(instanceEntry.id)"
                                                
                                                NavigationLink(destination: InstanceView(instanceId: fullLocation)) {
                                                    WorldInstanceCard(instance: instanceEntry)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                            
                            detailsListSection(world: world)
                            
                            if let tags = world.tags, !tags.isEmpty {
                                tagsSection(world: world)
                            }
                        }
                        .padding()
                    }
                } else if isLoading {
                    ProgressView("Loading World...")
                        .padding(.top, 100)
                } else {
                    Text("Failed to load world.")
                        .foregroundColor(.secondary)
                        .padding(.top, 100)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if world == nil && worldId != nil {
                    fetchData()
                }
            }
            .refreshable {
                fetchData()
            }
        }
    }
    
    // MARK: - Logic
    
    func fetchData() {
        guard let id = worldId else { return }
        isLoading = true
        
        NetworkManager.request(endpoint: "worlds/\(id)") { (result: Result<World, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.world = data
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Subviews
    
    func headerSection(world: World) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if let url = URL(string: world.displayImage) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.3))
                    }
                }
                
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .center, endPoint: .bottom)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(world.safeName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .shadow(radius: 4)
                        
                        HStack {
                            if let occupants = world.occupants {
                                Label("\(occupants) Online", systemImage: "person.2.fill")
                                    .font(.subheadline).bold()
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.green.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                            
                            if let status = world.releaseStatus {
                                Text(status.capitalized)
                                    .font(.caption).bold()
                                    .padding(6)
                                    .background(status == "public" ? Color.blue : Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(height: 300)
    }
    
    func actionButtonsSection(world: World) -> some View {
        HStack {
            let url = URL(string: "https://vrchat.com/home/world/\(world.safeId)")!
            Link(destination: url) {
                HStack {
                    Image(systemName: "safari")
                    Text("Open in Browser")
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
            
            Button(action: {
                // TODO: Create Instance logic
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New Instance")
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    func statsGridSection(world: World) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            StatCard(title: "Visits", value: world.formatNumber(world.visits), icon: "figure.walk", color: .purple)
            StatCard(title: "Favorites", value: world.formatNumber(world.favorites), icon: "star.fill", color: .yellow)
            StatCard(title: "Capacity", value: "\(world.safeCapacity)", icon: "person.3.fill", color: .blue)
            StatCard(title: "Heat", value: "\(world.heat ?? 0)", icon: "flame.fill", color: .orange)
        }
    }
    
    func descriptionSection(world: World) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description").font(.headline)
            
            if let desc = world.description, !desc.isEmpty {
                Text(desc)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            } else {
                Text("No description provided.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    func detailsListSection(world: World) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let authorId = world.authorId {
                NavigationLink(destination: UserView(userId: authorId)) {
                    HStack {
                        Text("Author").foregroundColor(.secondary)
                        Spacer()
                        Text(world.safeAuthorName)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            
            Divider()
            
            DetailRow(key: "Updated", value: String(world.formattedUpdatedDate.prefix(10)))
            Divider()
            DetailRow(key: "Created", value: String(world.formattedCreatedDate.prefix(10)))
            
            if let labsDate = world.labsPublicationDate, labsDate != "none" {
                Divider()
                DetailRow(key: "Labs Pub", value: String(labsDate.prefix(10)))
            }
            
            if let org = world.organization, org != "vrchat" {
                Divider()
                DetailRow(key: "Organization", value: org)
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    func tagsSection(world: World) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags").font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(world.cleanTags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(6)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(6)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
                
                Spacer()
                
                Text(value)
                    .fontWeight(.bold)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

struct WorldInstanceCard: View {
    let instance: WorldInstanceEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                // リージョン国旗
                Text(instance.regionFlag)
                    .font(.title2)
                
                Spacer()
                
                // アクセスタイプ (Public/Friends+など)
                Text(instance.typeInfo.0)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(instance.typeInfo.1.opacity(0.2))
                    .foregroundColor(instance.typeInfo.1)
                    .cornerRadius(4)
            }
            
            Spacer()
            
            HStack(alignment: .bottom) {
                // 人数
                HStack(spacing: 2) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                    Text("\(instance.userCount)")
                        .font(.headline)
                }
                .foregroundColor(.primary)
                
                Spacer()
                
                // インスタンスIDの一部
                Text(parseShortId(instance.id))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .frame(width: 140, height: 100) // カードサイズ
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
    
    // 例: "82898~region(jp)" -> "82898"
    func parseShortId(_ fullId: String) -> String {
        return fullId.components(separatedBy: "~").first ?? fullId
    }
}

#Preview {
    WorldView(worldId: "wrld_bf51e60f-f372-48b1-a757-88ba8331d926")
}
