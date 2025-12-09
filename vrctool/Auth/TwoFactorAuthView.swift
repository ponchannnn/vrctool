import SwiftUI

struct TwoFactorAuthView: View {
    @State private var isTwoFactored: Bool = false
    @State private var code: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading = false
    
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                VStack(spacing: 10) {
                    Image(systemName: "lock.shield.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                    
                    Text("2段階認証")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("メールに届いた認証コードを入力してください")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // コード入力欄
                CustomInputField(
                    iconName: "key.fill",
                    placeholder: "123456",
                    text: $code,
                    keyboardType: .numberPad,
                    isFocused: isFocused
                )
                .focused($isFocused)
                .padding(.horizontal)
                
                // ボタンエリア
                VStack(spacing: 15) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button(action: authenticate) {
                            Text("認証する")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(code.isEmpty ? Color.gray : Color.green)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                        .disabled(code.isEmpty)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .navigationDestination(isPresented: $isTwoFactored) {
             SelectTabView()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("通知"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
                        UserDefaults.standard.set(true, forKey: "isTwoFactored")
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
}
