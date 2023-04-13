//
//  Utils+DB.swift
//  
//
//  Created by Miroslav Yozov on 1.12.20.
//

import Foundation
import CoreData

public extension NSManagedObject {
    static var entityName: String {
        String(describing: self)
    }
    
    static func entityDesc(in context: NSManagedObjectContext) -> NSEntityDescription {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        return Utils.unwrapOrFatalError(entity)
    }
}


extension Utils {
    public struct DB {
        public struct Configuration {
            public static var group = "group.bg.netinfo"
            public static var SQLiteFilename = ""
            public static var name = ""
        }
        
        public static let shared: DB = .init()
        
        private let container: NSPersistentContainer
        private var MOC: NSManagedObjectContext {
            container.viewContext
        }
        
        private init() {
            assert(!Configuration.group.isEmpty, "Set Utils.DB.Configuration.group before use!")
            assert(!Configuration.SQLiteFilename.isEmpty, "Set Utils.DB.Configuration.SQLiteFilename before use!")
            assert(!Configuration.name.isEmpty, "Set Utils.DB.Configuration.name before use!")
            
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Configuration.group) else {
                fatalError("Unknown container url for group: \(Configuration.group)")
            }
            
            let storeURL = containerURL.appendingPathComponent(Configuration.SQLiteFilename)
            let storeDesc: NSPersistentStoreDescription = .init(url: storeURL)
            storeDesc.shouldInferMappingModelAutomatically = true
            storeDesc.shouldMigrateStoreAutomatically = true
            
            container = NSPersistentContainer(name: Configuration.name)
            container.persistentStoreDescriptions = [storeDesc]
            container.loadPersistentStores(completionHandler: {
                if let error = $1 {
                    fatalError("Unable to load CoreData persistent store! \(error)")
                }
            })
        }
        
        public static func initialize() {
            let _ = shared
        }
        
        public static func instance<T: NSManagedObject>(forEntity name: String, save: Bool = true, init: ((NSManagedObjectContext) -> T) ) -> T {
            let MOC = shared.MOC
            let object = `init`(MOC)
            if save {
                MOC.performAndWait {
                    MOC.saveQuite()
                }
            }
            return object
        }
        
        public static func delete(object: NSManagedObject, save: Bool = true) {
            let MOC = shared.MOC
            MOC.performAndWait {
                MOC.delete(object)
                
                if save {
                    MOC.saveQuite()
                }
            }
        }
        
        public static func fetch<T>(_ request: NSFetchRequest<T>) -> [T] {
            var result = [T]()
            
            let MOC = shared.MOC
            MOC.performAndWait {
               result.append(contentsOf: MOC.fetchQuite(request))
            }
            
            return result
        }
        
        public static func save() {
            let MOC = shared.MOC
            MOC.performAndWait {
                MOC.saveQuite()
            }
        }
    }
}

public extension NSManagedObjectContext {
    func saveQuite() {
        guard hasChanges else { return }
        
        do {
            try save()
        } catch (let error) {
            let nserror = error as NSError
            Utils.Log.error("Unresolved error during save.", nserror, nserror.userInfo)
        }
    }
    
    func fetchQuite<T>(_ request: NSFetchRequest<T>) -> [T] {
        var result: [T]?
        
        do {
            try result = fetch(request)
        } catch (let error) {
            let nserror = error as NSError
            Utils.Log.error("Unresolved error during fetch.", nserror, nserror.userInfo)
        }
        
        return result ?? []
    }
}

