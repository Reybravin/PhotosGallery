//
//  TokenResponse.swift
//  PhotosGallery
//
//  Created by SS on 5/10/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import Foundation

struct TokenResponse : Decodable {
    var token : String
}

struct TokenRequest : Encodable {
    var apiKey : String
}
