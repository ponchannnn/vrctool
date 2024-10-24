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
        location: "offline",
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
        location: "offline",
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
        location: "offline",
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
        location: "offline",
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
        location: "offline",
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

struct HomeView: View {
    @State private var friends: [Friend] = []
    @State private var authCookie: String = "your_auth_cookie_here" // ここに実際の認証クッキーを設定

    var body: some View {
        NavigationView {
            List(friends) { friend in
                VStack(alignment: .leading) {
                    Text(friend.displayName)
                        .font(.headline)
                    Text(friend.bio)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("フレンド一覧")
            .onAppear {
                            fetchFriendsMock()
                        }
        }
        .navigationBarBackButtonHidden(true) // 戻るボタンを非表示にする
    }
    
    func fetchFriendsMock() {
            // モックデータを使用
            self.friends = mockFriends
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

#Preview {
    HomeView()
}
