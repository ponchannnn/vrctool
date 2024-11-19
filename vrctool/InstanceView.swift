import SwiftUI

struct Instance2: Codable {
    let active: Bool
    let ageGate: String? // new
    let canRequestInvite: Bool
    let capacity: Int
    let clientNumber: String
    let closedAt: String?
    let displayName: String?
    let full: Bool
    let hardClose: String?
    let hasCapacityForYou: Bool
    let id: String
    let instanceId: String
    let instancePersistenceEnabled: Bool?
    let location: String
    let n_users: Int
    let name: String
    let ownerId: String?
    let permanent: Bool
    let photonRegion: String
    let platforms: Platforms
    let playerPersistenceEnabled: Bool?
    let queueEnabled: Bool
    let queueSize: Int
    let recommendedCapacity: Int
    let region: String
    let secureName: String
    let shortName: String
    let strict: Bool
    let tags: [String]
    let type: String
    let userCount: Int
    let world: World2
    let worldId: String
}

struct UnityPackage2: Codable {
    let assetUrl: String?
    let assetUrlObject: [String: String]? // new
    let assetVersion: Int
    let created_at: String
    let id: String
    let platform: String
    let pluginUrl: String // new
    let pluginUrlObject: [String: String]? // new
    let unitySortNumber: Int
    let unityVersion: String
}

struct World2: Codable {
    let authorId: String
    let authorName: String
    let capacity: Int
    let created_at: String
    let description: String
    let favorites: Int
    let featured: Bool
    let heat: Int
    let id: String
    let imageUrl: String
    let labsPublicationDate: String
    let name: String
    let organization: String
    let popularity: Int
    let previewYoutubeId: String?
    let publicationDate: String
    let recommendedCapacity: Int
    let releaseStatus: String
    let tags: [String]
    let thumbnailImageUrl: String
    let udonProducts: [String]
//    let unityPackages: [UnityPackage2]    // 使わないため削除
    let updated_at: String
    let urlList: [String]
    let version: Int
    let visits: Int
}

struct InstanceView: View {
    var instanceId: String
    
    @State private var instance: Instance2? = nil
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var isErrorAlert = true
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView()
                    .onAppear {
                        fetchInstance(instanceId: instanceId)
                    }
            } else if let instance = instance {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        // 画像
                        if let imageUrl = URL(string: instance.world.imageUrl) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        
                        // By authorName
                        Text("By \(instance.world.authorName)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Instance詳細の表
                        if instance.active {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Instance Details")
                                    .font(.headline)

                                    Group {
                                    Text("Instance ID: \(instance.name)")
                                    if let ownerId = instance.ownerId {
                                        Text("Owner ID: \(ownerId)")
                                    }
                                    Text("Region: \(instance.region)")
                                    Text("Type: \(instance.type)")
                                    Text("User Count: \(instance.n_users)")
                                }
                                
                                HStack {
                                    Text("Android: \(instance.platforms.android)")
                                    Text("iOS: \(instance.platforms.ios)")
                                    Text("Windows: \(instance.platforms.standalonewindows)")
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                        } else {
                            Text("Instance is not active")
                        }
                        
                        // World詳細の表
                        VStack(alignment: .leading, spacing: 10) {
                            Text("World Details")
                                .font(.headline)

                                Group {
                                Text("Description: \(instance.world.description)")
                                Text("Visits: \(instance.world.visits)")
                                Text("Favorites: \(instance.world.favorites)")
                                Text("Capacity: \(instance.world.capacity)")
                                Text("Updated At: \(instance.world.updated_at)")
                                Text("Created At: \(instance.world.created_at)")
                                Text("Release Status: \(instance.world.releaseStatus)")
                                Text("Version: \(instance.world.version)")
                            }
                            
                            Text("Tags")
                                .font(.subheadline)
                            
                            ForEach(instance.world.tags, id: \.self) { tag in
                                Text(tag)
                                    .padding(5)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(5)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    }
                    .padding()
                }
                .navigationTitle(instance.world.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing){  // 右上のボタン
                        Menu {
                            Button(action: {
                                NetworkManager.inviteMyselfToInstance(instanceId: instance.id) { result in
                                    switch result {
                                    case .success:
                                        alertMessage = "招待成功"
                                        isErrorAlert = false
                                        showAlert = true
                                    case .failure(let error):
                                        alertMessage = error.localizedDescription
                                        isErrorAlert = true
                                        showAlert = true
                                    }
                                }
                            }) {
                                Label("自分を招待", systemImage: "envelope.open.fill")
                            }
                            Button(action: {}) {
                                Label("フレンドを招待", systemImage: "envelope.badge.person.crop.fill")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: isErrorAlert ? Text("Error"): Text("Success"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    private func fetchInstance(instanceId: String) {
        NetworkManager.fetchInstance(instanceId: instanceId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let instance):
                    self.instance = instance
                    self.isLoading = false
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                    self.isErrorAlert = true
                    self.showAlert = true
                    self.isLoading = false
                }
            }
        }
    }
}
    
#Preview {
    InstanceView(instanceId: "wrld_bf51e60f-f372-48b1-a757-88ba8331d926:62309~region(jp)")
}
