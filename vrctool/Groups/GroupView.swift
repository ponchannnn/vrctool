//
//  GroupView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//

import Foundation
import SwiftUI

struct VRCLanguage: Identifiable, Hashable {
    let id: String // 3文字コード (API送信値)
    let name: String // 表示名
    let localName: String? // 現地語表記（あれば）

    // 表示用の結合名
    var displayName: String {
        return name
    }
    
    // 検索用テキスト
    var searchableText: String {
        "\(name) \(localName ?? "") \(id)".lowercased()
    }
}

// データセット
struct VRCLanguages {
    static let all: [VRCLanguage] = [
        VRCLanguage(id: "afr", name: "Afrikaans", localName: nil),
        VRCLanguage(id: "ara", name: "العربية", localName: "Arabic"),
        VRCLanguage(id: "ase", name: "American Sign Language", localName: "ASL"),
        VRCLanguage(id: "asf", name: "Auslan (Australian Sign Language)", localName: nil),
        VRCLanguage(id: "ben", name: "বাংলা", localName: "Bengali"),
        VRCLanguage(id: "bfi", name: "British Sign Language", localName: "BSL"),
        VRCLanguage(id: "bul", name: "български", localName: "Bulgarian"),
        VRCLanguage(id: "ces", name: "Čeština", localName: "Czech"),
        VRCLanguage(id: "cmn", name: "官话", localName: "Mandarin"),
        VRCLanguage(id: "cym", name: "Cymraeg", localName: "Welsh"),
        VRCLanguage(id: "dan", name: "Dansk", localName: "Danish"),
        VRCLanguage(id: "deu", name: "Deutsch", localName: "German"),
        VRCLanguage(id: "dse", name: "Nederlandse Gebarentaal", localName: "NGT"),
        VRCLanguage(id: "ell", name: "Ελληνικά", localName: "Greek"),
        VRCLanguage(id: "eng", name: "English", localName: nil),
        VRCLanguage(id: "epo", name: "Esperanto", localName: nil),
        VRCLanguage(id: "est", name: "eesti", localName: "Estonian"),
        VRCLanguage(id: "fil", name: "Filipino", localName: nil),
        VRCLanguage(id: "fin", name: "Suomi", localName: "Finnish"),
        VRCLanguage(id: "fra", name: "Français", localName: "French"),
        VRCLanguage(id: "fsl", name: "langue des signes française", localName: "LSF"),
        VRCLanguage(id: "gla", name: "Gàidhlig", localName: "Scottish Gaelic"),
        VRCLanguage(id: "gle", name: "Gaeilge", localName: "Irish"),
        VRCLanguage(id: "gsg", name: "Deutsche Gebärdensprache", localName: "DGS"),
        VRCLanguage(id: "heb", name: "עברית", localName: "Hebrew"),
        VRCLanguage(id: "hin", name: "हिन्दी", localName: "Hindi"),
        VRCLanguage(id: "hmn", name: "Hmoob", localName: "Hmong"),
        VRCLanguage(id: "hrv", name: "hrvatski", localName: "Croatian"),
        VRCLanguage(id: "hun", name: "Magyar", localName: "Hungarian"),
        VRCLanguage(id: "hye", name: "հայերեն", localName: "Armenian"),
        VRCLanguage(id: "ind", name: "Bahasa Indonesia", localName: "Indonesian"),
        VRCLanguage(id: "isl", name: "íslenska", localName: "Icelandic"),
        VRCLanguage(id: "ita", name: "Italiano", localName: "Italian"),
        VRCLanguage(id: "jpn", name: "日本語", localName: "Japanese"),
        VRCLanguage(id: "jsl", name: "日本手話", localName: "Japanese Sign Language"),
        VRCLanguage(id: "kor", name: "한국어", localName: "Korean"),
        VRCLanguage(id: "kvk", name: "한국 수화 언어", localName: "Korean Sign Language"),
        VRCLanguage(id: "lav", name: "Latviešu", localName: "Latvian"),
        VRCLanguage(id: "lit", name: "lietuvių", localName: "Lithuanian"),
        VRCLanguage(id: "ltz", name: "Lëtzebuergesch", localName: "Luxembourgish"),
        VRCLanguage(id: "mar", name: "मराठी", localName: "Marathi"),
        VRCLanguage(id: "mkd", name: "македонски", localName: "Macedonian"),
        VRCLanguage(id: "mlt", name: "Malti", localName: "Maltese"),
        VRCLanguage(id: "mri", name: "Māori", localName: nil),
        VRCLanguage(id: "msa", name: "Bahasa Melayu", localName: "Malay"),
        VRCLanguage(id: "nld", name: "Nederlands", localName: "Dutch"),
        VRCLanguage(id: "nor", name: "Norsk", localName: "Norwegian"),
        VRCLanguage(id: "nzs", name: "New Zealand Sign Language", localName: "NZSL"),
        VRCLanguage(id: "pol", name: "Polski", localName: "Polish"),
        VRCLanguage(id: "por", name: "Português", localName: "Portuguese"),
        VRCLanguage(id: "ron", name: "Română", localName: "Romanian"),
        VRCLanguage(id: "rus", name: "Русский", localName: "Russian"),
        VRCLanguage(id: "sco", name: "Scots", localName: nil),
        VRCLanguage(id: "slk", name: "slovenčina", localName: "Slovak"),
        VRCLanguage(id: "slv", name: "slovenščina", localName: "Slovenian"),
        VRCLanguage(id: "spa", name: "Español", localName: "Spanish"),
        VRCLanguage(id: "swe", name: "Svenska", localName: "Swedish"),
        VRCLanguage(id: "tel", name: "తెలుగు", localName: "Telugu"),
        VRCLanguage(id: "tha", name: "ภาษาไทย", localName: "Thai"),
        VRCLanguage(id: "tok", name: "toki pona", localName: nil),
        VRCLanguage(id: "tur", name: "Türkçe", localName: "Turkish"),
        VRCLanguage(id: "ukr", name: "украї́нська", localName: "Ukrainian"),
        VRCLanguage(id: "vie", name: "Tiếng Việt", localName: "Vietnamese"),
        VRCLanguage(id: "wuu", name: "吳語", localName: "Wu Chinese"),
        VRCLanguage(id: "yue", name: "廣東話", localName: "Cantonese"),
        VRCLanguage(id: "zho", name: "中文", localName: "Chinese"),
        VRCLanguage(id: "zxx", name: "No linguistic content", localName: nil)
    ]
    
