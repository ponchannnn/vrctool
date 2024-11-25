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
            
            ProfileView()   // Viewファイル①
                .tabItem {
                    Label("プロフィール", systemImage: "person.crop.circle")
                }
                .tag(2)

            CalendarView { dateComponents in
                // 選択された日付を処理するコード
                print(dateComponents)
            }  // Viewファイル②
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                .tag(3)

        } // TabView ここまで
        .navigationBarBackButtonHidden(true) // 戻るボタンを非表示にする
    } // body
} // View

#Preview {
    SelectTabView()
}
