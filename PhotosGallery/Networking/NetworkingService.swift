//
//  NetworkingService.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import UIKit

public enum HTTPMethod: String {
    case get = "GET", post = "POST", delete = "DELETE", put = "PUT"
}

//struct API {
//    static let baseURL = ""
//}

public enum StatusCodes : Int {
    case successs = 200
    case authError = 401
}

struct NetworkingService {
    
    static let shared = NetworkingService()
    
    private init(){}
    
    private let urlSession = URLSession(configuration: .default)
    
    typealias NetworkCompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    // MARK: Types
    
    /// Empty success handler.
    public typealias EmptySuccessHandler = () -> Void
    
    /// Success handler.
    public typealias SuccessHandler<T> = (_ data: T) -> Void
    
    /// Failure handler.
    public typealias FailureHandler = (_ error: Error) -> Void
    
    private enum Keychain {
        static let accessTokenKey = "AccessToken"
    }

    
//    func request<T: Decodable>(_ endpoint: String,
//                               method: HTTPMethod = .get,
//                               parameters: Parameters = [:],
//                               success: SuccessHandler<T>?,
//                               failure: FailureHandler?) {
//
//        let urlRequest = buildURLRequest(endpoint, method: method, parameters: parameters)
//
//        urlSession.dataTask(with: urlRequest) { data, _, error in
//            if let data = data {
//                DispatchQueue.global(qos: .utility).async {
//                    do {
//                        let jsonDecoder = JSONDecoder()
//                        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//                        let object = try jsonDecoder.decode(T.self, from: data)
//
//                        if let data = object.data {
//                            DispatchQueue.main.async {
//                                success?(data)
//                            }
//                        } else if let message = object.meta.errorMessage {
//                            DispatchQueue.main.async {
//                                //failure?(Netw.invalidRequest(message: message))
//                            }
//                        }
//                    } catch let error {
//                        DispatchQueue.main.async {
//                            //failure?(InstagramError.decoding(message: error.localizedDescription))
//                        }
//                    }
//                }
//            } else if let error = error {
//                failure?(error)
//            }
//            }.resume()
//    }
//
//    private func buildURLRequest(_ endpoint: String, method: HTTPMethod, parameters: Parameters) -> URLRequest {
//
//        let url = URL(string: API.baseURL + endpoint)!.appendingQueryParameters(["access_token": ""])
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = method.rawValue
//
//        switch method {
//        case .get, .delete:
//            urlRequest.url?.appendQueryParameters(parameters)
//        case .post, .put:
//            urlRequest.httpBody = Data(parameters: parameters)
//        }
//        return urlRequest
//    }
    
    //MARK: - Generic get request
    
    func get<T: Decodable>(url: URL?,
                           headers: [String: String],
                           completion: @escaping(_ result: Result<T, Error>) -> Void) {
        
        guard let url = url else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }
        
        let completionHandler: NetworkCompletionHandler = { (data, urlResponse, error) in
            
            print(urlResponse)
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let response = urlResponse as? HTTPURLResponse {
                
                let statusCode = response.statusCode
                
                switch statusCode {
                    
                case StatusCodes.successs.rawValue:
                    
                    guard let data = data else {
                        completion(.failure(NetworkError.dataParsingError))
                        return
                    }
                    
                    //let dataString = String(data: data, encoding: .utf8)
                    //print("dataString:", dataString)
                    
                    do {
                        let responseObject = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(responseObject))
                        return
                    } catch (let error){
                        print(error)
                        completion(.failure(NetworkError.decodingFailed))
                        return
                    }
                case StatusCodes.authError.rawValue:
                    completion(.failure(NetworkError.authError))
                    return
                    
                default:
                    completion(.failure(NetworkError.genericError))
                    return
                }
            }
            completion(.failure(NetworkError.noResponseError))
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
            .resume()
    }
    
    private func isSuccessCode(_ statusCode: Int) -> Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    private func isSuccessCode(_ response: URLResponse?) -> Bool {
        guard let urlResponse = response as? HTTPURLResponse else {
            return false
        }
        return isSuccessCode(urlResponse.statusCode)
    }
    
    
    func loadImage(urlString: String, completion: @escaping(_ image: UIImage?) -> Void) {
        
        print("loading image with url: " + urlString)
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        
        guard let encodedString = escapedString, let url = URL(string: encodedString) else {
            completion(nil)
            return
        }
        
        let completionHandler: NetworkCompletionHandler = { (data, _, _) in
            if let data = data {
                if let image = UIImage(data: data) {
                    completion(image)
                    return
                }
            }
            completion(nil)
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
            .resume()
    }
    
    
}


struct TokenResponse : Decodable {
    var token : String
}


struct TokenRequest : Encodable {
    var apiKey : String
}