    // コードから名前を引くヘルパー
    static func name(for code: String) -> String {
        return all.first(where: { $0.id == code })?.name ?? code.uppercased()
    }
}

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
    
    // リストAPI (GET /users/:id/groups) 由来
    let groupId: String?
    let mutualGroup: Bool?
    let isRepresenting: Bool?
    let memberVisibility: String?
    let lastPostReadAt: String?
    let hasJoinedFrom: String?
    let joinedAt: String?
    
    // MARK: - Safe Accessors (UI用)
    
    var safeId: String {
        // リストAPI由来なら groupId
        if let gId = groupId, !gId.isEmpty { return gId }
        // 詳細API由来なら id が "grp_" で始まっているはず
        if let rawId = id, rawId.hasPrefix("grp_") { return rawId }
        return ""
    }
    var safeMembershipId: String {
        // リストAPI由来の場合、id は gmem_...
        if let rawId = id, rawId.hasPrefix("gmem_") { return rawId }
        return ""
    }
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
        return membershipStatus == "member" || myMember != nil || groupId != nil
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
    var safeImageUrl: String { imageUrl ?? "" }
    
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
    let item: GroupAnnouncement?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let announcement = try? container.decode(GroupAnnouncement.self) {
            self.item = announcement
        } else {
            self.item = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(item)
    }
}

struct GroupPost: Codable, Identifiable {
    let id: String?
    let groupId: String?
    let authorId: String?
    let editorId: String?
    let title: String?
    let text: String?
    let imageId: String?
    let imageUrl: String?
    let visibility: String?
    let roleIds: [String]?
    let createdAt: String?
    let updatedAt: String?
    
    // MARK: - Safe Accessors
    
    var safeId: String { id ?? UUID().uuidString }
    var safeTitle: String { title ?? "No Title" }
    var safeText: String { text ?? "" }
    var safeVisibility: String { visibility ?? "group" }
    var safeRoleIds: [String] { roleIds ?? [] }
    var safeImageUrl: String { imageUrl ?? "" }
    
    // 日付整形
    var createdDate: Date? {
        guard let dateStr = createdAt else { return nil }
        return ISO8601DateFormatter.vrcStandard.date(from: dateStr)
    }
    
