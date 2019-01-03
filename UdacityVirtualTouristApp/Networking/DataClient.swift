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
    func searchByLatLon(latitude: Double, longitude: Double, totalPages: Int?, completion: @escaping( _ result: PhotosDataParser?, _ error: Error?) -> Void) {
        
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 4000/Constants.FlickrParameterValues.DisplayedPhotos)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: longitude),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            //Path extension to api to limit displayed photos.
            Constants.FlickrParameterKeys.DisplayedPhotos : "\(Constants.FlickrParameterValues.DisplayedPhotos)",
            Constants.FlickrParameterKeys.Page : "\(page)"
        ]
        
        _ = taskForGetMethod(parameters: methodParameters) { (data, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                let errorInformation = [NSLocalizedDescriptionKey: "Data could not be retrieved"]
                completion(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: errorInformation))
                return
            }
            
            //Using try catch to parse data.
            do {
                let photosDataParser = try JSONDecoder().decode(PhotosDataParser.self, from: data)
                completion(photosDataParser, nil)
            } catch {
                print("error: \(error)")
                completion(nil, error)
            }
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
    
    // MARK: Helper for Creating a URL from Parameters
    private func flickrURLFromParameters(_ parameters: [String:String], withPathExtension : String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    //Used instead of displayImageFromFlickrBySearch method.
    func taskForGetMethod(_ method: String? = nil, parameters: [String:String], completionHandlerForGET: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = URLRequest(url: flickrURLFromParameters(parameters, withPathExtension: method))
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
             completionHandlerForGET(data, nil)
        }
        
        task.resume()
        
        return task
    }
}

