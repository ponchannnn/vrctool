import SwiftUI

struct Badge: Codable, Identifiable {
    let id = UUID()
    let badgeDescription: String
    let badgeId: String
    let badgeImageUrl: String
    let badgeName: String
    let showcased: Bool
}

struct User: Codable {
    let ageVerificationStatus: String
    let allowAvatarCopying: Bool
    let badges: [Badge]
    let bio: String
    let bioLinks: [String]
    let currentAvatarImageUrl: String
    let currentAvatarTags: [String]
    let currentAvatarThumbnailImageUrl: String
    let date_joined: String
    let developerType: String
    let displayName: String
    let friendKey: String
    let friendRequestStatus: String?
    let id: String
    let instanceId: String
    let isFriend: Bool
    let last_activity: String
    let last_login: String
    let last_platform: String
    let location: String
    let note: String
    let platform: String
    let profilePicOverride: String
    let profilePicOverrideThumbnail: String
    let pronouns: String
    let state: String
    let status: String
    let statusDescription: String
    let tags: [String]
    let userIcon: String
    let worldId: String
}

struct UserView: View {
    var userId: String

    @State private var user: User? = nil
    @State private var selectedBadge: Badge? = nil
    @State private var showModal = false
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var scale: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView()
                    .onAppear {
                        fetchUser(userId: userId)
                    }
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
            } else if let user = user {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        // プロフィール画像
                        if !user.profilePicOverride.isEmpty {
                            TabView {
                                VStack {
                                    if let profilePicUrl = URL(string: user.profilePicOverride) {
                                        AsyncImage(url: profilePicUrl) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: .infinity)
                                                .scaleEffect(scale)
                                                .gesture(
                                                    MagnificationGesture()
                                                        .onChanged { value in
                                                            scale = value
                                                        }
                                                        .onEnded { _ in
                                                            scale = 1.0
                                                        }
                                                )
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                    Text("カスタムサムネイル")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                VStack {
                                    if let avatarImageUrl = URL(string: user.currentAvatarImageUrl) {
                                        AsyncImage(url: avatarImageUrl) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: .infinity)
                                                .scaleEffect(scale)
                                                .gesture(
                                                    MagnificationGesture()
                                                        .onChanged { value in
                                                            scale = value
                                                        }
                                                        .onEnded { _ in
                                                            scale = 1.0
                                                        }
                                                )
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                    Text("アバターサムネイル")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .frame(height: 300) // スライドの高さを設定
                        } else {
                            VStack {
                                if let avatarImageUrl = URL(string: user.currentAvatarImageUrl) {
                                    AsyncImage(url: avatarImageUrl) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: .infinity)
                                            .scaleEffect(scale)
                                            .gesture(
                                                MagnificationGesture()
                                                    .onChanged { value in
                                                        scale = value
                                                    }
                                                    .onEnded { _ in
                                                        scale = 1.0
                                                    }
                                            )
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                                Text("アバターサムネイル")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Bio
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Bio")
                                .font(.headline)
                            Text(user.bio)
                                .font(.body)
                                .textSelection(.enabled)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        
                        // Bio Links
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(user.bioLinks, id: \.self) { link in
                                Link(link, destination: URL(string: link)!)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        
                        // Badges
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Badges")
                                .font(.headline)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                                ForEach(user.badges) { badge in
                                    if let badgeUrl = URL(string: badge.badgeImageUrl) {
                                        AsyncImage(url: badgeUrl) { image in
                                            image
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .onTapGesture {
                                                    selectedBadge = badge
                                                    showModal.toggle()
                                                }
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        
                        // その他の情報
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Joined: \(user.date_joined)").textSelection(.enabled)
                            Text("Last Platform: \(user.last_platform)").textSelection(.enabled)
                            Text("Status: \(user.status)").textSelection(.enabled)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    }
                    .padding()
                    .sheet(isPresented: $showModal) {
                        if let badge = selectedBadge {
                            BadgeDetailView(badge: badge)
                            .presentationDetents([
                                .fraction(0.2),
                                .medium
                            ])
                        }
                    }
                }
                .navigationTitle(user.displayName)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private func fetchUser(userId: String) {
        NetworkManager.fetchUser(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct BadgeDetailView: View {
    let badge: Badge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let badgeUrl = URL(string: badge.badgeImageUrl) {
                    AsyncImage(url: badgeUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(badge.badgeName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(badge.badgeDescription)
                        .font(.body)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
        )
        .padding()
    }
}

#Preview {
    UserView(userId: "usr_bd77ec85-06f6-4f88-9978-4c16dc13a483")
}