    var formattedDate: String {
        guard let date = createdDate else { return "-" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // 編集済みかどうか
    var isEdited: Bool {
        return createdAt != updatedAt
    }
}

// レスポンス用ラッパー
struct GroupPostsResponse: Codable {
    let posts: [GroupPost]?
    let total: Int?
    
    var safePosts: [GroupPost] { posts ?? [] }
}

// 日付フォーマッターの拡張
extension ISO8601DateFormatter {
    static let vrcStandard: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
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

// MARK: - Group Permission Definition
enum GroupPermission: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    // --- Management ---
    case manageGroupData = "group-data-manage"
    case manageGroupMemberData = "group-members-manage"
    case viewAuditLog = "group-audit-view"
    
    // --- Roles ---
    case manageGroupRoles = "group-roles-manage"
    case assignGroupRoles = "group-roles-assign"
    case manageGroupDefaultRole = "group-default-role-manage"
    
    // --- Moderation ---
    case removeGroupMembers = "group-members-remove" // Kick
    case manageGroupBans = "group-bans-manage"       // Ban
    case viewAllMembers = "group-members-viewall"
    
    // --- Content ---
    case manageGroupAnnouncement = "group-announcement-manage"
    case manageGroupGalleries = "group-galleries-manage"
    case manageGroupCalendar = "group-calendar-manage"
    
    // --- Invites ---
    case manageGroupInvites = "group-invites-manage"
    
    // --- Instances ---
    case groupInstanceJoin = "group-instance-join"
    case manageGroupInstances = "group-instance-manage"      // Rename/Close
    case moderateGroupInstances = "group-instance-moderate"  // Kick/Ban/Warn inside instance
    case groupInstanceQueuePriority = "group-instance-queue-priority"
    
    // --- Instance Creation (Types) ---
    case createGroupInstanceOpen = "group-instance-open-create"       // Group (Open)
    case createGroupInstancePlus = "group-instance-plus-create"       // Group+
    case createGroupInstancePublic = "group-instance-public-create"   // Group Public
    case createGroupInstanceRestricted = "group-instance-restricted-create" // Group (Restricted)
    case createAgeGatedInstances = "group-instance-age-gated-create"  // Age Gated
    
    // --- Instance Features ---
    case groupInstanceCalendarLink = "group-instance-calendar-link"          // イベント連動インスタンス
    case groupInstancePlusPortal = "group-instance-plus-portal"              // ポータル設置
    case groupInstancePlusPortalUnlocked = "group-instance-plus-portal-unlocked" // 鍵なしポータル
    
    // --- Super User ---
    case all = "*"
    
    // MARK: - Display Info
    
    var title: String {
        switch self {
        case .manageGroupData: return "Manage Group Data"
        case .manageGroupMemberData: return "Manage Group Member Data"
        case .viewAuditLog: return "View Audit Log"
        case .manageGroupRoles: return "Manage Group Roles"
        case .assignGroupRoles: return "Assign Group Roles"
        case .manageGroupDefaultRole: return "Manage Default Role"
        case .removeGroupMembers: return "Remove Group Members"
        case .manageGroupBans: return "Manage Group Bans"
        case .viewAllMembers: return "View All Members"
        case .manageGroupAnnouncement: return "Manage Group Announcement"
        case .manageGroupGalleries: return "Manage Group Galleries"
        case .manageGroupCalendar: return "Manage Group Calendar"
        case .manageGroupInvites: return "Manage Group Invites"
        
        case .groupInstanceJoin: return "Join Group Instances"
        case .manageGroupInstances: return "Manage Group Instances"
        case .moderateGroupInstances: return "Moderate Group Instances"
        case .groupInstanceQueuePriority: return "Instance Queue Priority"
        
        case .createGroupInstanceOpen: return "Create Instance (Open)"
        case .createGroupInstancePlus: return "Create Instance (Group+)"
        case .createGroupInstancePublic: return "Create Instance (Public)"
        case .createGroupInstanceRestricted: return "Create Instance (Restricted)"
        case .createAgeGatedInstances: return "Create Age Gated Instances"
        
        case .groupInstanceCalendarLink: return "Create Event Linked Instances"
        case .groupInstancePlusPortal: return "Create Portals"
        case .groupInstancePlusPortalUnlocked: return "Create Unlocked Portals"
        case .all: return "Administrator"
        }
    }
    
    var description: String {
        switch self {
        case .manageGroupData:
            return "Allows role to edit group details (name, description, joinState, etc)."
        case .manageGroupMemberData:
            return "Allows role to view, filter by role, and sort all members and edit data about them."
        case .viewAuditLog:
            return "Allows role to view the full group audit log."
        case .manageGroupRoles:
            return "Allows role to create roles, modify roles, and delete roles."
        case .assignGroupRoles:
            return "Allows role to assign/unassign roles to users. Requires 'Manage Group Member Data'."
        case .manageGroupDefaultRole:
            return "Allows role to manage the permissions for the default role (aka Everyone role). Requires 'Manage Group Roles'."
        case .removeGroupMembers:
            return "Allows role to remove someone from the group. Requires 'Manage Group Member Data'."
        case .manageGroupBans:
            return "Allows role to ban/unban users and view all banned users. Requires 'Manage Group Member Data'."
        case .viewAllMembers:
            return "Allows role to view all members in a group, not just friends."
        case .manageGroupAnnouncement:
            return "Allows role to set/clear group announcement and send it as a notification."
        case .manageGroupGalleries:
            return "Allows role to create, reorder, edit, and delete group galleries. Can always submit to galleries, and can approve images."
        case .manageGroupCalendar:
            return "Allows role to create, modify, and publish calendar entries."
        case .manageGroupInvites:
            return "Allows role to create/cancel invites, as well as accept/decline/block join requests."
        case .groupInstanceJoin:
            return "Allows role to join group instances."
        case .manageGroupInstances:
            return "Allows role to rename or close a group instance."
        case .moderateGroupInstances:
            return "Allows role to moderate (warn/kick/ban) within a group instance."
        case .groupInstanceQueuePriority:
            return "Gives role priority for group instance queues."
        case .createGroupInstanceOpen:
            return "Allows role to create 'Group' instances (Open to group members)."
        case .createGroupInstancePlus:
            return "Allows role to create 'Group+' instances (Group members + friends of people in instance)."
        case .createGroupInstancePublic:
            return "Allows role to create 'Group Public' instances (Visible on group page, open to everyone)."
        case .createGroupInstanceRestricted:
            return "Allows role to create 'Group Only' instances (Strictly restricted to group members only)."
        case .createAgeGatedInstances:
            return "Allows role to create group instances that require users to have age verified and be 18 or above in order to join."
        case .groupInstanceCalendarLink:
            return "Allows role to create group instances linked to live events, events starting within 6 hours, and events that have ended within 6 hours."
        case .groupInstancePlusPortal:
            return "Allows role to create portals to Group+ instances."
        case .groupInstancePlusPortalUnlocked:
            return "Allows role to create unlocked portals to Group+ instances."
            
        case .all:
            return "Grants all permissions within the group."
        }
    }
    
    var icon: String {
        switch self {
        case .manageGroupData: return "gearshape.2"
        case .manageGroupMemberData: return "person.text.rectangle"
        case .viewAuditLog: return "list.bullet.rectangle"
        case .manageGroupRoles: return "person.badge.key"
        case .assignGroupRoles: return "person.badge.plus"
        case .manageGroupDefaultRole: return "person.2.circle"
        case .removeGroupMembers: return "person.fill.xmark"
        case .manageGroupBans: return "slash.circle"
        case .viewAllMembers: return "person.3"
        case .manageGroupAnnouncement: return "megaphone"
        case .manageGroupGalleries: return "photo.stack"
        case .manageGroupCalendar: return "calendar"
        case .manageGroupInvites: return "envelope"
        
        case .groupInstanceJoin: return "arrow.right.circle"
        case .manageGroupInstances: return "server.rack"
        case .moderateGroupInstances: return "shield"
        case .groupInstanceQueuePriority: return "arrow.up.circle"
        
        case .createGroupInstanceOpen, .createGroupInstancePlus, .createGroupInstancePublic, .createGroupInstanceRestricted:
            return "plus.square"
        case .createAgeGatedInstances: return "18.circle"
        
        case .groupInstanceCalendarLink: return "link"
        case .groupInstancePlusPortal, .groupInstancePlusPortalUnlocked: return "door.sliding.left.hand.closed"
            
        case .all: return "star.circle.fill"
        }
    }
}

extension GroupMyMember {
    func hasPermission(_ permission: GroupPermission) -> Bool {
        guard let permissions = self.permissions else { return false }
        return permissions.contains("*") || permissions.contains(permission.rawValue)
    }
    
    // ショートカット
    var isOwner: Bool { hasPermission(.all) }
    var canKick: Bool { hasPermission(.removeGroupMembers) }
    var canBan: Bool { hasPermission(.manageGroupBans) }
    var canAssignRoles: Bool { hasPermission(.assignGroupRoles) }
    var canManageRoles: Bool { hasPermission(.manageGroupRoles) }
    var canManageMembers: Bool { hasPermission(.manageGroupMemberData) }
    var canViewAuditLogs: Bool { hasPermission(.viewAuditLog) }
    var canManageData: Bool { hasPermission(.manageGroupData) }
    var canPostAnnouncements: Bool { hasPermission(.manageGroupAnnouncement) }
}

extension GroupRole {
    /// このロールが指定された権限を含んでいるか確認する
    func hasPermission(_ permission: GroupPermission) -> Bool {
        guard let permissions = self.permissions else { return false }
        return permissions.contains("*") || permissions.contains(permission.rawValue)
    }
}


struct GroupView: View {
    let groupId: String
    @State private var postToEdit: GroupPost?
    
    @State private var group: VRCGroup?
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    @State private var showFullDescription = false
    @State private var showFullRules = false
    
    // Members List State
    @State private var members: [User] = []
    @State private var isLoadingMembers = false
    @State private var showMembers = false
    
    // Roles List State
    @State private var roles: [GroupRole] = []
    @State private var isLoadingRoles = false
    @State private var showRoles = false
    
    // Announcements State
    @State private var announcement: GroupAnnouncement? = nil
    @State private var showFullAnonouncement = false
    @State private var isLoadingAnnouncements = false
    
    @State private var isProcessingJoin = false
    @State private var pendingAction: GroupAction?
    
    @State private var groupInstances: [Instance] = []
    @State private var isLoadingInstances = false
    
    @State private var posts: [GroupPost] = []
    @State private var expandedPostIds: Set<String> = []
    @State private var isLoadingPosts = false
    
    @State private var showAnnouncementSheet = false
    @State private var showPostSheet = false
    @State private var showEditGroupSheet = false
    @State private var announcementToDelete: String?
    @State private var showDeleteAnnouncementAlert = false
    
    var body: some View {
        mainScrollView
        .alert(item: $pendingAction) { action in
            let confirmButton: Alert.Button
            
            if action.isDestructive {
                confirmButton = .destructive(Text("Confirm")) {
                    Task { await executeAction(action) }
                }
            } else {
                confirmButton = .default(Text("Confirm")) {
                    Task { await executeAction(action) }
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
        // お知らせ作成シート
        .sheet(isPresented: $showAnnouncementSheet) {
            NewAnnouncementSheet(groupId: groupId) { title, text, img,notify in
                await createAnnouncement(title: title, text: text, imageId: img, sendNotification: notify)
            }
        }
        // post作成編集シート
        .sheet(isPresented: $showPostSheet) {
            NewPostSheet(groupId: groupId) { title, text, img, notify, vis, roles in
                await createPost(title: title, text: text, imageId: img, sendNotification: notify, visibility: vis, roleIds: roles)
            }
        }
        .sheet(item: $postToEdit) { post in
            NewPostSheet(groupId: groupId, editingPost: post) { title, text, img, _, vis, roles in
                await editPost(postId: post.safeId, title: title, text: text, imageId: img, visibility: vis, roleIds: roles)
            }
        }
        
        // グループ編集シート
        .sheet(isPresented: $showEditGroupSheet) {
            if let group = group {
                EditGroupSheet(group: group)
                    .onDisappear {
                        Task { await fetchGroup() } // 編集して閉じたら情報を更新
                    }
            }
        }
        
        // お知らせ削除確認アラート
        .alert("Delete Announcement", isPresented: $showDeleteAnnouncementAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let id = announcementToDelete {
                    deleteAnnouncement(id)
                }
            }
        } message: {
            Text("Are you sure you want to delete this announcement?")
        }
    }
    
    var mainScrollView: some View {
        Group {
            if let group = group {
                ScrollView {
                VStack(spacing: 0) {
                    // ヘッダー (バナー + アイコン)
                    headerSection(group: group)
                    
                    mainContent(group: group)
                        .padding()
                }
                }
                .background(Color(uiColor: .systemGroupedBackground))
            } else if isLoading {
                ProgressView("Loading Group...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemBackground))
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemBackground))
            }
        }
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
                    menuContent(group: group)
                }
            }
        }
    }
    
