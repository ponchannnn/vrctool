import SwiftUI

struct SelectTabView: View {

    // タブの選択項目を保持する
    @State var selection = 1

    var body: some View {

        TabView(selection: $selection) {

            HomeView()   // Viewファイル①
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
                .tag(1)
            
            UserTabContainerView()   // Viewファイル①
                .tabItem {
                    Label("ユーザー", systemImage: "person.crop.circle")
                }
                .tag(2)
            WorldTabContainerView()
                .tabItem {
                    Label("ワールド", systemImage: "globe")
                }
                .tag(3)

            CalendarView { dateComponents in
                // 選択された日付を処理するコード
                print(dateComponents)
            }  // Viewファイル②
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                .tag(4)

        } // TabView ここまで
        .navigationBarBackButtonHidden(true) // 戻るボタンを非表示にする
    } // body
} // View

#Preview {
    SelectTabView()
}
