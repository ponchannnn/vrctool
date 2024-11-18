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
    let dateJoined: String
    let developerType: String
    let displayName: String
    let friendKey: String
    let friendRequestStatus: String?
    let id: String
    let instanceId: String
    let isFriend: Bool
    let lastActivity: String
    let lastLogin: String
    let lastPlatform: String
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

let mockUser = User(
    ageVerificationStatus: "hidden",
    allowAvatarCopying: true,
    badges: [
        Badge(
            badgeDescription: "Supports VRChat through VRC+",
            badgeId: "bdg_754f9935-0f97-49d8-b857-95afb9b673fa",
            badgeImageUrl: "https://assets.vrchat.com/badges/fa/bdgai_8c9cf371-ffd2-4177-9894-1093e2e34bf7.png",
            badgeName: "Supporter",
            showcased: true
        ),
        Badge(
            badgeDescription: "Supported VRChat through VRC+ when it first launched",
            badgeId: "bdg_a60e514a-8cb7-4702-8f24-2786992be1a8",
            badgeImageUrl: "https://assets.vrchat.com/badges/a8/bdgai_c51b0dc0-56fb-4e20-bfd5-48db74e6a059.png",
            badgeName: "Early Supporter",
            showcased: true
        )
    ],
    bio: "普段はBlenderやUnityをしています。\nBoothでの販売やVRC脳波技術集会の主催もしています。\n現在は語学の勉強も少しずつ始めてます。VR技術者認定試験合格しました！\n22時以降によく出現します。\nWorld巡りで一人でいるときもあるので\nその時は遠慮なく是非来てくださると嬉しいです。\n\n［Link］\nMisskey․io˸ ＠spis\nBluesky˸ ＠spis․bsky․social\nBooth˸ https˸⁄⁄spis․booth․pm⁄",
    bioLinks: [
        "https://misskey.io/@spis",
        "https://bsky.app/profile/spis.bsky.social"
    ],
    currentAvatarImageUrl: "https://api.vrchat.cloud/api/1/file/file_0e8c4e32-7444-44ea-ade4-313c010d4bae/1/file",
    currentAvatarTags: [],
    currentAvatarThumbnailImageUrl: "https://api.vrchat.cloud/api/1/image/file_0e8c4e32-7444-44ea-ade4-313c010d4bae/1/256",
    dateJoined: "2020-08-31",
    developerType: "none",
    displayName: "Spis（スピス）",
    friendKey: "",
    friendRequestStatus: nil,
    id: "usr_bd77ec85-06f6-4f88-9978-4c16dc13a483",
    instanceId: "offline",
    isFriend: false,
    lastActivity: "",
    lastLogin: "",
    lastPlatform: "standalonewindows",
    location: "offline",
    note: "",
    platform: "offline",
    profilePicOverride: "https://api.vrchat.cloud/api/1/file/file_6539ee0d-5e3d-4cdd-acb4-6644883ea8bd/1",
    profilePicOverrideThumbnail: "https://api.vrchat.cloud/api/1/image/file_6539ee0d-5e3d-4cdd-acb4-6644883ea8bd/1/512",
    pronouns: "",
    state: "offline",
    status: "active",
    statusDescription: "",
    tags: [
        "language_jpn",
        "system_world_access",
        "system_avatar_access",
        "system_trust_basic",
        "system_feedback_access",
        "system_trust_known",
        "system_early_adopter",
        "system_trust_trusted",
        "system_trust_veteran",
        "system_supporter"
    ],
    userIcon: "https://api.vrchat.cloud/api/1/file/file_c6796fdf-105b-46d2-b205-e20468c48bff/1",
    worldId: "offline"
)

struct UserView: View {
    @State private var user: User = mockUser

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // プロフィール画像
                    if let imageUrl = URL(string: user.profilePicOverride) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    // Bio
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bio")
                        .font(.headline)
                        Text(user.bio)
                        .font(.body)
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

                        ForEach(user.badges) { badge in
                            HStack {
                                if let badgeUrl = URL(string: badge.badgeImageUrl) {
                                    AsyncImage(url: badgeUrl) { image in
                                        image
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                                VStack(alignment: .leading) {
                                    Text(badge.badgeName)
                                        .font(.headline)
                                    Text(badge.badgeDescription)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
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
                        Text("Joined: \(user.dateJoined)")
                        Text("Last Platform: \(user.lastPlatform)")
                        Text("Status: \(user.status)")
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
            }
            .navigationTitle(user.displayName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    UserView()
}
