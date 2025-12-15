import Foundation

extension Notification.Name {
    static let logoutRequired = Notification.Name("LogoutRequired")
}

struct NetworkManager {
    static func login(loginId: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        // cookieあれば削除
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if (cookie.name == "auth" || cookie.name == "twoFactorAuth") {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
            }
        }

        let loginString = "\(loginId):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid login data"])))
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        guard let url = URL(string: "https://api.vrchat.cloud/api/1/auth/user") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("chrome/1.0", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response"])))
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                    completion(.success(jsonString))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
                }
            } else {
                let errorMessage = "Login failed with status code: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }
        task.resume()
    }
    
    static func fetchHome(url: String, completion: @escaping (Result<[World], Error>) -> Void) {
            
            guard let requestUrl = URL(string: url) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }

            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"

            request.setValue("chrome/1.0", forHTTPHeaderField: "User-Agent")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "No Response", code: 0, userInfo: nil)))
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: [NSLocalizedDescriptionKey: "Login required"])))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    let worlds = try JSONDecoder().decode([World].self, from: data)
                    completion(.success(worlds))
                } catch {
                    print("Decode Error: \(error)")
                    completion(.failure(error))
                }
            }.resume()
        }
    
    static func inviteMyselfToInstance(instanceId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://vrchat.com/api/1/invite/myself/to/\(instanceId)") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("chrome/1.0", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No response")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response"])))
                return
            }
            
            if httpResponse.statusCode == 401 {
                print("Unauthorized")
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                let errorCode = httpResponse.statusCode
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: errorCode)
                print("Server error with code: \(errorCode), message: \(errorMessage)")
                completion(.failure(NSError(domain: "", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            print("Invite sent successfully")
            completion(.success(()))
        }
        
        task.resume()
    }

    static func fetchUser(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "https://api.vrchat.cloud/api/1/users/\(userId)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("chrome/1.0", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No response")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response"])))
                return
            }
            
            if httpResponse.statusCode == 401 {
                print("Unauthorized")
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                let errorCode = httpResponse.statusCode
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: errorCode)
                print("Server error with code: \(errorCode), message: \(errorMessage)")
                completion(.failure(NSError(domain: "", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    static func fetchInstance(instanceId: String, completion: @escaping (Result<Instance, Error>) -> Void) {
        guard let url = URL(string: "https://api.vrchat.cloud/api/1/instances/\(instanceId)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("chrome/1.0", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No response")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response"])))
                return
            }
            
            if httpResponse.statusCode == 401 {
                print("Unauthorized")
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                let errorCode = httpResponse.statusCode
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: errorCode)
                print("Server error with code: \(errorCode), message: \(errorMessage)")
                completion(.failure(NSError(domain: "", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let instance = try JSONDecoder().decode(Instance.self, from: data)
                completion(.success(instance))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    static func fetchWorld(worldId: String, completion: @escaping (Result<World, Error>) -> Void) {
        guard let url = URL(string: "https://api.vrchat.cloud/api/1/worlds/\(worldId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("chrome/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let world = try JSONDecoder().decode(World.self, from: data)
                completion(.success(world))
            } catch {
                print("World Decode Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func fetchWorlds(url: String, completion: @escaping (Result<[World], Error>) -> Void) {
            
        guard let requestUrl = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        request.setValue("chrome/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let worlds = try JSONDecoder().decode([World].self, from: data)
                completion(.success(worlds))
            } catch {
                print("Worlds Decode Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func searchWorlds(query: String, completion: @escaping (Result<[World], Error>) -> Void) {
        var components = URLComponents(string: "https://api.vrchat.cloud/api/1/worlds")!
        
        components.queryItems = [
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "sort", value: "popularity"), // 人気順
            URLQueryItem(name: "order", value: "descending"),
            URLQueryItem(name: "n", value: "60"), // 取得数
            URLQueryItem(name: "featured", value: "false")
        ]
        
        guard let url = components.url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("chrome/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let worlds = try JSONDecoder().decode([World].self, from: data)
                completion(.success(worlds))
            } catch {
                print("Search Decode Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func request<T: Codable>(endpoint: String, queryItems: [URLQueryItem]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        let baseUrl = "https://api.vrchat.cloud/api/1/"
        // 1. URL構築
        guard var components = URLComponents(string: baseUrl + endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "Invalid URL Params", code: 0)))
            return
        }

        // 2. リクエスト作成
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("vrctool/1.0", forHTTPHeaderField: "User-Agent")
        
        // 3. 通信実行
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    print("⚠️ 401 Unauthorized: Session Expired")
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .logoutRequired, object: nil)
                    }
                    
                    completion(.failure(NSError(domain: "Unauthorized", code: 401)))
                    return
                }
            }
            
            // 4. 汎用デコード (T型としてデコードする)
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                if let rawString = String(data: data, encoding: .utf8) {
                    print("⚠️ Raw Response for \(endpoint): \(rawString)")
                }
                print("Decode Error for \(endpoint): \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func action<T: Codable>(endpoint: String, method: String = "POST", body: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
            
        let baseUrl = "https://api.vrchat.cloud/api/1/"
        guard let url = URL(string: baseUrl + endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("vrctool/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    print("⚠️ 401 Unauthorized: Session Expired")
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .logoutRequired, object: nil)
                    }
                    
                    completion(.failure(NSError(domain: "Unauthorized", code: 401)))
                    return
                }
            }
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                completion(.failure(NSError(domain: "Error", code: 0)))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }
            do {
                if T.self == String.self {
                    let str = String(data: data, encoding: .utf8) ?? "Success"
                    completion(.success(str as! T))
                } else {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                }
            } catch {
                print("Decode Error: \(error)")
                if let rawStr = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(rawStr)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func fetchAll<T: Codable>(
        endpoint: String,
        baseQueryItems: [URLQueryItem] = [],
        offset: Int = 0,
        limit: Int = 100,
        maxItems: Int = 1500,
        accumulated: [T] = [],
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        var query = baseQueryItems
        query.removeAll { $0.name == "n" || $0.name == "offset" }
        query.append(URLQueryItem(name: "n", value: "\(limit)"))
        query.append(URLQueryItem(name: "offset", value: "\(offset)"))
        
        request(endpoint: endpoint, queryItems: query) { (result: Result<[T], Error>) in
            switch result {
            case .success(let items):
                var newAccumulated = accumulated
                newAccumulated.append(contentsOf: items)
                
                if items.count < limit || newAccumulated.count >= maxItems{
                    completion(.success(newAccumulated))
                } else {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        fetchAll(
                            endpoint: endpoint,
                            baseQueryItems: baseQueryItems,
                            offset: offset + limit,
                            limit: limit,
                            maxItems: maxItems,
                            accumulated: newAccumulated,
                            completion: completion
                        )
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func fetchAllFriendsCombined(completion: @escaping (Result<[User], Error>) -> Void) {
        let group = DispatchGroup()
        var allUsers: [User] = []
        var fetchError: Error?
        
        // 排他制御用 (複数のスレッドから配列を書き換えるため)
        let lock = NSLock()
        
        // 1. オンライン取得 (offline=false)
        group.enter()
        let onlineQuery = [URLQueryItem(name: "offline", value: "false")]
        
        // 汎用fetchAllを使用 (<[User]>型を指定)
        fetchAll(endpoint: "auth/user/friends", baseQueryItems: onlineQuery) { (result: Result<[User], Error>) in
            switch result {
            case .success(let users):
                lock.lock()
                allUsers.append(contentsOf: users)
                lock.unlock()
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }
        
        // 2. オフライン含む全件取得 (offline=true)
        // ※APIの仕様上、ここだけでも全件取れる場合もありますが、オンライン状態の正確性を期すために両方取得してマージするのが確実です
        group.enter()
        let offlineQuery = [URLQueryItem(name: "offline", value: "true")]
        
        fetchAll(endpoint: "auth/user/friends", baseQueryItems: offlineQuery) { (result: Result<[User], Error>) in
            switch result {
            case .success(let users):
                lock.lock()
                allUsers.append(contentsOf: users)
                lock.unlock()
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }
        
        // 3. 両方終わったら通知
        group.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
            } else {
                // 重複除去 (IDをキーにしてユニークにする)
                // Dictionary(grouping:...)を使うと簡単にIDごとにまとめられます
                let uniqueUsers = Array(
                    Dictionary(grouping: allUsers, by: { $0.id })
                        .compactMap { $0.value.first } // 各IDの最初の1つだけ取り出す
                )
                
                completion(.success(uniqueUsers))
            }
        }
    }
}
