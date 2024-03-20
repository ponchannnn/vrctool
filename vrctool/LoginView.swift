//
//  LoginView.swift
//  vrctool
//
//  Created by 池田瑞基 on 2024/03/17.
//


import SwiftUI
import Foundation

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
                    
                    let loginString = "\(self.username):\(self.password)"
                    guard let loginData = loginString.data(using: .utf8) else { return }
                    let base64LoginString = loginData.base64EncodedString()
                    
                    let headers = [
                      "User-Agent": "chrome/1.0",
                      "Authorization": "Basic \(base64LoginString)"
                    ]

                    let postData = NSData(data: "".data(using: String.Encoding.utf8)!)

                    let request = NSMutableURLRequest(url: NSURL(string: "https://api.vrchat.cloud/api/1/auth/user")! as URL,
                                                            cachePolicy: .useProtocolCachePolicy,
                                                        timeoutInterval: 10.0)
                    request.httpMethod = "GET"
                    request.allHTTPHeaderFields = headers
                    request.httpBody = postData as Data

                    // リクエスト内容をprint
                    print("Request: \(request)")
                    print("HTTP Method: \(String(describing: request.httpMethod))")
                    print("Headers: \(String(describing: request.allHTTPHeaderFields))")

                    let session = URLSession.shared
                    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                        if (error != nil) {
                            print(error)
                        } else if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    print(json)
                                }
                            } catch {
                                print("Failed to parse JSON: \(error)")
                            }
                        }
                    })
                    
                    dataTask.resume()
                    
                    
                    
                    
                    
                    
//                     var request = URLRequest(url: URL(string: "https://api.vrchat.cloud/api/1/auth/user")!)
//                     request.httpMethod = "GET"
//                     request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
//                     // User-Agentを追加
//                     request.setValue("chrome/1.0", forHTTPHeaderField: "User-Agent")
//                     let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//                         guard let data = data, error == nil else {
//                             print(String(describing: error))
//                             return
//                         }
//                         if let httpStatus = response as? HTTPURLResponse {
//                             print(httpStatus.statusCode)
//                             if httpStatus.statusCode == 200 {
//                                 // レスポンスコードが200の場合、ログイン成功とみなす
//                                 DispatchQueue.main.async {
//                                     self.isLoggedIn = true
//                                 }
//                                 let str = String(decoding: data, as: UTF8.self)
//                                 print("ステータスコードが200です")
//                                 print(str)
//                             } else {
//                                 // レスポンスコードが200以外の場合、ログイン失敗とみなす
//                                 print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                                 print("response = \(response)")
//                             }
//                         }
//                     }
//                    do {
//                        let requestInfo = [
//                            "url": request.url?.absoluteString ?? "",
//                            "httpMethod": request.httpMethod ?? "",
//                            "headers": request.allHTTPHeaderFields ?? [:],
//                            "body": String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
//                        ]
//                        let jsonData = try JSONSerialization.data(withJSONObject: requestInfo, options: .prettyPrinted)
//                        let jsonString = String(data: jsonData, encoding: .utf8)
//                        print(jsonString ?? "")
//                    } catch {
//                        print("Failed to convert request to JSON")
//                    }
//                     task.resume()
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
