//
//  MemoListViewController+PreView.swift
//  Memo
//
//  Created by  李俊 on 15/9/26.
//  Copyright © 2015年  李俊. All rights reserved.
//

import UIKit

extension MemoListViewController: UIViewControllerPreviewingDelegate {
  
  func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    
    guard let indexPath = collectionView?.indexPathForItemAtPoint(location), cell = collectionView?.cellForItemAtIndexPath(indexPath) else { return nil }
    
    let detailViewController = MemoViewController()
    
    var memo: Memo!
    if isSearching{
      
      memo = searchResults[indexPath.row]
      
      didSelectedSearchResultIndexPath = indexPath
      
    }else{
      memo = fetchedResultsController?.objectAtIndexPath(indexPath) as! Memo
    }
    
    detailViewController.preferredContentSize = CGSize(width: 0.0, height: 350)
    
    if #available(iOS 9.0, *) {
        previewingContext.sourceRect = cell.frame
    } else {
        // Fallback on earlier versions
    }
    
    detailViewController.memo = memo
    
    return detailViewController
  }
  
  func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
    
    showViewController(viewControllerToCommit, sender: self)
  }
  
  
  
}