    @ViewBuilder
    func mainContent(group: VRCGroup) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            topInfoGroup(group: group)
            
            bottomInfoGroup(group: group)
        }
    }
    
    @ViewBuilder
    func topInfoGroup(group: VRCGroup) -> some View {
        Group {
            basicInfoSection(group: group)
            Divider()
            
            if !group.safeLanguages.isEmpty {
                languageSection(group: group)
                Divider()
            }
            
            statsSection(group: group)
            
            if isLoadingInstances || !groupInstances.isEmpty {
                activeInstancesSection()
            }
            
            groupLinksSection(group: group)
            
            announcementsSection(group: group)
            
            if group.isJoined {
                postsSection(group: group)
            }
        }
    }
    
    @ViewBuilder
    func bottomInfoGroup(group: VRCGroup) -> some View {
        Group {
            if let myMember = group.myMember {
                myMembershipSection(member: myMember)
            }
            
            descriptionSection(group: group)
            
            if !group.safeRules.isEmpty {
                rulesSection(group: group)
            }
            
            if let galleries = group.galleries, !galleries.isEmpty {
                galleriesSection(galleries: galleries)
            }
            
            if !group.safeTags.isEmpty {
                tagsSection(group: group)
            }
            
            detailsSection(group: group)
        }
    }
    
    func menuContent(group: VRCGroup)-> some View {
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
            
            // ★管理者メニューセクション
            if group.myMember?.hasPermission(.manageGroupData) == true {
                Divider()
                Button {
                    showEditGroupSheet = true
                } label: {
                    Label("Edit Group Info", systemImage: "pencil")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
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
    
    func languageSection(group: VRCGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Languages", systemImage: "globe")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(group.safeLanguages, id: \.self) { code in
                        HStack(spacing: 6) {
                            Text(LanguageHelper.flag(for: code))
                            Text(LanguageHelper.name(for: code))
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
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
    
    func activeInstancesSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Active Instances", systemImage: "figure.socialdance")
                    .font(.headline)
                Spacer()
                if isLoadingInstances {
                    ProgressView().controlSize(.small)
                } else {
                    Text("\(groupInstances.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            if !groupInstances.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(groupInstances) { instance in
                            NavigationLink(destination: InstanceView(instanceId: instance.safeLocation)) {
                                instanceCard(instance: instance)
                            }
                            .buttonStyle(PlainButtonStyle()) // リンクの色を無効化
                        }
                    }
                    .padding(.vertical, 4) // 影が見えるように少し余白
                }
            } else if !isLoadingInstances {
                Text("No active group instances.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    func instanceCard(instance: Instance) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 80)
                
                Image(systemName: "globe")
                    .font(.largeTitle)
                    .foregroundColor(.blue.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(instance.safeWorldName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                HStack {
                    Text("\(LanguageHelper.flag(for: instance.safeRegion))\(LanguageHelper.name(for: instance.safeRegion))")
                        .font(.caption)
                    Text("\(instance.safeUserCount) / \(instance.safeCapacity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    // 参加タイプ (Public/Group/Friendsなど)
                    Text("Group")
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
            }
            .padding(8)
        }
        .frame(width: 160)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
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
                    .contentShape(Rectangle())
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
                    .contentShape(Rectangle())
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
            HStack {
                Label("Announcement", systemImage: "megaphone")
                    .font(.headline)
                
                Spacer()
                
                if group.myMember?.hasPermission(.manageGroupAnnouncement) == true {
                    Button {
                        showAnnouncementSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if isLoadingAnnouncements {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .padding()
            } else if let announcement = announcement {
                VStack(alignment: .leading, spacing: 6) {
                    Text(announcement.safeTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(announcement.safeText)
                        .font(.caption)
                        .lineLimit(showFullAnonouncement ? nil : 5)
                    
                    if announcement.safeText.count > 80 || announcement.safeText.filter({ $0 == "\n" }).count >= 4 {
                        Button(action: { withAnimation { showFullAnonouncement.toggle() } }) {
                            Text(showFullAnonouncement ? "Show Less" : "Show More")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 4)
                    }
                    
                    if !announcement.safeImageUrl.isEmpty, let url = URL(string: announcement.safeImageUrl) {
                         AsyncImage(url: url) { img in
                             img.resizable().scaledToFit()
                         } placeholder: {
                             Color.gray.opacity(0.3)
                         }
                         .frame(maxHeight: 150)
                         .cornerRadius(8)
                    }
                    
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
                .contextMenu {
                    if group.myMember?.hasPermission(.manageGroupAnnouncement) == true {
                        Button(role: .destructive) {
                            announcementToDelete = announcement.safeId
                            showDeleteAnnouncementAlert = true
                        } label: {
                            Label("Delete Announcement", systemImage: "trash")
                        }
                    }
                }
            } else {
                // お知らせがない場合
                Text("No active announcement.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    func postsSection(group: VRCGroup) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Label("Posts", systemImage: "newspaper")
                    .font(.headline)
                
                Spacer()
                
                // 投稿権限がある場合のみ「＋」ボタン
                if group.myMember?.hasPermission(.manageGroupAnnouncement) == true {
                    Button {
                        showPostSheet = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if posts.isEmpty {
                Text("No recent posts.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            } else {
                // 最新3件を表示
                ForEach(posts.prefix(3)) { post in
                    VStack(alignment: .leading, spacing: 8) {
                        // タイトルと日付
                        Text(post.safeTitle)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        
                        // 本文
                        let isExpanded = expandedPostIds.contains(post.safeId)
                        Text(post.safeText)
                            .font(.caption)
                            .lineLimit(isExpanded ? nil : 3)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        if post.safeText.count > 80 || post.safeText.filter({ $0 == "\n" }).count >= 3 {
                            Button(action: {
                                withAnimation {
                                    if isExpanded {
                                        expandedPostIds.remove(post.safeId)
                                    } else {
                                        expandedPostIds.insert(post.safeId)
                                    }
                                }
                            }) {
                                Text(isExpanded ? "Show Less" : "Show More")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 2)
                        }
                        
                        // 画像があれば表示（URLがある場合）
                        if !post.safeImageUrl.isEmpty, let url = URL(string: post.safeImageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: { Color.gray.opacity(0.2) }
                            .frame(height: 120).cornerRadius(8).clipped()
                        }
                        
                        HStack {
                            Spacer()
                            Text(post.formattedDate)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                    .contextMenu {
                        // 管理者用削除メニュー
                        if group.myMember?.hasPermission(.manageGroupAnnouncement) == true {
                            Button {
                                postToEdit = post
                            } label: {
                                Label("Edit Post", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                deletePost(postId: post.safeId)
                            } label: {
                                Label("Delete Post", systemImage: "trash")
                            }
                        }
                    }
                }
                
                // 全件表示リンク（PostListViewへ）
//                if posts.count > 3 {
//                    NavigationLink(destination: GroupPostListView(groupId: groupId, myMember: group.myMember)) {
//                        HStack {
//                            Text("View All News")
//                                .font(.caption)
//                                .fontWeight(.bold)
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .font(.caption)
//                        }
//                        .padding(.top, 4)
//                    }
//                }
            }
        }
        .padding()
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
            
            VStack(alignment: .leading) {
                Text(group.safeRules)
                    .font(.body)
                    .lineLimit(showFullRules ? nil : 5)
                
                // 長い場合のみ「もっと見る」を表示
                if group.safeDescription.count > 150 {
                    Button(action: { withAnimation { showFullRules.toggle() } }) {
                        Text(showFullRules ? "Show Less" : "Show More")
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
            
            // FlowLayout (LazyVGridで代用)
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
                if !group.safeOwnerId.isEmpty {
                    NavigationLink(destination: UserView(userId: group.safeOwnerId)) {
                        HStack {
                            Text("Owner")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("View Profile")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                }
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
                            Task { await fetchInstances() }
                            Task { await fetchPosts() }
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
                        self.announcement = data.item
                    case .failure(let error):
                        print("Failed to fetch announcements: \(error)")
                        self.announcement = nil
                    }
                    self.isLoadingAnnouncements = false
                    continuation.resume()
                }
            }
        }
    }
    
    func fetchInstances() async {
        isLoadingInstances = true
        await withCheckedContinuation { continuation in
            NetworkManager.request(endpoint: "groups/\(groupId)/instances") { (result: Result<[Instance], Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.groupInstances = data
                    case .failure(let error):
                        print("Failed to fetch instances: \(error)")
                        self.groupInstances = []
                    }
                    self.isLoadingInstances = false
                    continuation.resume()
                }
            }
        }
    }
    
    func executeAction(_ action: GroupAction) async {
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
    
    // お知らせ削除
    func deleteAnnouncement(_ announcementId: String) {
        NetworkManager.action(endpoint: "groups/\(groupId)/announcements/\(announcementId)", method: "DELETE") { (result: Result<String, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.announcement = nil
                case .failure(let error):
                    print("Failed to delete announcement \(error)")
                }
            }
        }
    }
    
    // お知らせ作成
    func createAnnouncement(title: String, text: String, imageId: String?, sendNotification: Bool) async -> Bool {
        var body: [String: Any] = [
            "title": title,
            "text": text,
            "sendNotification": sendNotification
        ]
        
        if let img = imageId, !img.isEmpty {
            body["imageId"] = img
        }
        
        return await withCheckedContinuation { continuation in
            NetworkManager.action(endpoint: "groups/\(groupId)/announcement", method: "POST", body: body) { (result: Result<String, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        Task { await fetchAnnouncements() }
                        continuation.resume(returning: true)
                    case .failure(let error):
                        print("Create Announcement Error \(error)")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    // MARK: - Post Logic
    
    // 投稿一覧を取得
    func fetchPosts() async {
        NetworkManager.request(endpoint: "groups/\(groupId)/posts") { (result: Result<GroupPostsResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.posts = data.safePosts
                case .failure(let error):
                    print("Fetch Group Post Error\(error)")
                }
            }
        }
    }
    
    // 新規投稿を作成
    func createPost(title: String, text: String, imageId: String?, sendNotification: Bool, visibility: String, roleIds: [String]) async -> Bool {
        var body: [String: Any] = [
            "title": title,
            "text": text,
            "sendNotification": sendNotification,
            "visibility": visibility,
            "roleIds": roleIds
        ]
        
        if let img = imageId, !img.isEmpty {
            body["imageId"] = img
        }
        
        return await withCheckedContinuation { continuation in
            NetworkManager.action(endpoint: "groups/\(groupId)/posts", method: "POST", body: body) { (result: Result<GroupPost, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        Task { await fetchPosts() }
                        continuation.resume(returning: true)
                    case .failure(let error):
                        print("create post error \(error)")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    func editPost(postId: String, title: String, text: String, imageId: String?, visibility: String, roleIds: [String]) async -> Bool {
        var body: [String: Any] = [
            "title": title,
            "text": text,
            "visibility": visibility,
            "roleIds": roleIds
        ]
        
        if let img = imageId, !img.isEmpty {
            body["imageId"] = img
        }
        
        return await withCheckedContinuation { continuation in
            NetworkManager.action(endpoint: "groups/\(groupId)/posts/\(postId)", method: "PUT", body: body) { (result: Result<String, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        Task { await fetchPosts() }
                        continuation.resume(returning: true)
                    case .failure(let error):
                        print("edit post error \(error)")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    // 投稿削除
    func deletePost(postId: String) {
        NetworkManager.action(endpoint: "groups/\(groupId)/posts/\(postId)", method: "DELETE") { (result: Result<GroupPost, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.posts.removeAll { $0.id == postId }
                case .failure(let error):
                    print("delete post error \(error)")
                }
            }
        }
    }
}

struct NewAnnouncementSheet: View {
    let groupId: String
    let onPost: (String, String, String?, Bool) async -> Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var text = ""
    @State private var sendNotification = false
    @State private var isPosting = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Content")) {
                    TextField("Title", text: $title)
                    TextField("Message", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(footer: Text("Send a notification to all members.")) {
                    Button {
                        // 画像選択処理
                    } label: {
                        HStack {
                            Label("Attach Image", systemImage: "photo")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("Optional")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(footer: Text("If enabled, all group members who explicitly turned on notifications for this group will receive a push notification.")) {
                    Toggle(isOn: $sendNotification) {
                        Label("Send Notification", systemImage: "bell.fill")
                            .foregroundColor(sendNotification ? .primary : .secondary)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
            }
            .navigationTitle("New Announcement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            isPosting = true
                            let success = await onPost(title, text, nil, sendNotification)
                            isPosting = false
                            if success { dismiss() }
                        }
                    }
                    .disabled(title.isEmpty || text.isEmpty || isPosting)
                    .fontWeight(.bold)
                }
            }
            .disabled(isPosting)
            .overlay {
                if isPosting {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }
}

struct NewPostSheet: View {
    let groupId: String
    let editingPost: GroupPost?
    let onSave: (String, String, String?, Bool, String, [String]) async -> Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var text = ""
    @State private var sendNotification = false
    @State private var visibility: String = "group"
    @State private var selectedRoleIds: Set<String> = []
    
    @State private var availableRoles: [GroupRole] = []
    @State private var isLoadingRoles = true
    @State private var isProcessing = false
    
    init(groupId: String, editingPost: GroupPost? = nil, onSave: @escaping (String, String, String?, Bool, String, [String]) async -> Bool) {
        self.groupId = groupId
        self.editingPost = editingPost
        self.onSave = onSave
        
        _title = State(initialValue: editingPost?.safeTitle ?? "")
        _text = State(initialValue: editingPost?.safeText ?? "")
        _visibility = State(initialValue: editingPost?.safeVisibility ?? "group")
        _selectedRoleIds = State(initialValue: Set(editingPost?.safeRoleIds ?? []))
    }
    
    var isEditing: Bool { editingPost != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Post Content")) {
                    TextField("Headline", text: $title)
                    TextField("Content", text: $text, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section(header: Text("Settings")) {
                    // Visibility Picker
                    Picker("Visibility", selection: $visibility) {
                        Label("Group Members", systemImage: "person.2").tag("group")
                        Label("Public", systemImage: "globe").tag("public")
                    }
                    
                    Toggle("Send Notification", isOn: $sendNotification)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                
                Section(header: Text("Visible to Roles (Optional)")) {
                    if isLoadingRoles {
                        ProgressView()
                    } else {
                        // 何も選択していない = 全員
                        if selectedRoleIds.isEmpty {
                            Text("Visible to everyone (based on visibility setting)")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        
                        ForEach(availableRoles) { role in
                            HStack {
                                Text(role.safeName)
                                Spacer()
                                if selectedRoleIds.contains(role.safeId) {
                                    Image(systemName: "checkmark").foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedRoleIds.contains(role.safeId) {
                                    selectedRoleIds.remove(role.safeId)
                                } else {
                                    selectedRoleIds.insert(role.safeId)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Posts" : "Create Posts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Repost" : "Post") {
                        executeSave()
                    }
                    .disabled(title.isEmpty || text.isEmpty || isProcessing)
                }
            }
            .overlay {
                if isProcessing {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView()
                    }
                }
            }
            .onAppear {
                fetchRoles()
            }
        }
    }
    
    func fetchRoles() {
        NetworkManager.request(endpoint: "groups/\(groupId)/roles") { (result: Result<[GroupRole], Error>) in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    self.availableRoles = data
                }
                self.isLoadingRoles = false
            }
        }
    }
    
    func executeSave() {
        isProcessing = true
        Task {
            let roleArray = Array(selectedRoleIds)
            let success = await onSave(title, text, nil, sendNotification, visibility, roleArray)
            isProcessing = false
            if success { dismiss() }
        }
    }
}

struct EditGroupSheet: View {
    let group: VRCGroup
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var shortCode: String
    @State private var description: String
    @State private var rules: String
    @State private var joinState: String
    
    @State private var languages: [String]
    @State private var newLanguageInput: String = ""
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    init(group: VRCGroup) {
        self.group = group
        _name = State(initialValue: group.safeName)
        _shortCode = State(initialValue: group.safeShortCode)
        _description = State(initialValue: group.safeDescription)
        _rules = State(initialValue: group.safeRules)
        _joinState = State(initialValue: group.joinState ?? "open")
        _languages = State(initialValue: group.safeLanguages)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Info")) {
                    // Name (Max 64)
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Group Name", text: $name)
                            .onChange(of: name) { newValue in
                                if newValue.count > 64 { name = String(newValue.prefix(64)) }
                            }
                        HStack {
                            Spacer()
                            Text("\(name.count)/64")
                                .font(.caption2)
                                .foregroundColor(name.count > 60 ? .red : .secondary)
                        }
                    }
                    
                    // Short Code (3-6 chars)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Short Code")
                            Spacer()
                            TextField("CODE", text: $shortCode)
                                .multilineTextAlignment(.trailing)
                                .textInputAutocapitalization(.characters) // 大文字固定
                                .onChange(of: shortCode) { newValue in
                                    // 大文字変換 & 6文字制限 & 英数字のみ
                                    let filtered = newValue.uppercased().filter { $0.isLetter || $0.isNumber }
                                    if filtered.count > 6 {
                                        shortCode = String(filtered.prefix(6))
                                    } else {
                                        shortCode = filtered
                                    }
                                }
                        }
                        HStack {
                            Spacer()
                            Text("\(shortCode.count)/6")
                                .font(.caption2)
                                .foregroundColor((shortCode.count < 3 || shortCode.count > 6) ? .red : .secondary)
                        }
                    }
                }
                
                Section(header: Text("Privacy & Access")) {
                    Picker("Join State", selection: $joinState) {
                        Label("Open (Anyone can join)", systemImage: "door.left.hand.open").tag("open")
                        Label("Request (Approval required)", systemImage: "person.badge.clock").tag("request")
                        Label("Invite Only", systemImage: "envelope").tag("invite")
                        Label("Closed", systemImage: "lock").tag("closed") // 閉鎖
                    }
                }
                
                // --- Languages (Max 3, 3-letter) ---
                Section(header: Text("Languages")) {
                    NavigationLink {
                        LanguageSelectionView(selectedLanguages: $languages)
                    } label: {
                        HStack {
                            Text("Select Languages")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // 選択済みの言語を右側に表示 (例: "Japanese, English")
                            if languages.isEmpty {
                                Text("None")
                                    .foregroundColor(.secondary)
                            } else {
                                Text(languages.map { VRCLanguages.name(for: $0) }.joined(separator: ", "))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
                
                // --- Description (Max 250) ---
                Section(header: Text("Description")) {
                    ZStack(alignment: .bottomTrailing) {
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .onChange(of: description) { newValue in
                                if newValue.count > 250 { description = String(newValue.prefix(250)) }
                            }
                        
                        Text("\(description.count)/250")
                            .font(.caption2)
                            .foregroundColor(description.count > 240 ? .red : .secondary)
                            .padding(4)
                            .background(.ultraThinMaterial)
                            .cornerRadius(4)
                    }
                }
                
                // --- Rules ---
                Section(header: Text("Rules")) {
                    TextEditor(text: $rules)
                        .frame(minHeight: 100)
                }
                
                // エラー表示
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(isSaving || name.isEmpty || shortCode.count < 3)
                }
            }
            .overlay {
                if isSaving {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView()
                    }
                }
            }
        }
    }
    
    func saveChanges() {
        isSaving = true
        let body: [String: Any] = [
            "name": name,
            "shortCode": shortCode,
            "description": description,
            "joinState": joinState,
            "rules": rules,
            "languages": languages
        ]
        
        NetworkManager.action(endpoint: "groups/\(group.safeId)", method: "PUT", body: body) { (result: Result<String, Error>) in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    dismiss() // 成功したら閉じる (親で再取得が必要)
                case .failure(let error):
                    print("edit group data error \(error)")
                }
            }
        }
    }
}


struct LanguageSelectionView: View {
    @Binding var selectedLanguages: [String]
    @Environment(\.dismiss) var dismiss // 必要なら使うが、通常はBackボタンで戻る
    
    @State private var searchText = ""
    
    var filteredLanguages: [VRCLanguage] {
        if searchText.isEmpty {
            return VRCLanguages.all
        } else {
            return VRCLanguages.all.filter {
                $0.searchableText.contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        List {
            // 選択中の言語を一番上に表示
            if !selectedLanguages.isEmpty && searchText.isEmpty {
                Section(header: Text("Selected (\(selectedLanguages.count)/3)")) {
                    ForEach(selectedLanguages, id: \.self) { code in
                        let langName = VRCLanguages.name(for: code)
                        HStack {
                            Text(langName).font(.body).fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleSelection(code)
                        }
                    }
                }
            }
            
            // 全言語リスト
            Section(header: Text("All Languages")) {
                ForEach(filteredLanguages) { lang in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(lang.name).font(.body)
                            if let local = lang.localName {
                                Text(local).font(.caption).foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        
                        if selectedLanguages.contains(lang.id) {
                            Image(systemName: "checkmark").foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleSelection(lang.id)
                    }
                }
            }
        }
        .navigationTitle("Languages")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
    
    func toggleSelection(_ code: String) {
        if selectedLanguages.contains(code) {
            selectedLanguages.removeAll { $0 == code }
        } else {
            if selectedLanguages.count < 3 {
                selectedLanguages.append(code)
            }
        }
    }
}
