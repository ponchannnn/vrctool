import SwiftUI

struct TwoFactorAuthView: View {
    @State private var code: String = ""
    @Binding var isLoggedIn: Bool
    @Binding var isTwoFactered: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            TextField("認証コードを入力してください", text: $code)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                // 2段階認証を処理するためのメソッドを呼び出す
                self.loginWithTwoFactorAuth()
            }) {
                Text("認証")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }

    func loginWithTwoFactorAuth() {
        guard let url = URL(string: "https://vrchat.com/api/1/auth/twofactorauth/emailotp/verify") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ボディを設定
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
                            self.isTwoFactered = true
                        case 401:
                            // 認証失敗
                            self.alertMessage = "認証に失敗しました。コードが正しいか確認してください。"
                            self.showAlert = true
                        default:
                            // その他のエラーハンドリング
                            self.alertMessage = "予期しないエラーが発生しました。ステータスコード: \(httpStatus.statusCode)"
                        print(httpStatus)
                            self.showAlert = true
                    }
                }
            }
        }
        task.resume()
    }
}
