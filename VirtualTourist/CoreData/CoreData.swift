//
//  CoreData.swift
//  VirtualTourist
//
//  Created by Raghad Almatrodi on 1/31/19.
//  Copyright © 2019 raghad almatrodi. All rights reserved.
//

import Foundation
import CoreData

class CoreData {
    
    let persistentContainer:NSPersistentContainer
    
    static let shared = CoreData()
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "dataModel")
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
