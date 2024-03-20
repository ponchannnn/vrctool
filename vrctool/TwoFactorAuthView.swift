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
        //apiでgetして認証する
    }
}

struct TwoFactorAuthView_Previews: PreviewProvider {
    static var previews: some View {
        TwoFactorAuthView()
    }
}
