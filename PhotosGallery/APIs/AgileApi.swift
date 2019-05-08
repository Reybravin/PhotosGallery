//
//  AgileApi.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import Foundation

struct AgileApi {
    
    static func fetchImagesList(page: Int, completion: @escaping (_ result: Result<PicturesResponse, Error>)->Void){
        
        let urlString = "http://195.39.233.28:8035/images"
        
        var urlComponents = URLComponents(string: urlString)
        if page != 1 {
            let queryItem = URLQueryItem(name: "page", value: String(page))
            urlComponents?.queryItems = [queryItem]
        }
        let url = urlComponents?.url
        let headers = ["Authorization" : "7456af052cd839e9d4f6f33c35793b4ef276a195"]
        NetworkingService.shared.get(url: url, headers: headers, completion: completion)
    }
    
}
