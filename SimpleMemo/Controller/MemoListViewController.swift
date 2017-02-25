//
//  MemoListViewController.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import UIKit
import CoreData
import EvernoteSDK

class MemoListViewController: MemoCollectionViewController {

  fileprivate lazy var addItem: UIBarButtonItem = {
    let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addMemo))
    return item
  }()

  fileprivate lazy var evernoteItem: UIBarButtonItem = {
    let item = UIBarButtonItem(image: UIImage(named: "ENActivityIcon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(evernoteAuthenticate))
    return item
  }()

  fileprivate lazy var searchItem: UIBarButtonItem = {
    let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(search))
    return item
  }()

  lazy var fetchedResultsController: NSFetchedResultsController<Memo> = {
    let request = Memo.defaultRequest()
    let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
    request.sortDescriptors = [sortDescriptor]
    let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.default.managedContext, sectionNameKeyPath: nil, cacheName: nil)
    return controller
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    do {
      try fetchedResultsController.performFetch()
    } catch {
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    collectionView?.backgroundColor = .white
    collectionView?.register(MemoCell.self, forCellWithReuseIdentifier: String(describing: MemoCell.self))
    title = "便签"
    setNavigationBar()
  }

}

// MARK: - UICollectionViewDataSource Delegate
extension MemoListViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.fetchedObjects?.count ?? 0
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    // swiftlint:disable:next force_cast
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

private extension MemoListViewController {
  func setNavigationBar() {
    navigationItem.rightBarButtonItems = [addItem]
    evernoteItem.tintColor = ENSession.shared.isAuthenticated ? UIColor(red: 23/255.0, green: 127/255.0, blue: 251/255.0, alpha: 1) : UIColor.gray
    navigationItem.leftBarButtonItems = [evernoteItem, searchItem]
  }

  /// 印象笔记登录注销
  @objc func evernoteAuthenticate() {
    if ENSession.shared.isAuthenticated {
      let alert = UIAlertController(title: "退出印象笔记?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
      alert.addAction(UIAlertAction(title: "退出", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
        ENSession.shared.unauthenticate()
        self.evernoteItem.tintColor = UIColor.gray
      }))
      present(alert, animated: true, completion: nil)
    } else {
      ENSession.shared.authenticate(with: self, preferRegistration: false, completion: { error in
        if error == nil {
          self.evernoteItem.tintColor = UIColor(red: 23/255.0, green: 127/255.0, blue: 251/255.0, alpha: 1)
        }
      })
    }
  }

  /// 搜索
  @objc func search() {

  }

  /// 新memo
  @objc func addMemo() {

  }

}
