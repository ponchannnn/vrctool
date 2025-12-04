//
//  WorldView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/12/01.
//
import SwiftUI

struct World: Codable, Identifiable {
    let id: String
    let name: String
    let authorId: String
    let authorName: String
    let capacity: Int
    let imageUrl: String
    let thumbnailImageUrl: String
    let created_at: String
    let updated_at: String
    
    let occupants: Int?
    
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
    
    var displayImage: String {
            return thumbnailImageUrl.isEmpty ? imageUrl : thumbnailImageUrl
        }
    
    var cleanTags: [String] {
        guard let tags = tags else { return [] }
        return tags.map { tag in
            tag.replacingOccurrences(of: "author_tag_", with: "")
               .replacingOccurrences(of: "system_", with: "")
               .replacingOccurrences(of: "_", with: " ")
               .capitalized
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
                // データがない、または詳細情報(description等)が欠けている可能性がある場合は取得
                // (リストから渡されたWorldは軽量版の可能性があるため、IDがあれば再取得するのが確実ですが、
                // 今回はWorld構造体が統一されたので、nilの場合のみ取得します)
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
                        Text(world.name)
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
            let url = URL(string: "https://vrchat.com/home/world/\(world.id)")!
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
            StatCard(title: "Capacity", value: "\(world.capacity)", icon: "person.3.fill", color: .blue)
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
            NavigationLink(destination: UserView(userId: world.authorId)) {
                HStack {
                    Text("Author").foregroundColor(.secondary)
                    Spacer()
                    Text(world.authorName)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                }
                .padding()
            }
            
            Divider()
            
            DetailRow(key: "Updated", value: String(world.updated_at.prefix(10)))
            Divider()
            DetailRow(key: "Created", value: String(world.created_at.prefix(10)))
            
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

#Preview {
    WorldView(worldId: "wrld_bf51e60f-f372-48b1-a757-88ba8331d926")
}
