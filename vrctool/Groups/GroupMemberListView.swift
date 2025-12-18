//
//  GroupMemberListView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/12/18.
//


import SwiftUI

struct GroupMemberListView: View {
    let groupId: String
    let myMember: GroupMyMember? // 自分の権限情報
    
    @State private var members: [GroupMember] = []
    @State private var isLoading = true
    @State private var searchText = ""
    
    // メンバー管理用State
    @State private var selectedMember: GroupMember? // 操作対象のメンバー
    @State private var showRoleSheet = false        // ロール変更モーダル
    @State private var showKickAlert = false        // Kick確認アラート
    @State private var showBanAlert = false         // Ban確認アラート
    
    // フィルタ・ソート用
    @State private var sortOrder: SortOrder = .joinedAtDesc
    
    enum SortOrder {
        case joinedAtDesc, joinedAtAsc, nameAsc
    }
    
    var filteredMembers: [GroupMember] {
        let result: [GroupMember]
        
        // 1. 検索フィルタ
        if searchText.isEmpty {
            result = members
        } else {
            result = members.filter {
                ($0.user?.safeDisplayName ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 2. ソート
        return result.sorted { m1, m2 in
            switch sortOrder {
            case .joinedAtDesc:
                return (m1.joinedAt ?? "") > (m2.joinedAt ?? "")
            case .joinedAtAsc:
                return (m1.joinedAt ?? "") < (m2.joinedAt ?? "")
            case .nameAsc:
                return (m1.user?.safeDisplayName ?? "") < (m2.user?.safeDisplayName ?? "")
            }
        }
    }
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemBackground))
            } else {
                List {
                ForEach(filteredMembers, id: \.id) { member in
                    // メンバー行の表示 (NavigationLinkで詳細へ)
                    if let user = member.user {
                        NavigationLink(destination: UserView(userId: user.id)) {
                            MemberRow(member: member)
                        }
                        // ★ LINE風スワイプアクション
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            
                            // 1. バン (権限がある場合のみ表示)
                            if myMember?.canBanMembers == true {
                                Button(role: .destructive) {
                                    self.selectedMember = member
                                    self.showBanAlert = true
                                } label: {
                                    Label("Ban", systemImage: "slash.circle")
                                }
                            }
                            
                            // 2. キック (権限がある場合のみ表示)
                            if myMember?.canRemoveMembers == true {
                                Button(role: .destructive) {
                                    self.selectedMember = member
                                    self.showKickAlert = true
                                } label: {
                                    Label("Kick", systemImage: "person.fill.xmark")
                                }
                                .tint(.orange) // Kickはオレンジにして区別
                            }
                            
                            // 3. ロール変更 (権限がある場合のみ表示)
                            if myMember?.canAssignRoles == true {
                                Button {
                                    self.selectedMember = member
                                    self.showRoleSheet = true
                                } label: {
                                    Label("Roles", systemImage: "person.badge.key")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search Members")
        .navigationTitle("Members")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort", selection: $sortOrder) {
                        Text("Newest Joined").tag(SortOrder.joinedAtDesc)
                        Text("Oldest Joined").tag(SortOrder.joinedAtAsc)
                        Text("Name (A-Z)").tag(SortOrder.nameAsc)
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
            }
        }
        .onAppear {
            fetchMembers()
        }
        // --- Modals & Alerts ---
        
        // ロール変更シート
        .sheet(isPresented: $showRoleSheet) {
            if let target = selectedMember, let user = target.user {
                GroupMemberRoleSheet(groupId: groupId, member: target, userName: user.safeDisplayName)
            }
        }
        
        // Kickアラート
        .alert("Kick Member", isPresented: $showKickAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Kick", role: .destructive) {
                if let target = selectedMember {
                    kickMember(target)
                }
            }
        } message: {
            Text("Are you sure you want to remove \(selectedMember?.user?.safeDisplayName ?? "this user") from the group?")
        }
        
        // Banアラート
        .alert("Ban Member", isPresented: $showBanAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Ban", role: .destructive) {
                if let target = selectedMember {
                    banMember(target)
                }
            }
        } message: {
            Text("Are you sure you want to BAN \(selectedMember?.user?.safeDisplayName ?? "this user")? They will not be able to rejoin.")
        }
    }
    
    // MARK: - API Logic
    
    func fetchMembers() {
        // 全件取得 (ページネーションは今回は簡易化のため省略、limitを大きく設定)
        NetworkManager.fetchAll(endpoint: "groups/\(groupId)/members", limit: 100) { (result: Result<[GroupMember], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.members = data
                case .failure(let error):
                    print("Error fetching members: \(error)")
                }
                self.isLoading = false
            }
        }
    }
    
