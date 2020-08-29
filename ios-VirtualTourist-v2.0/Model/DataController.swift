//
//  DataController.swift
//  ios-VirtualTourist
//
//  Created by Abdullah Khayat on 8/27/20.
//  Copyright © 2020 Abdullah Khayat. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistenceContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        persistenceContainer.viewContext
    }
    var backgroundContext: NSManagedObjectContext {
        persistenceContainer.newBackgroundContext()
    }
    
    init(modelName: String) {
        persistenceContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil )  {
        
        persistenceContainer.loadPersistentStores { (storeDescription, error) in
            
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            self.configureContexts()
            
            completion?()
        }
    }
    
    func configureContexts() {
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    func autosave() {
        
        // save every 30 Seconds
        let interval: TimeInterval = 30
        viewContext.hasChanges ? try? viewContext.save() : print("error in autosave")
        DispatchQueue.main.asyncAfter(deadline: .now()+interval) {
            self.autosave()
        }
    }
    
}
