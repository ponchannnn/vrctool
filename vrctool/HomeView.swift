//
//  HomeView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2024/03/17.
//

import SwiftUI

struct Friend: Identifiable, Decodable {
    let id: String
    let displayName: String
    let bio: String
    let bioLinks: [String]
    let currentAvatarImageUrl: String
    let currentAvatarThumbnailImageUrl: String
    let developerType: String
    let imageUrl: String
    let isFriend: Bool
    let last_activity: String
    let last_login: String
    let last_mobile: String?
    let last_platform: String
    let location: String
    let platform: String
    let profilePicOverride: String
    let profilePicOverrideThumbnail: String
    let status: String
    let statusDescription: String
    let tags: [String]
    let userIcon: String
}

struct Instance: Codable {
    let active: Bool
    let canRequestInvite: Bool
    let capacity: Int
    let clientNumber: String
    let closedAt: String?
    let displayName: String?
    let full: Bool
    let gameServerVersion: Int
    let hardClose: String?
    let hasCapacityForYou: Bool
    let id: String
    let instanceId: String
    let instancePersistenceEnabled: Bool?
    let location: String
    let n_users: Int
    let name: String
    let ownerId: String?
    let permanent: Bool
    let photonRegion: String
    let platforms: Platforms
    let playerPersistenceEnabled: Bool
    let queueEnabled: Bool
    let queueSize: Int
    let recommendedCapacity: Int
    let region: String
    let secureName: String
    let shortName: String
    let strict: Bool
    let tags: [String]
    let type: String
    let userCount: Int
    let world: World
    let worldId: String
}

struct Platforms: Codable {
    let android: Int
    let ios: Int
    let standalonewindows: Int
}

struct World: Codable {
    let authorId: String
    let authorName: String
    let capacity: Int
    let created_at: String
    let description: String
    let favorites: Int
    let featured: Bool
    let heat: Int
    let id: String
    let imageUrl: String
    let labsPublicationDate: String
    let name: String
    let organization: String
    let popularity: Int
    let previewYoutubeId: String?
    let publicationDate: String
    let recommendedCapacity: Int
    let releaseStatus: String
    let tags: [String]
    let thumbnailImageUrl: String
    let udonProducts: [String]
    let unityPackages: [UnityPackage]
    let updated_at: String
    let version: Int
    let visits: Int
}

struct UnityPackage: Codable {
    let assetUrl: String
    let assetVersion: Int
    let created_at: String
    let id: String
    let platform: String
    let unitySortNumber: Int
    let unityVersion: String
}

