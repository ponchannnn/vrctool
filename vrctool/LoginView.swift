import SwiftUI
import Foundation

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("isTwoFactored") private var isTwoFactored: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToTwoFactor = false
    @State private var editting1 = false
    @State private var isLoading = false
    

    private let loginFailedMessage = "ログインに失敗しました。もう一度お試しください。"
    private let loginErrorMessage = "ログインに失敗しました。"

    var body: some View {
        NavigationStack {
            VStack {
                Text("ログイン")
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                
                TextField("ユーザー名", text: $username,
                          onEditingChanged: { begin in
                        /// 入力開始処理
                        if begin {
                            self.editting1 = true    // 編集フラグをオン

                            /// 入力終了処理
                        } else {
                            self.editting1 = false   // 編集フラグをオフ
                        }
                    }
                )
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.bottom, 20)
                    .keyboardType(.default)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .shadow(color: editting1 ? .blue : .clear, radius: 3)
                
                SecureField("パスワード", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.bottom, 20)
                
                NavigationLink(destination: TwoFactorAuthView(), isActive: $navigateToTwoFactor) {
                    EmptyView()
                }
                
                if isLoading {
                    ProgressView()
                        .padding(.bottom, 20)
                } else {
                    Button(action: login) {
                        Text("ログイン")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                    .padding(.bottom, 20)
                }
                
                Button(action: forceLogin) {
                    Text("強制ログイン")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(5)
                }
                .padding(.bottom, 20)
            }
            .padding()
            .onAppear {
                if isLoggedIn {
                    navigateToTwoFactor = true
                }
            }
            .alert("エラー", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(self.alertMessage)
                }
        }
    }

    private func login() {
        self.isLoading = true
        if self.navigateToTwoFactor {   //遷移先から戻ったときの処理
            self.navigateToTwoFactor = false
        }

        NetworkManager.login(loginId: username, password: password) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.isLoggedIn = true
                    self.navigateToTwoFactor = true
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                    self.username = ""  // ユーザー名のリセット
                    self.password = ""  // パスワードのリセット
                }
            }
        }
    }
    private func forceLogin() {
        if self.navigateToTwoFactor {   //遷移先から戻ったときの処理
            self.navigateToTwoFactor = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // 遅延しないと再遷移しない
            self.isLoggedIn = true
            self.navigateToTwoFactor = true
        }
    }
}
