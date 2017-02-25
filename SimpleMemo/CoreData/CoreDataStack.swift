//
//  CoreDataStack.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

  static let `default` = CoreDataStack()

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "SimpleMemo")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  lazy var managedContext: NSManagedObjectContext = {
    return self.persistentContainer.viewContext
  }()

  func saveContext () {
    if managedContext.hasChanges {
      do {
        try managedContext.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

}

extension CoreDataStack {

  func createMemo() -> Memo {
    let entityDescription = NSEntityDescription.entity(forEntityName: "Memo", in: managedContext)
    let memo = Memo(entity: entityDescription!, insertInto: managedContext)
    memo.createDate = Date()
    memo.isUpload = false
    return memo
  }
}
