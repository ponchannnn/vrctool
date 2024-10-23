//
//  TabView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2024/03/22.
//

import SwiftUI

struct SelectTabView: View {

    // タブの選択項目を保持する
    @State var selection = 1

    var body: some View {

        TabView(selection: $selection) {

            HomeView()   // Viewファイル①
                .tabItem {
                    Label("Page1", systemImage: "1.circle")
                }
                .tag(1)

            CalendarView { dateComponents in
                // 選択された日付を処理するコード
                print(dateComponents)
            }  // Viewファイル②
                .tabItem {
                    Label("Page2", systemImage: "2.circle")
                }
                .tag(2)

        } // TabView ここまで

    } // body
} // View

#Preview {
    SelectTabView()
}
