//
//  GroupView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//

import Foundation
import SwiftUI

// MARK: - Group Model
struct VRCGroup: Codable, Identifiable {
    let id: String?
    let name: String?
    let shortCode: String?
    let discriminator: String?
    let description: String?
    let iconId: String?
    let iconUrl: String?
    let bannerId: String?
    let bannerUrl: String?
    let privacy: String? // "default", "private" etc.
    let ownerId: String?
    let rules: String?
    let links: [String]? // APIによってはオブジェクトの可能性あり
    let languages: [String]?
    let memberCount: Int?
    let onlineMemberCount: Int?
    let createdAt: String?
    let memberCountSyncedAt: String?
    let isVerified: Bool?
    let joinState: String? // "open", "invite", "closed"
    let tags: [String]?
    let galleries: [GroupGallery]?
    let badges: [String]?
    let membershipStatus: String? // "member", "none" etc.
    let lastPostCreatedAt: String?
    
    let myMember: GroupMyMember?
    
    let roles: [GroupRole]? // ロール（役職）一覧
    let mutualMemberCount: Int? // 共通のフレンド数（検索時などに付与されることがある）
    let transferTargetId: String? // オーナー権限譲渡中のターゲットID
    
    // MARK: - Safe Accessors (UI用)
    
    var safeId: String { id ?? "" }
    var safeName: String { name ?? "Unknown Group" }
    var safeShortCode: String { shortCode ?? "" }
    var safeDiscriminator: String { discriminator ?? "0000" }
    
    var fullCode: String {
        guard let code = shortCode, let disc = discriminator else { return "" }
        return "\(code).\(disc)"
    }
    
    var safeDescription: String { description ?? "" }
    var safeRules: String { rules ?? "" }
    var safeIconUrl: String { iconUrl ?? "" }
    var safeBannerUrl: String { bannerUrl ?? "" }
    var safePrivacy: String { privacy ?? "default" }
    var safeOwnerId: String { ownerId ?? "" }
    
    var safeMemberCount: Int { memberCount ?? 0 }
    var safeOnlineMemberCount: Int { onlineMemberCount ?? 0 }
    
    var safeLanguages: [String] { languages ?? [] }
    var safeTags: [String] { tags ?? [] }
    
