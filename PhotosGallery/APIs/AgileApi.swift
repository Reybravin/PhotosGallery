//
//  AgileApi.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import Foundation

struct AgileApi {
    
    static let shared = AgileApi()
    
    private let urlSession = URLSession(configuration: .default)

    private init(){}
    
    let apiKey = "23567b218376f79d9415"
    
    private enum API {
        static let baseUrl = URL(string:"http://195.39.233.28:8035")!
        static let authUrl = API.baseUrl.appendingPathComponent("/auth")
        static let imagesUrl = API.baseUrl.appendingPathComponent("/images")
    }
    
    private let keychain = KeychainSwift(keyPrefix: "PhotosGallery_")
    
    private enum Keychain {
        static let accessTokenKey = "AccessToken"
    }
    
    public func storeAccessToken(_ accessToken: String) -> Bool {
        return keychain.set(accessToken, forKey: Keychain.accessTokenKey)
    }
    
    public func retrieveAccessToken() -> String? {
        return keychain.get(Keychain.accessTokenKey)
    }
    
    //MARK: - Login
    
    func authenticateUser(completion: @escaping (_ result: Result<Bool,Error>)->Void) {
        
        let urlString = "http://195.39.233.28:8035/auth"
        //let authURL = API.authUrl
        //print(authURL)
        
        guard let authURL = URL(string: urlString) else {
            //failure?(NetworkError.invalidUrl)
            return
        }
        
        var request = URLRequest(url: authURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = ["apiKey" : apiKey]
        guard let jsonData = try? JSONEncoder().encode(parameters) else { return }
        request.httpBody = jsonData
        
        urlSession.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let data = data, let text = String(data: data, encoding: .utf8) {
                
                print(text)
                
                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    print("token:", tokenResponse)
                    self.storeAccessToken(tokenResponse.token)
                    completion(.success(true))
                    
                } catch let error{
                    
                    print(error)
                    
                }

            }
            }.resume()
    }
    
    public var isAuthenticated: Bool {
        return retrieveAccessToken() != nil
    }

    
    //MARK: - Fetching data
    
    public func fetchImagesList(page: Int, completion: @escaping (_ result: Result<PicturesResponse, Error>)->Void){
        
        guard let token = AgileApi.shared.retrieveAccessToken() else {
            completion(.failure(NetworkError.noToken))
            return
        }
        
        //let urlString = "http://195.39.233.28:8035/images"
        //var urlComponents = URLComponents(string: urlString)
        
        let imagesUrl = API.imagesUrl
        var urlComponents = URLComponents(url: imagesUrl, resolvingAgainstBaseURL: true)
        
        if page != 1 {
            let queryItem = URLQueryItem(name: "page", value: String(page))
            urlComponents?.queryItems = [queryItem]
        }
        let url = urlComponents?.url
        let headers = ["Authorization" : token]
        NetworkingService.shared.get(url: url, headers: headers, completion: completion)
    }
    
}