let mockFriends: [Friend] = [
    Friend(
        id: "usr_27e495f4-b619-41ca-b451-2a6399196182",
        displayName: "ponCHANNN",
        bio: "Twitter ˸ ＠VR_ponCHANNN\nDiscord˸ ponCHANNN＃9029\nよく飲みます\nよく寝てます\nよく喋ります\n\n仲良くしてください（⁄⁄⁄ ＾⁄⁄⁄）\nフレンドになりたい方はぜひ送ってください！",
        bioLinks: ["https://twitter.com/@vr_ponCHANNN"],
        currentAvatarImageUrl: "https://api.vrchat.cloud/api/1/file/file_9e5830e5-2c6d-4339-a04f-3d848260398a/3/file",
        currentAvatarThumbnailImageUrl: "https://api.vrchat.cloud/api/1/image/file_9e5830e5-2c6d-4339-a04f-3d848260398a/3/256",
        developerType: "none",
        imageUrl: "https://api.vrchat.cloud/api/1/image/file_9e5830e5-2c6d-4339-a04f-3d848260398a/3/256",
        isFriend: true,
        last_activity: "2024-10-23T08:27:18.682Z",
        last_login: "2024-10-23T08:27:18.682Z",
        last_mobile: nil,
        last_platform: "standalonewindows",
        location: "wrld_4c2f8911-b082-4f58-8383-c6d64231b5a6:77874~region(jp)",
        platform: "",
        profilePicOverride: "",
        profilePicOverrideThumbnail: "",
        status: "offline",
        statusDescription: "",
        tags: [
            "system_world_access",
            "system_avatar_access",
            "system_trust_basic",
            "system_feedback_access",
            "system_trust_known",
            "system_trust_trusted",
            "language_jpn",
            "system_trust_veteran",
            "language_eng"
        ],
        userIcon: ""
    ),
    Friend(
        id: "usr_bd77ec85-06f6-4f88-9978-4c16dc13a483",
        displayName: "Spis（スピス）",
        bio: "普段はBlenderやUnityをしています。\nBoothでの販売やVRC脳波技術集会の主催もしています。\n現在は語学の勉強も少しずつ始めてます。VR技術者認定試験合格しました！\n22時以降によく出現します。\nWorld巡りで一人でいるときもあるので\nその時は遠慮なく是非来てくださると嬉しいです。\n\n［Link］\nMisskey․io˸ ＠spis\nBluesky˸ ＠spis․bsky․social\nBooth˸ https˸⁄⁄spis․booth․pm⁄",
        bioLinks: [
            "https://misskey.io/@spis",
            "https://bsky.app/profile/spis.bsky.social"
        ],
        currentAvatarImageUrl: "https://api.vrchat.cloud/api/1/file/file_0e8c4e32-7444-44ea-ade4-313c010d4bae/1/file",
        currentAvatarThumbnailImageUrl: "https://api.vrchat.cloud/api/1/image/file_0e8c4e32-7444-44ea-ade4-313c010d4bae/1/256",
        developerType: "none",
        imageUrl: "https://api.vrchat.cloud/api/1/file/file_6539ee0d-5e3d-4cdd-acb4-6644883ea8bd/1",
        isFriend: true,
        last_activity: "2024-10-22T11:43:21.784Z",
        last_login: "2024-10-22T08:15:41.773Z",
        last_mobile: nil,
        last_platform: "standalonewindows",
        location: "wrld_4c2f8911-b082-4f58-8383-c6d64231b5a6:77874~region(jp)",
        platform: "",
        profilePicOverride: "https://api.vrchat.cloud/api/1/file/file_6539ee0d-5e3d-4cdd-acb4-6644883ea8bd/1",
        profilePicOverrideThumbnail: "https://api.vrchat.cloud/api/1/image/file_6539ee0d-5e3d-4cdd-acb4-6644883ea8bd/1/256",
        status: "offline",
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
        userIcon: "https://api.vrchat.cloud/api/1/file/file_c6796fdf-105b-46d2-b205-e20468c48bff/1"
    ),
    Friend(
        id: "usr_57787b97-5cea-4b9a-8932-8ae531dcf1ef",
        displayName: "ネイル＝コロン",
        bio: "",
        bioLinks: [],
        currentAvatarImageUrl: "https://api.vrchat.cloud/api/1/file/file_0e8c4e32-7444-44ea-ade4-313c010d4bae/1/file",
        currentAvatarThumbnailImageUrl: "https://api.vrchat.cloud/api/1/image/file_0e8c4e32-7444-44ea-ade4-313c010d4bae/1/256",
        developerType: "none",
        imageUrl: "https://api.vrchat.cloud/api/1/image/file_0e8c4e32-7444-44ea-ade4-313c010d4bae/1/256",
        isFriend: true,
        last_activity: "2024-03-20T13:24:18.718Z",
        last_login: "2024-03-20T13:24:18.718Z",
        last_mobile: nil,
        last_platform: "standalonewindows",
        location: "wrld_4c2f8911-b082-4f58-8383-c6d64231b5a6:77874~region(jp)",
        platform: "",
        profilePicOverride: "",
        profilePicOverrideThumbnail: "",
        status: "offline",
        statusDescription: "",
        tags: [],
        userIcon: ""
    ),
    Friend(
        id: "usr_1fabe8c5-bd16-4749-8ab6-63699a3fff15",
        displayName: "Divine Priest",
        bio: "The wise monkey˸\nSee No Evil‚ Hear No Evil‚ Speak No Evil․\ndiscord˸ Divine＃4813\nMale\n18\nMute sometimes․\navatar creation is my deal to unity․\nFavorite Anime˸ \nServamp․\nViolet Ever Garden․\nUncle from Another World․\nThe Royal Tutor․",
        bioLinks: [],
        currentAvatarImageUrl: "https://api.vrchat.cloud/api/1/file/file_922e1bb6-77ad-4022-88c6-30743c108fc7/1/file",
        currentAvatarThumbnailImageUrl: "https://api.vrchat.cloud/api/1/image/file_922e1bb6-77ad-4022-88c6-30743c108fc7/1/256",
        developerType: "none",
        imageUrl: "https://api.vrchat.cloud/api/1/image/file_922e1bb6-77ad-4022-88c6-30743c108fc7/1/256",
        isFriend: true,
        last_activity: "2023-08-11T10:43:18.043Z",
        last_login: "2023-08-11T10:43:18.043Z",
        last_mobile: nil,
        last_platform: "standalonewindows",
        location: "wrld_4c2f8911-b082-4f58-8383-c6d64231b5a6:77874~region(jp)",
        platform: "",
        profilePicOverride: "",
        profilePicOverrideThumbnail: "",
        status: "offline",
        statusDescription: "",
        tags: [
            "system_no_captcha",
            "language_eng",
            "system_world_access",
            "system_avatar_access",
            "system_trust_basic"
        ],
        userIcon: ""
    ),
    Friend(
        id: "usr_0516a9be-fba4-493e-ac7a-9f8e57768df7",
        displayName: "superClub",
        bio: "",
        bioLinks: [],
        currentAvatarImageUrl: "https://api.vrchat.cloud/api/1/file/file_9b685591-47ed-455d-952d-b2da180326dd/2/file",
        currentAvatarThumbnailImageUrl: "https://api.vrchat.cloud/api/1/image/file_9b685591-47ed-455d-952d-b2da180326dd/2/256",
        developerType: "none",
        imageUrl: "https://api.vrchat.cloud/api/1/image/file_9b685591-47ed-455d-952d-b2da180326dd/2/256",
        isFriend: true,
        last_activity: "2023-01-15T06:59:32.487Z",
        last_login: "2023-01-15T06:59:32.487Z",
        last_mobile: nil,
        last_platform: "standalonewindows",
        location: "wrld_4c2f8911-b082-4f58-8383-c6d64231b5a6:77874~region(jp)",
        platform: "",
        profilePicOverride: "",
        profilePicOverrideThumbnail: "",
        status: "offline",
        statusDescription: "",
        tags: [
            "system_world_access",
            "system_avatar_access",
            "system_trust_basic"
        ],
        userIcon: ""
    )
]

