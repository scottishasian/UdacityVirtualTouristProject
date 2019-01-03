//
//  DataClient.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 02/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import UIKit

class DataClient {
    
    var session = URLSession.shared
    
    class func sharedInstance() -> DataClient {
        struct SingletonClass {
            static var sharedInstance = DataClient()
        }
        return SingletonClass.sharedInstance
    }
    
    //For searching via map pin
    func searchBy(latitude: Double, longitude: Double, totalPages: Int?, completion: @escaping( _ result: PhotosDataParser?, _ error: Error?) -> Void) {
        
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 4000/Constants.FlickrParameterValues.PhotosPerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        
    }
    
    //Now needs to take in lat long parameters as no search fields.
    private func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
            let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    
}
