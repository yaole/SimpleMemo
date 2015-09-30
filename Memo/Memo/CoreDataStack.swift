//
//  CoreDataStack.swift
//  EverMemo
//
//  Created by  李俊 on 15/8/5.
//  Copyright (c) 2015年  李俊. All rights reserved.
//

import CoreData

class CoreDataStack: NSObject {
    
    static let shardedCoredataStack:CoreDataStack = CoreDataStack()
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.likumb.EverMemo" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Memo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Memo.sqlite")
      var failureReason = "There was an error creating or loading the application's saved data."
      do {
        try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
      } catch {
        // Report any error we got.
        var dict = [String: AnyObject]()
        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
        dict[NSLocalizedFailureReasonErrorKey] = failureReason
        
        dict[NSUnderlyingErrorKey] = error as NSError
        let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        abort()
      }
      
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
  func saveContext () {
    if managedObjectContext!.hasChanges {
      do {
        try managedObjectContext!.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
      }
    }
  }
    func creatMemo() -> Memo {
      
        let context = CoreDataStack.shardedCoredataStack.managedObjectContext
        
        let entityDescription = NSEntityDescription.entityForName("Memo", inManagedObjectContext:context!)
        let note = Memo(entity: entityDescription!, insertIntoManagedObjectContext: context)
        
        note.changeDate = NSDate()
        
        note.isUpload = false
        
        return note
    }
    
    func fetchAndSaveNewMemos(){
        
        let sharedDefaults = NSUserDefaults(suiteName: "group.likumb.com.Memo")
        
        let dict =  sharedDefaults?.objectForKey("MemoContent") as? [[String: AnyObject]]
        
        if let contents = dict {
            
            for content in contents {
                
                addMemo(content)
                
            }
            
            sharedDefaults?.removeObjectForKey("MemoContent")
            
        }
        
    }
  
  func addMemo(dic: [String: AnyObject]){
    let memo = CoreDataStack.shardedCoredataStack.creatMemo()
    
    memo.text = dic["text"] as! String
    
    memo.changeDate = dic["changeDate"] as! NSDate
    
    CoreDataStack.shardedCoredataStack.saveContext()
    
  }


  
}