    // 日付変換ヘルパー (ISO8601 -> Date)
    var createdDate: Date? {
        guard let createdAt = createdAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt)
    }
    
    // UI表示用日付文字列 (例: 2024/12/28)
    var formattedCreatedAt: String {
        guard let date = createdDate else { return "-" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // 自分が参加しているかどうか
    var isJoined: Bool {
        return membershipStatus == "member" || myMember != nil
    }
}

// MARK: - Nested Models

// 自分のメンバーシップ詳細
struct GroupMyMember: Codable, Identifiable {
    let id: String?
    let groupId: String?
    let userId: String?
    let isRepresenting: Bool?
    let roleIds: [String]?
    let mRoleIds: [String]?
    let joinedAt: String?
    let membershipStatus: String?
    let visibility: String?
    let isSubscribedToAnnouncements: Bool?
    let isSubscribedToEventAnnouncements: Bool?
    let lastPostReadAt: String?
    let permissions: [String]?
    let has2FA: Bool?
    
    // Safe Accessors
    var safeId: String { id ?? "" }
    var safeUserId: String { userId ?? "" }
    var safeJoinedAt: String { joinedAt ?? "" }
    var isManager: Bool {
        // 権限チェックロジック（簡易版）
        guard let permissions = permissions else { return false }
        return permissions.contains("group-all") || permissions.contains("group-manage-settings")
    }
}

extension GroupMyMember {
    func hasPermission(_ permission: String) -> Bool {
        // "*" (すべての権限) を持っている場合、または指定の権限を持っている場合
        return permissions?.contains("*") == true || permissions?.contains(permission) == true
    }
    
    // よく使う権限のショートカット
    var canManageMembers: Bool { hasPermission("group-members-manage") }
    var canViewAuditLogs: Bool { hasPermission("group-audit-view") }
    var canManageRoles: Bool { hasPermission("group-roles-manage") }
    var canManageData: Bool { hasPermission("group-data-manage") }
    var canPostAnnouncements: Bool { hasPermission("group-announcement-manage") }
}

struct GroupMember: Codable {
    let id: String?
    let groupId: String?
    let userId: String?
    let user: User?
    let roleIds: [String]?
    let joinedAt: String?
}

// ギャラリー
struct GroupGallery: Codable, Identifiable {
    let id: String?
    let name: String?
    let description: String?
    let membersOnly: Bool?
    
    var safeId: String { id ?? UUID().uuidString }
    var safeName: String { name ?? "" }
}

struct GroupRole: Codable, Identifiable {
    let id: String?
    let name: String?
    let description: String?
    let isSelfAssignable: Bool?
    let permissions: [String]?
    
    var safeId: String { id ?? UUID().uuidString }
    var safeName: String { name ?? "Role" }
}

struct GroupAnnouncement: Codable, Identifiable {
    let id: String?
    let groupId: String?
    let authorId: String?
    let title: String?
    let text: String?
    let imageId: String?
    let imageUrl: String?
    let createdAt: String?
    let updatedAt: String?
    
    var safeId: String { id ?? UUID().uuidString }
    var safeTitle: String { title ?? "Announcement" }
    var safeText: String { text ?? "" }
    
    var createdDate: Date? {
        guard let createdAt = createdAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt)
    }
    
    var formattedDate: String {
        guard let date = createdDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AnyGroupAnnouncements: Codable {
    let items: [GroupAnnouncement]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let list = try? container.decode([GroupAnnouncement].self) {
            self.items = list
        } else {
            self.items = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(items)
    }
}

enum GroupAction: Identifiable {
    case join
    case requestInvite
    case leave
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .join: return "Join Group"
        case .requestInvite: return "Request Invite"
        case .leave: return "Leave Group"
        }
    }
    
    var message: String {
        switch self {
        case .join: return "Are you sure you want to join this group?"
        case .requestInvite: return "This group is invite-only. Do you want to send a join request?"
        case .leave: return "Are you sure you want to leave this group? You may lose your roles."
        }
    }
    
    var isDestructive: Bool {
        return self == .leave
    }
}


struct GroupView: View {
    let groupId: String
    
    @State private var group: VRCGroup?
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    @State private var showFullDescription = false
    
    // Members List State
    @State private var members: [User] = []
    @State private var isLoadingMembers = false
    @State private var showMembers = false
    
    // Roles List State
    @State private var roles: [GroupRole] = []
    @State private var isLoadingRoles = false
    @State private var showRoles = false
    
    // Announcements State
    @State private var announcements: [GroupAnnouncement] = []
    @State private var isLoadingAnnouncements = false
    
    @State private var isProcessingJoin = false
    @State private var pendingAction: GroupAction?
    
