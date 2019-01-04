//
//  Pin+Extension.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 04/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import Foundation
import CoreData

//https://www.hackingwithswift.com/read/38/4/creating-an-nsmanagedobject-subclass-with-xcode
extension Pin {
    
    static let pinName = "Pin"
    
    //Needed to initialise saved pins.
    convenience init(latitude: String, longitude: String, context: NSManagedObjectContext) {
        if let savedEntity = NSEntityDescription.entity(forEntityName: Pin.pinName, in: context) {
            self.init(entity: savedEntity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Entity name not found")
        }
    }
}
