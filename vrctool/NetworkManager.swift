import Foundation

struct NetworkManager {
    static func login(loginId: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
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
                completion(.success(()))
            } else {
                let errorMessage = "Login failed with status code: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }
        task.resume()
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
    
    static func fetchInstance(instanceId: String, completion: @escaping (Result<Instance2, Error>) -> Void) {
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
                let instance = try JSONDecoder().decode(Instance2.self, from: data)
                completion(.success(instance))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
