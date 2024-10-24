//
//  ContentView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2024/03/17.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("isTwoFactered") private var isTwoFactered: Bool = false
    
    var body: some View {
        if isLoggedIn { //ログインしていたら
            if isTwoFactered {  //２要素認証していたら
                SelectTabView()
            } else {    //２要素認証していなかったら
                TwoFactorAuthView(isLoggedIn: $isLoggedIn, isTwoFactered: $isTwoFactered)
            }
        } else {    //ログインしてなかったら
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                print("Name: \(cookie.name), Value: \(cookie.value)")
            }
        }
//        if let cookies = HTTPCookieStorage.shared.cookies {
//            for cookie in cookies {
//                HTTPCookieStorage.shared.deleteCookie(cookie)
//            }
//        }
//        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
//        UserDefaults.standard.removeObject(forKey: "isTwoFactered")
        return ContentView()
    }
}
