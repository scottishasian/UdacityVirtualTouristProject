//
//  PhotoDataParser.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 02/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import Foundation

struct PhotosDataParser: Codable {
    //Needs to be photos, no data was found under the name photoData.
    let photos: PhotoData
}

struct PhotoData: Codable {
    let pages: Int
    let photo: [PhotoParser]
}

struct PhotoParser: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_m"
        case title
    }
}
