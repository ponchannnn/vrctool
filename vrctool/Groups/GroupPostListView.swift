//
//  GroupPostListView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/12/18.
//

import SwiftUI

struct GroupPostListView: View {
    let groupId: String
    let myMember: GroupMyMember?
    
    @State private var posts: [GroupPost] = []
    @State private var isLoading = true
    
    // Sheet Control
    @State private var showCreateSheet = false
    @State private var postToEdit: GroupPost?
    
    var canManage: Bool {
        myMember?.hasPermission(.manageGroupAnnouncement) == true
    }
    
    var body: some View {
        List {
            if isLoading {
                HStack { Spacer(); ProgressView(); Spacer() }
            } else if posts.isEmpty {
                Text("No news posts.")
            }
            
            ForEach(posts) { post in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(post.safeTitle).font(.headline)
                        Spacer()
                        // 公開範囲アイコン
                        if post.safeVisibility == "public" {
                            Image(systemName: "globe").font(.caption).foregroundColor(.secondary)
                        } else {
                            Image(systemName: "lock").font(.caption).foregroundColor(.secondary)
                        }
                    }
                    
                    Text(post.safeText)
                        .font(.body)
                        .lineLimit(3)
                    
                    HStack {
                        Text(post.formattedDate)
                            .font(.caption).foregroundColor(.secondary)
                        if post.isEdited {
                            Text("(Edited)").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .trailing) {
                    if canManage {
                        Button(role: .destructive) {
                            Task { await deletePost(post.safeId) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            postToEdit = post
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .navigationTitle("News")
        .toolbar {
            if canManage {
                ToolbarItem(placement: .primaryAction) {
                    Button { showCreateSheet = true } label: { Image(systemName: "plus") }
                }
            }
        }
        .onAppear { fetch() }
        
        // 作成シート
        .sheet(isPresented: $showCreateSheet) {
            NewPostSheet(groupId: groupId) { title, text, img, notify, vis, roles in
                await createPost(title: title, text: text, notify: notify, visibility: vis, roleIds: roles)
            }
        }
        
        // 編集シート
        .sheet(item: $postToEdit) { post in
            NewPostSheet(groupId: groupId, post: post) { title, text, img, _, vis, roles in
                await editPost(id: post.safeId, title: title, text: text, visibility: vis, roleIds: roles)
            }
        }
    }
    
    // MARK: - API Calls (簡易版)
    func fetch() {
        NetworkManager.request(endpoint: "groups/\(groupId)/posts") { (result: Result<GroupPostsResponse, Error>) in
            DispatchQueue.main.async {
                if case .success(let data) = result { self.posts = data.safePosts }
                self.isLoading = false
            }
        }
    }
    
    func createPost(title: String, text: String, notify: Bool, visibility: String, roleIds: [String]) async -> Bool {
        let body: [String: Any] = [
            "title": title, "text": text, "imageId": "",
            "sendNotification": notify, "visibility": visibility, "roleIds": roleIds
        ]
        return await withCheckedContinuation { continuation in
            NetworkManager.action(endpoint: "groups/\(groupId)/posts", method: "POST", body: body) { (result: Result<String, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        fetch()
                        continuation.resume(returning: true)
                    case .failure(let error):
                        print("Group Post Create Error \(error)")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    func editPost(id: String, title: String, text: String, visibility: String, roleIds: [String]) async -> Bool {
        let body: [String: Any] = [
            "title": title, "text": text, "imageId": "",
            "visibility": visibility, "roleIds": roleIds
        ]
        return await withCheckedContinuation { continuation in
            NetworkManager.action(endpoint: "groups/\(groupId)/posts/\(id)", method: "PUT", body: body) { (result: Result<String, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        fetch()
                        continuation.resume(returning: true)
                    case .failure(let error):
                        print("Group Post Edit Error \(error)")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    func deletePost(_ id: String) async {
        NetworkManager.action(endpoint: "groups/\(groupId)/posts/\(id)", method: "DELETE") { (result: Result<String, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.posts.removeAll { $0.id == id }
                case .failure(let error):
                    print("Group Post Delete Error \(error)")
                }
            }
        }
    }
}