let mockInstance = Instance(
    active: true,
    canRequestInvite: false,
    capacity: 32,
    clientNumber: "unknown",
    closedAt: nil,
    displayName: nil,
    full: false,
    gameServerVersion: 1343,
    hardClose: nil,
    hasCapacityForYou: true,
    id: "wrld_4c2f8911-b082-4f58-8383-c6d64231b5a6:77874~region(jp)",
    instanceId: "77874~region(jp)",
    instancePersistenceEnabled: nil,
    location: "wrld_4c2f8911-b082-4f58-8383-c6d64231b5a6:77874~region(jp)",
    n_users: 1,
    name: "77874",
    ownerId: nil,
    permanent: true,
    photonRegion: "jp",
    platforms: Platforms(android: 0, ios: 0, standalonewindows: 1),
    playerPersistenceEnabled: true,
    queueEnabled: false,
    queueSize: 0,
    recommendedCapacity: 16,
    region: "jp",
    secureName: "gjsxsh7y",
    shortName: "ftcufzj3",
    strict: false,
    tags: [
        "author_tag_Quest",
        "author_tag_Shooter",
        "author_tag_Game",
        "author_tag_PVP",
        "author_tag_PC",
        "language_jpn"
    ],
    type: "public",
    userCount: 1,
    world: World(
        authorId: "usr_d55653d6-089b-4107-8d0d-c9209d4f05a6",
        authorName: "Neko Koko",
        capacity: 32,
        created_at: "2024-05-14T16:43:28.597Z",
        description: "Welcome to the Sci Fi City Arenaǃ New System Update Coming Soonǃ",
        favorites: 252,
        featured: false,
        heat: 4,
        id: "wrld_4c2f8911-b082-4f58-8383-c6d64231b5a6",
        imageUrl: "https://api.vrchat.cloud/api/1/file/file_3dd713ab-1731-4438-ab95-ee064b3a2d8c/4/file",
        labsPublicationDate: "2024-05-16T15:49:02.324Z",
        name: "Sci Fi City Arena （PvP）",
        organization: "vrchat",
        popularity: 5,
        previewYoutubeId: nil,
        publicationDate: "2024-06-11T19:34:19.674Z",
        recommendedCapacity: 16,
        releaseStatus: "public",
        tags: [
            "author_tag_Quest",
            "author_tag_Shooter",
            "author_tag_Game",
            "author_tag_PVP",
            "author_tag_PC",
            "system_approved",
            "system_updated_recently"
        ],
        thumbnailImageUrl: "https://api.vrchat.cloud/api/1/image/file_3dd713ab-1731-4438-ab95-ee064b3a2d8c/4/256",
        udonProducts: [],
        unityPackages: [
            UnityPackage(
                assetUrl: "https://api.vrchat.cloud/api/1/file/file_43e7ad1d-d125-4b2f-adfd-9a0c4ca5af27/13/file",
                assetVersion: 1,
                created_at: "2024-10-31T17:26:07.190Z",
                id: "unp_089415e2-8984-4843-a888-94bce52117b5",
                platform: "android",
                unitySortNumber: 20190431000,
                unityVersion: "2019.4.31f1"
            ),
            UnityPackage(
                assetUrl: "https://api.vrchat.cloud/api/1/file/file_3707ab99-cde6-45e1-a73d-72eac22c06bd/19/file",
                assetVersion: 1,
                created_at: "2024-10-31T17:13:54.047Z",
                id: "unp_b460e699-0b9f-41f2-ae1b-0a0445b1c88e",
                platform: "standalonewindows",
                unitySortNumber: 20190431000,
                unityVersion: "2019.4.31f1"
            )
        ],
        updated_at: "2024-11-04T05:40:09.387Z",
        version: 200,
        visits: 2258
    ),
    worldId: "wrld_4c2f8911-b082-4f58-8383-c6d64231b5a6"
)

