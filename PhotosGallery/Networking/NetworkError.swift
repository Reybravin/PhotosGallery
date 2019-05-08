//
//  NetworkError.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import Foundation

enum NetworkError : String, Error {
    case invalidUrl = "Invalid URL."
    case dataParsingError = "Error parsing data"
    case decodingFailed = "Error decoding data."
    case encodingFailed = "Error encoding parameters"
    case genericError = "General network error."
    case noToken = "Missing Access token is missing"
}

extension NetworkError : LocalizedError {
    public var errorDescription: String? {
        return self.rawValue
    }
}
