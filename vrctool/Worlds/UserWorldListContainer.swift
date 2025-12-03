//
//  UserWorldListContainer.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//
import SwiftUI

struct UserWorldListContainer: View {
    let userId: String
    let userName: String
    
    @State private var worlds: [World] = []
    @State private var isLoading = true
    
    var body: some View {
        WorldListView(
            worlds: worlds,
            isLoading: isLoading,
            searchConfig: .localFilter,
            onRefresh: {
                await loadUserWorlds()
            },
            onLoadMore: { },
            hasMoreData: false,
            emptyMessage: "No public worlds found."
        )
        .navigationTitle("\(userName)'s Worlds")
        .onAppear {
            if worlds.isEmpty {
                Task { await loadUserWorlds() }
            }
        }
    }
    
    func loadUserWorlds() async {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async { self.isLoading = true }
            
            let queryItems = [
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "sort", value: "updated"),
                URLQueryItem(name: "n", value: "100")
            ]
            
            NetworkManager.request(endpoint: "worlds", queryItems: queryItems) { (result: Result<[World], Error>) in
                DispatchQueue.main.async {
                    if case .success(let data) = result {
                        self.worlds = data
                    }
                    self.isLoading = false
                    continuation.resume()
                }
            }
        }
    }
}
