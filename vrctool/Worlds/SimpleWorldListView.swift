//
//  SimpleWorldListView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//

import SwiftUI

// ワールドリストの取得元を定義
enum WorldListSource {
    case category(WorldCategory)       // カテゴリ (Active, Favorites, etc)
    case user(userId: String, userName: String) // 特定ユーザーのワールド
    
    var title: String {
        switch self {
        case .category(let category):
            return category.rawValue
        case .user(_, let userName):
            return "\(userName) Worlds"
        }
    }
}

struct SimpleWorldListContainer: View {
    let source: WorldListSource
    
    @State private var worlds: [World] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            WorldListView(
                worlds: worlds,
                isLoading: isLoading,
                searchConfig: .localFilter,
                onRefresh: {
                    await loadData()
                },
                onLoadMore: { },
                hasMoreData: false,
                emptyMessage: "ワールドが見つかりません。"
            )
            .navigationTitle(source.title)
            .onAppear {
                if worlds.isEmpty {
                    Task { await loadData() }
                }
            }
        }
    }
    
    // MARK: - Logic
    
    func loadData() async {
        await MainActor.run { isLoading = true }
        
        await withCheckedContinuation { continuation in
            switch source {
            case .category(let category):
                let query = [URLQueryItem(name: "n", value: "100")]
                
                NetworkManager.fetchAll(endpoint: category.apiPath, baseQueryItems: query) { (result: Result<[World], Error>) in
                    handleResult(result)
                    continuation.resume()
                }
                
            case .user(let userId, _):
                let query = [
                    URLQueryItem(name: "userId", value: userId),
                    URLQueryItem(name: "sort", value: "updated"),
                    URLQueryItem(name: "n", value: "100")
                ]
                
                NetworkManager.fetchAll(endpoint: "worlds", baseQueryItems: query) { (result: Result<[World], Error>) in
                    handleResult(result)
                    continuation.resume()
                }
            }
        }
    }
    
    func handleResult(_ result: Result<[World], Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let data):
                self.worlds = data
            case .failure(let error):
                print("Error loading worlds: \(error)")
            }
            self.isLoading = false
        }
    }
}