    func kickMember(_ member: GroupMember) {
        guard let userId = member.userId else { return }
        // Kick API: DELETE /groups/:groupId/members/:userId
        NetworkManager.action(endpoint: "groups/\(groupId)/members/\(userId)", method: "DELETE") { result in
            DispatchQueue.main.async {
                if case .success = result {
                    // リストから削除してUI更新
                    self.members.removeAll { $0.id == member.id }
                } else {
                    // エラーハンドリング (Toastなどを出すと良い)
                    print("Failed to kick")
                }
            }
        }
    }
    
    func banMember(_ member: GroupMember) {
        guard let userId = member.userId else { return }
        // Ban API: POST /groups/:groupId/bans
        let body: [String: Any] = ["userId": userId]
        NetworkManager.action(endpoint: "groups/\(groupId)/bans", method: "POST", body: body) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    self.members.removeAll { $0.id == member.id }
                } else {
                    print("Failed to ban")
                }
            }
        }
    }
}

// リストの行デザイン
struct MemberRow: View {
    let member: GroupMember
    
    var body: some View {
        HStack {
            if let user = member.user {
                // アイコン
                if let urlStr = user.currentAvatarThumbnailImageUrl, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { i in i.resizable() } placeholder: { Color.gray }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text(user.safeDisplayName)
                        .font(.headline)
                    // ロール情報の表示などをここに足しても良い
                    if let roleIds = member.roleIds, !roleIds.isEmpty {
                        Text("\(roleIds.count) Roles")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct GroupMemberRoleSheet: View {
    let groupId: String
    let member: GroupMember // 対象メンバー
    let userName: String
    
    @Environment(\.dismiss) var dismiss
    
    @State private var allRoles: [GroupRole] = []
    @State private var userRoleIds: Set<String> = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    ProgressView()
                } else {
                    ForEach(allRoles) { role in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(role.safeName)
                                    .font(.body)
                                if let desc = role.description, !desc.isEmpty {
                                    Text(desc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // チェックマーク
                            if userRoleIds.contains(role.safeId) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleRole(roleId: role.safeId)
                        }
                    }
                }
            }
            .navigationTitle("Manage Roles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                fetchData()
            }
        }
    }
    
    func fetchData() {
        // 1. グループの全ロールを取得
        NetworkManager.request(endpoint: "groups/\(groupId)/roles") { (result: Result<[GroupRole], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let roles):
                    // "Everyone" ロールなどは外せない仕様があるため、UIから隠すか制御が必要だが一旦全表示
                    self.allRoles = roles
                    // ユーザーの現在のロールをSetに
                    self.userRoleIds = Set(member.roleIds ?? [])
                    self.isLoading = false
                case .failure(let error):
                    print("Failed to fetch roles: \(error)")
                }
            }
        }
    }
    
    func toggleRole(roleId: String) {
        guard let userId = member.userId else { return }
        
        // すでに持っているなら削除、持っていなければ追加
        if userRoleIds.contains(roleId) {
            // Remove Role: DELETE /groups/:groupId/members/:userId/roles/:roleId
            NetworkManager.action(endpoint: "groups/\(groupId)/members/\(userId)/roles/\(roleId)", method: "DELETE") { result in
                DispatchQueue.main.async {
                    if case .success = result {
                        self.userRoleIds.remove(roleId)
                    }
                }
            }
        } else {
            // Add Role: PUT /groups/:groupId/members/:userId/roles/:roleId
            NetworkManager.action(endpoint: "groups/\(groupId)/members/\(userId)/roles/\(roleId)", method: "PUT") { result in
                DispatchQueue.main.async {
                    if case .success = result {
                        self.userRoleIds.insert(roleId)
                    }
                }
            }
        }
    }
}
