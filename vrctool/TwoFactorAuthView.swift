import SwiftUI

struct TwoFactorAuthView: View {
    @State private var code: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isTwoFactored: Bool = false

    var body: some View {
        VStack {
            TextField("コードを入力してください", text: $code)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                self.authenticate()
            }) {
                Text("認証")
            }
            .padding()
            
            Button(action: {
                self.forceAuthenticate()
            }) {
                Text("強制認証")
            }
            .padding()

            NavigationLink(destination: SelectTabView(), isActive: $isTwoFactored) {
                EmptyView()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func authenticate() {
        guard let url = URL(string: "https://vrchat.com/api/1/auth/twofactorauth/emailotp/verify") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["code": code] as [String : String]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // リクエストを送信
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "リクエストに失敗しました: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }

            if let httpStatus = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    switch httpStatus.statusCode {
                        case 200:
                            // 認証成功
                            self.isTwoFactored = true
                        case 401:
                            // 認証失敗
                            self.alertMessage = "認証に失敗しました。コードが正しいか確認してください。"
                            self.showAlert = true
                        default:
                            // その他のエラーハンドリング
                            self.alertMessage = "予期しないエラーが発生しました。ステータスコード: \(httpStatus.statusCode)"
                            self.showAlert = true
                    }
                }
            }
        }
        task.resume()
    }
    func forceAuthenticate() {
        self.isTwoFactored = true
    }
}
