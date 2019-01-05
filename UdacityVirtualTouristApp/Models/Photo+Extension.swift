//
//  Photo+Extension.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 05/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import Foundation
import CoreData

//https://www.hackingwithswift.com/read/38/4/creating-an-nsmanagedobject-subclass-with-xcode
//Similar set up as Pin
extension Photo {
    
    static let photoName = "Photo"
    
    //Needed to initialise saved photos.
    convenience init(title: String, imageURL: String, selectedPin: Pin, context: NSManagedObjectContext) {
        if let savedEntity = NSEntityDescription.entity(forEntityName: Photo.photoName, in: context) {
            self.init(entity: savedEntity, insertInto: context)
            self.title = title
            self.image = nil
            self.imageURL = imageURL
            self.pin = selectedPin
        } else {
            fatalError("Entity name not found")
        }
    }
}
