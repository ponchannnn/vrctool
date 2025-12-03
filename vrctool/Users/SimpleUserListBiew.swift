//
//  SimpleUserListBiew.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/12/03.
//

import SwiftUI

struct SimpleUserListView: View {
    let users: [User]
    let isLoading: Bool
    var emptyMessage: String
    let onRefresh: () async -> Void
    let onLoadMore: () -> Void
    let hasMoreData: Bool
    
    var body: some View {
        VStack {
            if isLoading && users.isEmpty {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if users.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text(emptyMessage)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(users) { user in
                            NavigationLink(destination: UserView(userId: user.id)) {
                                UserCardView(user: user)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                if user.id == users.last?.id {
                                    onLoadMore()
                                }
                            }
                            if hasMoreData {
                                ProgressView()
                                    .padding()
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await onRefresh()
                }
            }
        }
    }
}
