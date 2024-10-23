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
                TwoFactorAuthView(isTwoFactered: $isTwoFactered)
            }
        } else {    //ログインしてなかったら
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        //UserDefaults.standard.removeObject(forKey: "isTwoFactered")
        return ContentView()
    }
}
