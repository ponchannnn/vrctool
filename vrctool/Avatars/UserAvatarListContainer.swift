//
//  UserAvatarListContainer.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/12/08.
//

import SwiftUI

struct UserAvatarListContainer: View {
    let userId: String
    let userName: String
    
    @State private var avatars: [Avatar] = []
    @State private var isLoading = true
    
    // AvatarListViewはsearchTextのBindingを要求するため、ここで管理します
    @State private var searchText = ""
    
    var body: some View {
        AvatarListView(
            avatars: avatars,
            isLoading: isLoading,
            mode: .local, // 取得したリストに対してローカル検索・フィルタを行う
            onLoadMore: { }, // 全件取得するため追加読み込みは不要
            hasMoreData: false,
            onRefresh: {
                await loadUserAvatars()
            },
            emptyMessage: "No public avatars found."
        )
        .navigationTitle("\(userName)'s Avatars")
        .onAppear {
            if avatars.isEmpty {
                Task { await loadUserAvatars() }
            }
        }
    }
    
    func loadUserAvatars() async {
        await MainActor.run { isLoading = true }
        
        await withCheckedContinuation { continuation in
            
            // VRChat API: アバター検索
            // user = userId を指定すると、そのユーザーのアバターを取得できます
            let queryItems = [
                URLQueryItem(name: "authorId", value: userId),
                URLQueryItem(name: "n", value: "100") // fetchAllを使うのでベースとなる取得数
            ]
            
            // fetchAllを使って、もし100件以上あっても全て取得するようにします
            NetworkManager.fetchAll(endpoint: "avatars", baseQueryItems: queryItems) { (result: Result<[Avatar], Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.avatars = data
                    case .failure(let error):
                        print("Error loading user avatars: \(error)")
                    }
                    
                    self.isLoading = false
                    continuation.resume()
                }
            }
        }
    }
}
