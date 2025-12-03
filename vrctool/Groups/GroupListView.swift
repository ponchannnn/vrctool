//
//  GroupListView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//
import SwiftUI

struct UserGroup: Codable, Identifiable {
    let id: String
    let name: String
    let shortCode: String
    let discriminator: String?
    let bannerUrl: String?
    let iconUrl: String?
    let iconId: String?
}

struct GroupListView: View {
    let userId: String // 自分のID
    @State private var groups: [UserGroup] = []
    @State private var isLoading = true
    
    var body: some View {
        List {
            if isLoading { ProgressView() }
            ForEach(groups) { group in
                HStack {
                    if let url = URL(string: group.iconUrl ?? "") {
                        AsyncImage(url: url) { i in i.resizable() } placeholder: { Color.gray }
                            .frame(width: 40, height: 40).cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text(group.name).font(.headline)
                        Text(group.shortCode).font(.caption).foregroundColor(.secondary)
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
