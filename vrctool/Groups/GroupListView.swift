//
//  GroupListView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//
import SwiftUI

struct UserGroup: Codable, Identifiable {
    let id: String?
    let groupId: String?
    let name: String?
    let shortCode: String?
    let discriminator: String?
    let description: String?
    let iconId: String?
    let iconUrl: String?
    let bannerId: String?
    let bannerUrl: String?
    let privacy: String?    // "default", "private" etc.
    let ownerId: String?
    let memberCount: Int?
    let mutualGroup: Bool?  // 相手との共通グループかどうか
    let isRepresenting: Bool?
    let memberVisibility: String?   // "visible", "hidden" etc.
    let lastPostCreatedAt: String?  // ISO8601 Date String
    let lastPostReadAt: String? // ISO8601 Date String

    let joinState: String?  // "open", "invite", "closed"
    let rules: String?
    let links: [String]?
    let languages: [String]?
    let tags: [String]?
    let hasJoinedFrom: String?  // "invite", "request" etc.
    let roleIds: [String]?  // 所持しているロールID一覧
    let joinedAt: String?   // 参加日時

    // MARK: - Safe Accessors (UI用)

    var safeGroupId: String { groupId ?? "" }
    var safeMembershipId: String { id ?? "" }
    
    var safeName: String { name ?? "Unknown Group" }
    var safeShortCode: String { shortCode ?? "" }
    var safeDiscriminator: String { discriminator ?? "0000" }
    
    // フルコード (例: ABC.1234)
    var fullCode: String {
        guard let code = shortCode, let disc = discriminator else { return "" }
        return "\(code).\(disc)"
    }
    
    var safeDescription: String { description ?? "" }
    var safeIconUrl: String { iconUrl ?? "" }
    var safeBannerUrl: String { bannerUrl ?? "" }
    var safePrivacy: String { privacy ?? "default" }
    var safeOwnerId: String { ownerId ?? "" }
    
    var safeMemberCount: Int { memberCount ?? 0 }
    
    var isMutual: Bool { mutualGroup ?? false }
    var isRepresentingGroup: Bool { isRepresenting ?? false }
    
    var safeMemberVisibility: String { memberVisibility ?? "visible" }
    
    var safeTags: [String] { tags ?? [] }
    var safeRoleIds: [String] { roleIds ?? [] }

    // MARK: - Date Helpers
    
    // 最終投稿日時
    var lastPostDate: Date? {
        guard let dateStr = lastPostCreatedAt else { return nil }
        return ISO8601DateFormatter.vrcStandard.date(from: dateStr)
    }
    
    var formattedLastPostDate: String {
        guard let date = lastPostDate else { return "-" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // 既読日時
    var lastPostReadDate: Date? {
        guard let dateStr = lastPostReadAt else { return nil }
        return ISO8601DateFormatter.vrcStandard.date(from: dateStr)
    }
    
    // 未読の投稿があるかどうか (簡易判定)
    var hasUnreadPosts: Bool {
        guard let postDate = lastPostDate else { return false }
        guard let readDate = lastPostReadDate else { return true } // 読んだ記録がなければ未読扱い
        return postDate > readDate
    }
}

extension ISO8601DateFormatter {
    static let vrcStandard: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

struct GroupListView: View {
    let userId: String // 自分のID
    @State private var groups: [UserGroup] = []
    @State private var isLoading = true
    
    var body: some View {
        List {
            if isLoading { ProgressView() }
            ForEach(groups) { group in
                NavigationLink(destination: GroupView(groupId: group.safeGroupId)) {
                    HStack {
                        if let url = URL(string: group.iconUrl ?? "") {
                            AsyncImage(url: url) { i in i.resizable() } placeholder: { Color.gray }
                                .frame(width: 40, height: 40).cornerRadius(8)
                        }
                        VStack(alignment: .leading) {
                            Text(group.safeName).font(.headline)
                            Text(group.fullCode).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Groups")
        .onAppear {
            NetworkManager.request(endpoint: "users/\(userId)/groups") { (result: Result<[UserGroup], Error>) in
                DispatchQueue.main.async {
                    if case .success(let data) = result { self.groups = data }
                    self.isLoading = false
                }
            }
        }
    }
}
