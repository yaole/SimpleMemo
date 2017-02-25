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

private let backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)

class MemoListViewController: MemoCollectionViewController {

  fileprivate lazy var searchView = UIView()
  fileprivate var isSearching: Bool = false
  fileprivate lazy var searchResults = [Memo]()
  fileprivate lazy var searchBar = UISearchBar()
  fileprivate var didSelectedSearchResultIndexPath: IndexPath? // 被选中的搜索结果的索引

  fileprivate lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "便签"
    label.font = UIFont.systemFont(ofSize: 17)
    label.sizeToFit()
    return label
  }()

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
    controller.delegate = self
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
    collectionView?.backgroundColor = backgroundColor
    collectionView?.register(MemoCell.self, forCellWithReuseIdentifier: String(describing: MemoCell.self))
    setNavigationBar()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if ENSession.shared.isAuthenticated {
      uploadMemoToEvernote()
    }
  }

}

// MARK: - UICollectionViewDataSource Delegate

extension MemoListViewController {

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (isSearching ? searchResults.count :
      fetchedResultsController.fetchedObjects?.count ?? 0)
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    // swiftlint:disable:next force_cast
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MemoCell.self), for: indexPath) as! MemoCell

    let memo = isSearching ? searchResults[indexPath.row] : fetchedResultsController.object(at: indexPath)
    cell.memo = memo
    cell.deleteMemo = { memo in
      let alert = UIAlertController(title: "删除便签", message: nil, preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
      alert.addAction(UIAlertAction(title: "删除", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
        // TODO: delete handle
      }))
      self.present(alert, animated: true, completion: nil)
    }
    return cell
  }

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    searchBar.resignFirstResponder()
    var memo: Memo
    if isSearching {
      memo = searchResults[indexPath.row]
      didSelectedSearchResultIndexPath = indexPath
    } else {
      memo = fetchedResultsController.object(at: indexPath)
    }

    let MemoView = MemoViewController()
    MemoView.memo = memo
    navigationController?.pushViewController(MemoView, animated: true)
  }
}

private extension MemoListViewController {

  func setNavigationBar() {
    navigationItem.titleView = titleLabel
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
        } else {
          printLog(message: error.debugDescription)
        }
      })
    }
  }

  /// 搜索
  @objc func search() {
    navigationItem.rightBarButtonItems?.removeAll(keepingCapacity: true)
    navigationItem.leftBarButtonItems?.removeAll(keepingCapacity: true)
    searchBar.searchBarStyle = .minimal
    searchBar.setShowsCancelButton(true, animated: true)
    searchBar.delegate = self
    searchBar.backgroundColor = backgroundColor
    navigationItem.titleView = searchView
    searchView.frame = navigationController!.navigationBar.bounds
    searchView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    searchView.addSubview(searchBar)

    var margin: CGFloat = 0
    let deviceModel = UIDevice.current.model
    if deviceModel == "iPad" || deviceModel == "iPad Simulator" {
      margin = 30
    } else {
      margin = 10
    }

    searchBar.frame = CGRect(x: 0, y: 0, width: searchView.bounds.width - margin, height: searchView.bounds.height)
    searchBar.becomeFirstResponder()
    isSearching = true
    if !searchBar.text!.isEmpty {
      fetchSearchResults(searchBar.text!)
    }
    collectionView?.reloadData()
  }

  /// 新memo
  @objc func addMemo() {
    navigationController?.pushViewController(MemoViewController(), animated: true)
  }

}

// MARK: - UISearchBarDelegate

extension MemoListViewController: UISearchBarDelegate {

  fileprivate func fetchSearchResults(_ searchText: String) {
    let request = Memo.defaultRequest()
    request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", searchText)
    let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
    request.sortDescriptors = [sortDescriptor]
    var results: [AnyObject]?
    do {
      results = try CoreDataStack.default.managedContext.fetch(request)
    } catch {
      if let error = error as NSError? {
        printLog(message: "\(error.userInfo)")
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }

    if let resultMemos = results as? [Memo] {
      searchResults = resultMemos
    }
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    fetchSearchResults(searchText)
    collectionView?.reloadData()
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchView.removeFromSuperview()
    setNavigationBar()
    isSearching = false
    searchResults.removeAll(keepingCapacity: false)
    collectionView?.reloadData()
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }

}

// MARK: - NSFetchedResultsControllerDelegate

extension MemoListViewController: NSFetchedResultsControllerDelegate {

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    // 如果处于搜索状态, 内容更新了,就重新搜索,重新加载数据
    if isSearching, let searchText = searchBar.text {
      fetchSearchResults(searchText)
      collectionView?.reloadData()
      return
    }

    switch type {
    case .insert:
      collectionView?.insertItems(at: [newIndexPath!])
    case .update:
      collectionView?.reloadItems(at: [indexPath!])
    case .delete:
      collectionView?.deleteItems(at: [indexPath!])
    case .move:
      collectionView?.moveItem(at: indexPath!, to:newIndexPath!)
      collectionView?.reloadItems(at: [newIndexPath!])
    }
  }

}

// MARK: - Evernote

private extension MemoListViewController {

  func uploadMemoToEvernote() {
    // 取出所有没有上传的memo
    let predicate = NSPredicate(format: "isUpload == %@", false as CVarArg)
    let request = Memo.defaultRequest()
    request.predicate = predicate
    var results: [AnyObject]?
    do {
      results = try CoreDataStack.default.managedContext.fetch(request)
    } catch {
      printLog(message: error.localizedDescription)
    }

    if let unUploadMemos = results as? [Memo] {
      for unUploadMemo in unUploadMemos {
        ENSession.shared.uploadMemoToEvernote(unUploadMemo)
      }
    }
  }

}
