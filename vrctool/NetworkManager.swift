import Foundation

struct NetworkManager {
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
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                let errorCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: errorCode)
                print("Server error with code: \(errorCode), message: \(errorMessage)")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
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
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                let errorCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: errorCode)
                print("Server error with code: \(errorCode), message: \(errorMessage)")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
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
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                let errorCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: errorCode)
                print("Server error with code: \(errorCode), message: \(errorMessage)")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
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
