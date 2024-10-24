//
//  ContentView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2024/03/17.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("isTwoFactored") private var isTwoFactored: Bool = false
    
    var body: some View {
        if isLoggedIn { //ログインしていたら
            if isTwoFactored {  //２要素認証していたら
                SelectTabView()
            } else {    //２要素認証していなかったら
                TwoFactorAuthView()
            }
        } else {    //ログインしてなかったら
            LoginView(isLoggedIn: $isLoggedIn, isTwoFactored: $isTwoFactored)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        if let cookies = HTTPCookieStorage.shared.cookies {
            print("Number of cookies: \(cookies.count)")
            for cookie in cookies {
                print("Name: \(cookie.name), Value: \(cookie.value)")
            }
        }
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "isTwoFactored")
        return ContentView()
    }
}
