//
//  DataManager.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 03/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import CoreData

class DataManager {
    
    //https://cocoacasts.com/setting-up-the-core-data-stack-from-scratch
    
    private let modelName: String
    let modelURL : URL
    var databaseURL : URL
    let managedObjectModel : NSManagedObjectModel
    let coordinator: NSPersistentStoreCoordinator
    let persistedCOntext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext!
    let pinContext: NSManagedObjectContext
    
    class func sharedInstance() -> DataManager {
        struct SingletonClass {
            static var sharedInstance = DataManager(modelName: "Virtual_Tourist_Model")
        }
        return SingletonClass.sharedInstance
    }
    
    init(modelName: String) {
        self.modelName = modelName
        
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Data model not found.")
        }
        self.modelURL = modelURL
        
        //Model is created from the URL
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Data model could not be loaded.")
        }
        self.managedObjectModel = managedObjectModel
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        persistedCOntext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistedCOntext.persistentStoreCoordinator = coordinator
        
        pinContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        pinContext.parent = persistedCOntext
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = pinContext
        
        //Access SQLite database. Has to be done in init as due to issues of being called before initialisation.
        //Only functional once the store is added to the coordinator.
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        guard let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            //Need to use .first as opposed to [0].
            fatalError("Folder could not be reached.")
        }
        self.databaseURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        //Database migration
        let migration = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: migration as [NSObject:AnyObject]?)
        } catch {
            fatalError("Persistant store not found.")
        }
    }

}

extension DataManager {
    
    //saving pin on placement
    //https://www.hackingwithswift.com/read/38/3/adding-core-data-to-our-project-nspersistentcontainer
    
    func savePinContext() throws {
        pinContext.performAndWait {
            if self.pinContext.hasChanges {
                do {
                    try self.pinContext.save()
                } catch {
                    print("\(error): Unable to save context.")
                }
                
                //Run background saving.
                self.persistedCOntext.perform {
                    do {
                        try self.persistedCOntext.save()
                    } catch {
                        print("\(error): Unable to save persisted context.")
                    }
                }
            }
        }
    }

    //autosave feature
//    func autoSaveViewContext(interval: TimeInterval = 30) {
//        print("Auto-saving")
//        guard interval > 0 else {
//            print("Can not set negative autosave intervals")
//            return
//        }
//        if viewContext.hasChanges {
//            try? viewContext.save()
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
//            self.autoSaveViewContext(interval: interval)
//        }
//    }
}
