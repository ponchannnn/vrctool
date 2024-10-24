import SwiftUI
import Foundation

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @Binding var isLoggedIn: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("ログイン")
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                
                TextField("ユーザー名", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.bottom, 20)
                
                SecureField("パスワード", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.bottom, 20)
                
                Button(action: {
                    // ログイン処理
                    let loginString = "\(self.username):\(self.password)"
                    guard let loginData = loginString.data(using: .utf8) else { return }
                    let base64LoginString = loginData.base64EncodedString()
                    
                    var request = URLRequest(url: URL(string: "https://vrchat.com/api/1/auth/user")!)
                    request.httpMethod = "GET"
                    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                    request.setValue("chrome/1.0", forHTTPHeaderField: "User-Agent")
                    
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        guard let data = data, error == nil else {
                            DispatchQueue.main.async {
                                self.alertMessage = "ログインに失敗しました。もう一度お試しください。"
                                self.showAlert = true
                            }
                            return
                        }
                        if let httpStatus = response as? HTTPURLResponse {
                            print(httpStatus)
                            if httpStatus.statusCode == 200 {
                                DispatchQueue.main.async {
                                    self.isLoggedIn = true
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.alertMessage = "ログインに失敗しました。"
                                    self.showAlert = true
                                    self.username = ""  // ユーザー名のリセット
                                    self.password = ""  // パスワードのリセット
                                }
                            }
                        }
                    }
                    task.resume()
                }) {
                    Text("ログイン")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(5)
                }
                .padding(.bottom, 20)
                .alert("エラー", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(self.alertMessage)
                }
            }
            .padding()
        }
    }
}