struct HomeView: View {
    @State private var friends: [Friend] = []
    @State private var instances: [Instance] = []
    @State private var authCookie: String = "your_auth_cookie_here" // ここに実際の認証クッキーを設定
    var body: some View {
            NavigationStack {
                VStack {
                    ScrollView {
                        ForEach(instances, id: \.id) { instance in
                            VStack(alignment: .leading) {
                                InstanceCard(instance: instance)
                                    .padding()
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(friends.filter { $0.location == instance.id }, id: \.id) { friend in
                                        FriendCard(friend: friend)
                                            .frame(height: 140)
                                            .padding(.horizontal, 5)
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    fetchInstanceMock()
                    fetchFriendsMock()
                }
            }
        }
    
    func fetchFriendsMock() {
            // モックデータを使用
            self.friends = mockFriends
        }
    
    func fetchInstanceMock() {
        self.instances = [mockInstance, mockInstance]
    }

    func fetchFriends() {
        guard let url = URL(string: "https://vrchat.com/api/1/auth/user/friends?offline=true") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("auth=\(authCookie)", forHTTPHeaderField: "Cookie")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            do {
                let friends = try JSONDecoder().decode([Friend].self, from: data)
                DispatchQueue.main.async {
                    self.friends = friends
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }

        task.resume()
    }
}

struct InstanceCard: View {
    var instance: Instance
    
    var body: some View {
        NavigationLink (destination: InstanceView(instanceId: instance.id)) {
            VStack(alignment: .leading) {
                if let imageUrl = URL(string: instance.world.imageUrl) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        ProgressView()
                    }
                }
                Text("Instance ID: \(instance.id)")
                    .font(.headline)
                Text("World ID: \(instance.worldId)")
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct FriendCard: View {
    var friend: Friend
    
    var body: some View {
        NavigationLink(destination: UserView(userId: friend.id)) {
            VStack(alignment: .leading) {
                if let imageUrl = URL(string: friend.imageUrl) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100) // 画像のサイズを固定
                    } placeholder: {
                        ProgressView()
                            .frame(width: 100, height: 100) // プレースホルダーのサイズも固定
                    }
                }
                Text(friend.displayName)
                    .font(.headline)
                    .lineLimit(1) // 1行に制限
                    .truncationMode(.tail) // 省略記号を末尾に表示
            }
            .padding(6) // 内側の余白を小さくする
            .background(Color.blue.opacity(0.2))
            .cornerRadius(10)
        }
    }
}

#Preview {
    HomeView()
}
