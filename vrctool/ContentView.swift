//
//  ContentView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2024/03/17.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        if isLoggedIn { //ログインしていたら
            SelectTabView()
        } else {    //ログインしてなかったら
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
