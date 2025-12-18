//
//  GroupListView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2025/11/30.
//
import SwiftUI

struct GroupListView: View {
    let userId: String // 自分のID
    @State private var groups: [VRCGroup] = []
    @State private var isLoading = true
    
    var body: some View {
        List {
            if isLoading { ProgressView() }
            ForEach(groups) { group in
                NavigationLink(destination: GroupView(groupId: group.safeId)) {
                    HStack {
                        if let url = URL(string: group.iconUrl ?? "") {
                            AsyncImage(url: url) { i in i.resizable() } placeholder: { Color.gray }
                                .frame(width: 40, height: 40).cornerRadius(8)
                        }
                        VStack(alignment: .leading) {
                            Text(group.safeName).font(.headline)
                            Text(group.fullCode).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Groups")
        .onAppear {
            NetworkManager.request(endpoint: "users/\(userId)/groups") { (result: Result<[VRCGroup], Error>) in
                DispatchQueue.main.async {
                    if case .success(let data) = result { self.groups = data }
                    self.isLoading = false
                }
            }
        }
    }
}
