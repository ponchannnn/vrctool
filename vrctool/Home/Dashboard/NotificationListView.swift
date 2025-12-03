//
//  NotificationListView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//
import SwiftUI

struct VRCNotification: Codable, Identifiable {
    let id: String
    let type: String // "friendRequest", "invite", "requestInvite" etc
    let senderUsername: String?
    let senderUserId: String?
    let receiverUserId: String?
    let message: String
    let created_at: String
    let seen: Bool?
    
    let details: [String: String]?
    
    // --- 表示用ヘルパー ---
    
    var icon: String {
        if type == "friendRequest" { return "person.badge.plus" }
        if type == "invite" { return "envelope.fill" }
        if type == "requestInvite" { return "hand.wave.fill" }
        if type == "voteToKick" { return "exclamationmark.triangle.fill" }
        return "bell.fill"
    }
    
    var color: Color {
        if type == "friendRequest" { return .blue }
        if type == "invite" { return .green }
        if type == "requestInvite" { return .orange }
        if type == "voteToKick" { return .red }
        return .gray
    }
    
    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: created_at) else { return created_at }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    var detailText: String {
        guard let details = details, !details.isEmpty else { return "" }
        return details.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
    }
    
    // ワールド名があれば取得 (Inviteの場合など)
    var worldName: String? {
        return details?["worldName"]
    }
}

struct NotificationListView: View {
    @State private var notifications: [VRCNotification] = []
    @State private var isLoading = true
    
    @State private var selectedNotification: VRCNotification?
    
    // ユーザー画面遷移用
    @State private var navigationUserId: String?
    
    var body: some View {
        List {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if notifications.isEmpty {
                Text("通知はありません")
                    .foregroundColor(.secondary)
            } else {
                ForEach(notifications) { notif in
                    NotificationRow(notif: notif)
                        .contentShape(Rectangle()) // タップ領域を広げる
                        .onTapGesture {
                            selectedNotification = notif
                        }
                        .contextMenu {
                            // 長押しメニュー
                            if let userId = notif.senderUserId {
                                Button {
                                    navigationUserId = userId
                                } label: {
                                    Label("プロフィール", systemImage: "person.circle")
                                }
                            }
                            
                            if notif.type == "friendRequest" {
                                Button {
                                    // 承認処理 (NetworkManager.action...)
                                } label: {
                                    Label("承認", systemImage: "checkmark")
                                }
                            }
                        }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Notifications")
        .navigationDestination(isPresented: Binding(    // ios!7以上はitemで処理可
            get: { navigationUserId != nil },
            set: { if !$0 { navigationUserId = nil } }
        )) {
            if let userId = navigationUserId {
                UserView(userId: userId)
            }
        }
        .sheet(item: $selectedNotification) { notif in
            NotificationDetailModal(notification: notif)
        }
        .onAppear(perform: loadData)
        .refreshable { loadData() }
    }
    
    func loadData() {
        self.isLoading = true
        NetworkManager.request(endpoint: "auth/user/notifications") { (result: Result<[VRCNotification], Error>) in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    self.notifications = data
                }
                self.isLoading = false
            }
        }
    }
}

struct NotificationRow: View {
    let notif: VRCNotification
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: notif.icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(notif.color)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notif.senderUsername ?? "Unknown")
                        .fontWeight(.bold)
                        .font(.subheadline)
                    Spacer()
                    Text(notif.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Text(notif.message)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                // ワールド名がある場合（Inviteなど）は表示
                if let worldName = notif.worldName {
                    Text(worldName)
                        .font(.caption2)
                        .padding(4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// --- 詳細モーダル ---
struct NotificationDetailModal: View {
    let notification: VRCNotification
    @Environment(\.dismiss) var dismiss // 閉じる用
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack {
                        Image(systemName: notification.icon)
                            .font(.largeTitle)
                            .foregroundColor(notification.color)
                        
                        VStack(alignment: .leading) {
                            Text(notification.type.capitalized)
                                .font(.headline)
                            Text(notification.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    Divider()
                    
                    // メッセージ全文
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Message")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(notification.message)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(10)
                            .textSelection(.enabled)
                    }
                    
                    // 詳細情報 (Details) があれば表示
                    if !notification.detailText.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Details")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(notification.detailText)
                                .font(.caption)
                                .fontDesign(.monospaced) // 等幅フォント
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    if let userId = notification.senderUserId {
                        NavigationLink(destination: UserView(userId: userId)) {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                Text("\(notification.senderUsername ?? "User") のプロフィール")
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding()
            }
            .navigationTitle("Notification Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}
