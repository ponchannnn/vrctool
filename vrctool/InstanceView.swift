import SwiftUI

struct Instance2: Codable {
    let active: Bool
    let ageGate: Int? // new
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
    let world: World2
    let worldId: String
}

struct UnityPackage2: Codable {
    let assetUrl: String
    let assetUrlObject: [String] // new
    let assetVersion: Int
    let created_at: String
    let id: String
    let platform: String
    let pluginUrl: String // new
    let pluginUrlObject: [String] // new
    let unitySortNumber: Int
    let unityVersion: String
}

struct World2: Codable {
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
    let unityPackages: [UnityPackage2]
    let updated_at: String
    let urlList: [String]
    let version: Int
    let visits: Int
}

let mockInstance2 = Instance2(
    active: true,
    ageGate: nil,
    canRequestInvite: false,
    capacity: 30,
    clientNumber: "unknown",
    closedAt: nil,
    displayName: nil,
    full: true,
    gameServerVersion: 1343,
    hardClose: nil,
    hasCapacityForYou: true,
    id: "wrld_bf51e60f-f372-48b1-a757-88ba8331d926:62309~region(jp)",
    instanceId: "62309~region(jp)",
    instancePersistenceEnabled: nil,
    location: "wrld_bf51e60f-f372-48b1-a757-88ba8331d926:62309~region(jp)",
    n_users: 32,
    name: "62309",
    ownerId: nil,
    permanent: true,
    photonRegion: "jp",
    platforms: Platforms(android: 5, ios: 0, standalonewindows: 27),
    playerPersistenceEnabled: true,
    queueEnabled: false,
    queueSize: 0,
    recommendedCapacity: 25,
    region: "jp",
    secureName: "ej9udjn5",
    shortName: "tts0mtkv",
    strict: false,
    tags: [
        "author_tag_japan",
        "author_tag_japanese",
        "author_tag_jp",
        "language_jpn",
        "language_eng",
        "language_jsl",
        "show_social_rank",
        "language_swe"
    ],
    type: "public",
    userCount: 23,
    world: World2(
        authorId: "usr_38ccf11e-f305-46f2-ae8a-45f74e397a03",
        authorName: "tamsco274",
        capacity: 30,
        created_at: "2018-12-24T07:13:51.540Z",
        description: "日本人の初心者の方向けの各種解説ワールドです。1102更新",
        favorites: 129849,
        featured: false,
        heat: 7,
        id: "wrld_bf51e60f-f372-48b1-a757-88ba8331d926",
        imageUrl: "https://api.vrchat.cloud/api/1/file/file_c21e1df5-c53b-4878-b462-608ae900d80b/6/file",
        labsPublicationDate: "none",
        name: "［JP］Tutorial world",
        organization: "vrchat",
        popularity: 9,
        previewYoutubeId: nil,
        publicationDate: "2019-07-15T20:03:43.582Z",
        recommendedCapacity: 25,
        releaseStatus: "public",
        tags: [
            "author_tag_japan",
            "author_tag_japanese",
            "author_tag_jp",
            "admin_approved",
            "admin_onboarding_japan",
            "system_approved",
            "system_updated_recently"
        ],
        thumbnailImageUrl: "https://api.vrchat.cloud/api/1/image/file_c21e1df5-c53b-4878-b462-608ae900d80b/6/256",
        udonProducts: [],
        unityPackages: [
            UnityPackage2(
                assetUrl: "https://api.vrchat.cloud/api/1/file/file_8e27063c-2bba-4152-8d6d-eb4b812c80d9/31/file",
                assetUrlObject: [],
                assetVersion: 3,
                created_at: "2019-06-19T15:11:54.328Z",
                id: "unp_ca338897-143c-4ddc-b005-09c5a79e2dd5",
                platform: "android",
                pluginUrl: "",
                pluginUrlObject: [],
                unitySortNumber: 20170415000,
                unityVersion: "2017.4.15f1"
            ),
            UnityPackage2(
                assetUrl: "https://api.vrchat.cloud/api/1/file/file_8e27063c-2bba-4152-8d6d-eb4b812c80d9/72/file",
                assetUrlObject: [],
                assetVersion: 3,
                created_at: "2019-12-15T15:01:09.267Z",
                id: "unp_727cafb1-8edb-4be7-a181-62c842a5f493",
                platform: "android",
                pluginUrl: "",
                pluginUrlObject: [],
                unitySortNumber: 20180411000,
                unityVersion: "2018.4.11f1"
            )
        ],
        updated_at: "2024-11-16T01:42:20.236Z",
        urlList: [],
        version: 852,
        visits: 6293376
    ),
    worldId: "wrld_bf51e60f-f372-48b1-a757-88ba8331d926"
)

struct InstanceView: View {
    @State private var instance: Instance2 = mockInstance2
    @State private var authCookie: String = "your_auth_cookie_here" // ここに実際の認証クッキーを設定
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // World2.name
                Text(instance.world.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 画像
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
                
                // By authorName
                Text("By \(instance.world.authorName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Instance詳細の表
                if instance.active {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instance Details")
                            .font(.headline)

                            Group {
                            Text("Instance ID: \(instance.name)")
                            if let ownerId = instance.ownerId {
                                Text("Owner ID: \(ownerId)")
                            }
                            Text("Region: \(instance.region)")
                            Text("Type: \(instance.type)")
                            Text("User Count: \(instance.n_users)")
                        }
                        
                        HStack {
                            Text("Android: \(instance.platforms.android)")
                            Text("iOS: \(instance.platforms.ios)")
                            Text("Windows: \(instance.platforms.standalonewindows)")
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
                } else {
                    Text("Instance is not active")
                }
                
                // World詳細の表
                VStack(alignment: .leading, spacing: 10) {
                    Text("World Details")
                        .font(.headline)

                        Group {
                        Text("Description: \(instance.world.description)")
                        Text("Visits: \(instance.world.visits)")
                        Text("Favorites: \(instance.world.favorites)")
                        Text("Capacity: \(instance.world.capacity)")
                        Text("Updated At: \(instance.world.updated_at)")
                        Text("Created At: \(instance.world.created_at)")
                        Text("Release Status: \(instance.world.releaseStatus)")
                        Text("Version: \(instance.world.version)")
                    }
                    
                    Text("Tags")
                        .font(.subheadline)
                    
                    ForEach(instance.world.tags, id: \.self) { tag in
                        Text(tag)
                            .padding(5)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(5)
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
            }
            .padding()
            .onAppear {
                fetchInstanceMock()
            }
        }
    }
    
    func fetchInstanceMock() {
        self.instance = mockInstance2
    }
}
    
#Preview {
    InstanceView()
}
