//
//  LoginView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2024/03/17.
//


import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Text("ログイン").font(.largeTitle).padding(.bottom, 20)
                
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
                    // ここにログインの処理を実装します
                    self.isLoggedIn = true // 仮のログイン成功としてisLoggedInをtrueに設定します
                }) {
                    Text("ログイン")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(5)
                }
                .padding(.bottom, 20)
                
                NavigationLink(
                    destination: HomeView(),
                    isActive: $isLoggedIn,
                    label: {
                        EmptyView()
                    }
                )
            }
            .padding()
        }
    }
}
