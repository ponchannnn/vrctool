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
    
    @FocusState private var focusedField: Field?
    enum Field {
        case username
        case password
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill.badge.checkmark") // アプリのロゴがあればそれに変更
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        
                        Text("VRCTool Login")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 40)
                    
                    // 入力フォームエリア
                    VStack(spacing: 20) {
                        CustomInputField(
                            iconName: "person.fill",
                            placeholder: "ユーザー名 / メールアドレス",
                            text: $username,
                            isFocused: focusedField == .username
                        )
                        .focused($focusedField, equals: .username)
                        
                        CustomInputField(
                            iconName: "lock.fill",
                            placeholder: "パスワード",
                            text: $password,
                            isSecure: true,
                            isFocused: focusedField == .password
                        )
                        .focused($focusedField, equals: .password)
                    }
                    .padding(.horizontal)
                    
                    // ログインボタンエリア
                    VStack(spacing: 15) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                        } else {
                            Button(action: login) {
                                Text("ログイン")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isFormValid ? Color.blue : Color.gray)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                            }
                            .disabled(!isFormValid)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToTwoFactor) {
                TwoFactorAuthView()
            }
            .alert("エラー", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if isLoggedIn {
                    navigateToTwoFactor = true
                }
            }
        }
    }

    var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty
    }

    private func login() {
        // キーボードを閉じる
        focusedField = nil
        self.isLoading = true
        
        NetworkManager.login(loginId: username, password: password) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let data):
                    self.isLoggedIn = true
                    self.navigateToTwoFactor = true
                    self.saveUserData(jsonString: data)

                case .failure(let error):
                    self.alertMessage = "ログインに失敗しました。\n\(error.localizedDescription)"
                    self.showAlert = true
                    self.password = "" // パスワードのみリセット
                }
            }
        }
    }

    private func saveUserData(jsonString: String) {
        if let jsonData = jsonString.data(using: .utf8) {
            // プロフィール情報の保存
            @AppStorage("Profile") var userData = jsonData
        }
    }
}

struct CustomInputField: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(isFocused ? .blue : .gray)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}
