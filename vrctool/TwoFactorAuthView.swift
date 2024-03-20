//
//  TwoFactorAuthView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2024/03/20.
//

import SwiftUI

struct TwoFactorAuthView: View {
    @State private var code: String = ""
    
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
        }
        .padding()
    }
    
    func loginWithTwoFactorAuth() {
        //codeにユーザが入力したデータが入る
        //apiでpostして認証する
        guard let url = URL(string: "https://api.vrchat.cloud/api/1/auth/twofactorauth/totp/verify") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                // Cookieを設定
                if let cookies = HTTPCookieStorage.shared.cookies {
                    let headers = HTTPCookie.requestHeaderFields(with: cookies)
                    request.allHTTPHeaderFields = headers
                }
                
                // ボディを設定
                let body = ["code": code]
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
                
                // リクエストを送信
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Error: \(error)")
                    } else if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            print(json)
                        } catch {
                            print("Failed to parse JSON: \(error)")
                        }
                    }
                }
                task.resume()
    }
}

struct TwoFactorAuthView_Previews: PreviewProvider {
    static var previews: some View {
        TwoFactorAuthView()
    }
}
