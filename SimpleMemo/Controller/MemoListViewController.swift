//
//  MemoListViewController.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import UIKit
import CoreData

class MemoListViewController: MemoCollectionViewController {

  lazy var fetchedResultsController: NSFetchedResultsController<Memo> = {
    let request = Memo.defaultRequest()
    let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
    request.sortDescriptors = [sortDescriptor]
    let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.default.managedContext, sectionNameKeyPath: nil, cacheName: nil)
    return controller
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    do{
      try fetchedResultsController.performFetch()
    }catch {
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    collectionView?.backgroundColor = .white
    collectionView?.register(MemoCell.self, forCellWithReuseIdentifier: String(describing: MemoCell.self))
    title = "便签"
  }

}

// MARK: - UICollectionViewDataSource Delegate
extension MemoListViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.fetchedObjects?.count ?? 0
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MemoCell.self), for: indexPath) as! MemoCell

    let memo = fetchedResultsController.object(at: indexPath)
    cell.memo = memo
    cell.deleteMemo = { memo in
      let alert = UIAlertController(title: "删除便签", message: nil, preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
      // .Destructive 需要谨慎操作的工作,文字会自动设为红色
      alert.addAction(UIAlertAction(title: "删除", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
        // TODO: delete handle
        
      }))
      self.present(alert, animated: true, completion: nil)
    }
    return cell
  }

}