    var body: some View {
        ScrollView {
            if let group = group {
                VStack(spacing: 0) {
                    // ヘッダー (バナー + アイコン)
                    headerSection(group: group)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Group {
                            // 基本情報 (名前・コード・検証バッジ)
                            basicInfoSection(group: group)
                            
                            Divider()
                            
                            // 統計 (メンバー数・オンライン数・公開設定)
                            statsSection(group: group)
                            
                            groupLinksSection(group: group)
                            
                            announcementsSection(group: group)
                        }
                        
                        Group {
                            // 自分のメンバーシップ状況 (加入している場合のみ)
                            if let myMember = group.myMember {
                                myMembershipSection(member: myMember)
                            }
                            
                            // 説明文
                            descriptionSection(group: group)
                            
                            // ルール (存在する場合)
                            if !group.safeRules.isEmpty {
                                rulesSection(group: group)
                            }
                            
                            // ギャラリー (存在する場合)
                            if let galleries = group.galleries, !galleries.isEmpty {
                                galleriesSection(galleries: galleries)
                            }
                            
                            // タグ
                            if !group.safeTags.isEmpty {
                                tagsSection(group: group)
                            }
                            
                            // 詳細情報 (オーナー・作成日)
                            detailsSection(group: group)
                        }
                    }
                    .padding()
                }
            } else if isLoading {
                ProgressView("Loading Group...")
                    .padding(.top, 50)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Failed to load group")
                    if !errorMessage.isEmpty {
                        Text(errorMessage).font(.caption).foregroundColor(.secondary)
                    }
                    Button("Retry") {
                        Task {
                            await fetchGroup()
                        }
                    }
                }
                .padding(.top, 50)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(group?.safeName ?? "Group")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showMembers) {
            SimpleUserListView(
                users: members,
                isLoading: false,
                emptyMessage: "No members found.",
                onRefresh: { await fetchMembers() },
                onLoadMore: { },
                hasMoreData: false
            )
            .navigationTitle("Members")
        }
        .navigationDestination(isPresented: $showRoles) {
            List(roles) { role in
                VStack(alignment: .leading) {
                    Text(role.safeName).font(.headline)
                    if let desc = role.description, !desc.isEmpty {
                        Text(desc).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Roles")
        }
        .refreshable {
            Task {
                await fetchGroup()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let group = group {
                    Menu {
                        
                        if !group.isJoined {
                            Button {
                                if group.joinState == "invite" || group.joinState == "closed" {
                                    pendingAction = .requestInvite
                                } else {
                                    pendingAction = .join
                                }
                            } label: {
                                if group.joinState == "invite" || group.joinState == "closed" {
                                    Label("Request Invite", systemImage: "envelope")
                                } else {
                                    Label("Join Group", systemImage: "person.badge.plus")
                                }
                            }
                        }
                        // Leave Group (Destructive)
                        else {
                            Divider()
                            
                            Button(role: .destructive) {
                                pendingAction = .leave
                            } label: {
                                Label("Leave Group", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert(item: $pendingAction) { action in
            let confirmButton: Alert.Button
            
            if action.isDestructive {
                confirmButton = .destructive(Text("Confirm")) {
                    Task { await executeAction() }
                }
            } else {
                confirmButton = .default(Text("Confirm")) {
                    Task { await executeAction() }
                }
            }
            
            return Alert(
                title: Text(action.title),
                message: Text(action.message),
                primaryButton: confirmButton,
                secondaryButton: .cancel()
            )
        }
        .task {
            // すでにデータがある場合は再ロードしない制御も可能
            if group == nil {
                await fetchGroup()
            }
        }
    }
    
    // MARK: - Subviews
    
    // ヘッダー (バナー + アイコン)
    func headerSection(group: VRCGroup) -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(uiColor: .systemGroupedBackground))
                .frame(height: 150) // 最低限の高さ確保
            
            // バナー画像
            if !group.safeBannerUrl.isEmpty, let url = URL(string: group.safeBannerUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView())
                }
                .frame(maxWidth: .infinity)
            } else {
                Rectangle()
                    .fill(LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            LinearGradient(colors: [.clear, .black.opacity(0.4)], startPoint: .center, endPoint: .bottom)
        }
        .padding(.bottom, 0)
    }
    
    // 基本情報
    func basicInfoSection(group: VRCGroup) -> some View {
        HStack(alignment: .center, spacing: 16) {
            if !group.safeIconUrl.isEmpty, let iconUrl = URL(string: group.safeIconUrl) {
                AsyncImage(url: iconUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.5))
                }
                .frame(width: 80, height: 80) // アイコンサイズ
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(group.safeName)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    // 公式認証バッジなど (isVerified)
                    if group.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                }
                
                Text("@\(group.fullCode)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // 統計情報
    func statsSection(group: VRCGroup) -> some View {
        HStack(spacing: 20) {
            statItem(label: "Members", value: "\(group.safeMemberCount)", icon: "person.2.fill")
            statItem(label: "Online", value: "\(group.safeOnlineMemberCount)", icon: "circle.fill", iconColor: .green)
            statItem(label: "Privacy", value: group.safePrivacy.capitalized, icon: group.safePrivacy == "private" ? "lock.fill" : "globe")
            
            let joinState = group.joinState ?? "unknown"
            statItem(
                label: "Join",
                value: joinState.capitalized,
                icon: joinStateIcon(for: joinState),
                iconColor: joinStateColor(for: joinState)
            )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // Join State用のアイコン定義
    func joinStateIcon(for state: String) -> String {
        switch state {
        case "open": return "door.left.hand.open"
        case "invite": return "envelope.fill"
        case "closed": return "lock.slash.fill"
        default: return "questionmark.circle"
        }
    }
    
    // Join State用の色定義
    func joinStateColor(for state: String) -> Color {
        switch state {
        case "open": return .green
        case "invite": return .orange
        case "closed": return .red
        default: return .secondary
        }
    }
    
    func statItem(label: String, value: String, icon: String, iconColor: Color = .primary) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(iconColor)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
    
    func groupLinksSection(group: VRCGroup) -> some View {
        VStack(spacing: 0) {
            // Members
            // 表示条件: Public (default) または 自分がメンバー管理者権限を持っている
            let canViewMembers = group.safePrivacy == "default" || (group.myMember?.canManageMembers == true) || (group.myMember?.membershipStatus == "member")
            
            if canViewMembers {
                Button {
                    Task {
                        await fetchMembers()
                    }
                } label: {
                    HStack {
                        Label("Members", systemImage: "person.3")
                        Spacer()
                        if isLoadingMembers {
                            ProgressView()
                        } else {
                            Image(systemName: "chevron.right").foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoadingMembers)
                Divider()
            }
            
            // Roles
            // 表示条件: Public または ロール管理権限
             let canViewRoles = group.safePrivacy == "default" || (group.myMember?.canManageRoles == true) || (group.myMember?.membershipStatus == "member")
            
            if group.isJoined && canViewRoles {
                Button {
                    Task {
                        await fetchRoles()
                    }
                } label: {
                    HStack {
                        Label("Roles", systemImage: "person.badge.shield.checkmark")
                        Spacer()
                        if isLoadingRoles {
                            ProgressView()
                        } else {
                            Image(systemName: "chevron.right").foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoadingRoles)
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // お知らせセクション
    func announcementsSection(group: VRCGroup) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Announcements", systemImage: "megaphone")
                .font(.headline)
            
            if isLoadingAnnouncements {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .padding()
            } else if announcements.isEmpty {
                Text("No recent announcements.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            } else {
                ForEach(announcements.prefix(3)) { announcement in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(announcement.safeTitle)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(announcement.safeText)
                            .font(.caption)
                            .lineLimit(3)
                        
                        HStack {
                            Spacer()
                            Text(announcement.formattedDate)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                
                if announcements.count > 3 {
                    Button("See All") {
                        // 全件表示への遷移など
                    }
                    .font(.caption)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
}
    
    // 自分のメンバーシップ情報
    func myMembershipSection(member: GroupMyMember) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("My Membership", systemImage: "person.text.rectangle")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Status:")
                    Spacer()
                    Text(member.membershipStatus?.capitalized ?? "-")
                        .fontWeight(.bold)
                }
                
                Toggle("Announcements", isOn: .constant(member.isSubscribedToAnnouncements ?? false))
                    .disabled(true) // 編集機能をつけるならここをBindingに
                
                if member.isManager {
                    Text("You have management permissions.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    // 説明文
    func descriptionSection(group: VRCGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("About", systemImage: "info.circle")
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text(group.safeDescription)
                    .font(.body)
                    .lineLimit(showFullDescription ? nil : 5)
                
                // 長い場合のみ「もっと見る」を表示
                if group.safeDescription.count > 150 {
                    Button(action: { withAnimation { showFullDescription.toggle() } }) {
                        Text(showFullDescription ? "Show Less" : "Show More")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    // ルール
    func rulesSection(group: VRCGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Rules", systemImage: "list.bullet.clipboard")
                .font(.headline)
            
            Text(group.safeRules)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
        }
    }
    
    // ギャラリー
    func galleriesSection(galleries: [GroupGallery]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Galleries", systemImage: "photo.stack")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(galleries) { gallery in
                        VStack {
                            // ギャラリーのサムネ等があればここに表示
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .frame(width: 100, height: 80)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            
                            Text(gallery.safeName)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
    
    // タグ
    func tagsSection(group: VRCGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Tags", systemImage: "tag")
                .font(.headline)
            
            // 簡易的なFlowLayout (LazyVGridで代用)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(group.safeTags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(16)
                }
            }
        }
    }
    
    // 詳細情報
    func detailsSection(group: VRCGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Details", systemImage: "doc.text")
                .font(.headline)
            
            VStack(spacing: 0) {
                DetailRow(key: "Owner ID", value: group.safeOwnerId) // タップでUserViewへ飛べるようにすると良い
                Divider()
                DetailRow(key: "Created", value: group.formattedCreatedAt)
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Logic
    
    func fetchGroup() async {
        isLoading = true
        errorMessage = ""
        await withCheckedContinuation { continuation in
            NetworkManager.request(endpoint: "groups/\(groupId)") { (result: Result<VRCGroup, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.group = data
                        self.isLoading = false
                        if data.isJoined {
                            Task { await fetchAnnouncements() }
                        } else {
                            self.isLoadingAnnouncements = false
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    func fetchMembers() async {
        guard !isLoadingMembers else { return }
        isLoadingMembers = true
        
        await withCheckedContinuation { continuation in
            NetworkManager.fetchAll(endpoint: "groups/\(groupId)/members", limit: 50) { (result: Result<[GroupMember], Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        // Map GroupMember to User
                        self.members = data.compactMap { $0.user }
                        self.showMembers = true
                    case .failure(let error):
                        print("Failed to fetch members: \(error)")
                    }
                    self.isLoadingMembers = false
                    continuation.resume()
                }
            }
        }
    }
    
    func fetchRoles() async {
        guard !isLoadingRoles else { return }
        isLoadingRoles = true
        
        await withCheckedContinuation { continuation in
            NetworkManager.request(endpoint: "groups/\(groupId)/roles") { (result: Result<[GroupRole], Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.roles = data
                        self.showRoles = true
                    case .failure(let error):
                        print("Failed to fetch roles: \(error)")
                    }
                    self.isLoadingRoles = false
                    continuation.resume()
                }
            }
        }
    }
    
    func fetchAnnouncements() async {
        isLoadingAnnouncements = true
        await withCheckedContinuation { continuation in
            NetworkManager.request(endpoint: "groups/\(groupId)/announcement") { (result: Result<AnyGroupAnnouncements, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.announcements = data.items
                    case .failure(let error):
                        print("Failed to fetch announcements: \(error)")
                        self.announcements = []
                    }
                    self.isLoadingAnnouncements = false
                    continuation.resume()
                }
            }
        }
    }
    
    func executeAction() async {
        guard let action = pendingAction else { return }
        isProcessingJoin = true
        
        switch action {
        case .join:
            await joinGroup()
        case .requestInvite:
            await requestInvite()
        case .leave:
            await leaveGroup()
        }
        
        isProcessingJoin = false
    }
    
    func joinGroup() async {
        isProcessingJoin = true
        await withCheckedContinuation { continuation in
            NetworkManager.action(endpoint: "groups/\(groupId)/join", method: "POST") { (result: Result<String, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        Task { await fetchGroup() }
                    case .failure(let error):
                        print("Failed to join: \(error)")
                    }
                    self.isProcessingJoin = false
                    continuation.resume()
                }
            }
        }
    }
    
    func requestInvite() async {
        // あってるかわからん
        await withCheckedContinuation { continuation in
            NetworkManager.action(endpoint: "groups/\(groupId)/requests", method: "POST") { (result: Result<String, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Request sent")
                        Task { await fetchGroup() }
                    case .failure(let error):
                        print("Failed to request invite: \(error)")
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    func leaveGroup() async {
        await withCheckedContinuation { continuation in
            NetworkManager.action(endpoint: "groups/\(groupId)/leave", method: "POST") { (result: Result<String, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        Task { await fetchGroup() }
                    case .failure(let error):
                        print("Failed to leave: \(error)")
                    }
                    continuation.resume()
                }
            }
        }
    }
}
