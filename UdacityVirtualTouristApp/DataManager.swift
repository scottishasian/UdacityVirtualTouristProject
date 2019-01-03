//
//  DataManager.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 03/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import CoreData

class DataManager {
    
    //Hold persistant container instance.
    let persistantContainer: NSPersistentContainer
    
    //Conveniece property to access context.
    var viewContext: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext!
    
    init(modelName: String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContexts() {
        backgroundContext = persistantContainer.newBackgroundContext()
        
        //Peer contexts.
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        //Setting merge policies so app doesn't crash if there is a conflict.
        //Authoratative version of data, prefers own property values in case of conflict.
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        //In case of conflict, it preferes property values from the persistant store.
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil)  {
        //Optional closure.
        persistantContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
            //Can load the store.
            }
    }
}

extension DataManager {
    
    //autosave feature
    func autoSaveViewContext(interval: TimeInterval = 30) {
        print("Auto-saving")
        guard interval > 0 else {
            print("Can not set negative autosave intervals")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
