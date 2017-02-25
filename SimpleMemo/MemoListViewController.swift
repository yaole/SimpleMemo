//
//  MemoListViewController.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import UIKit

class MemoListViewController: MemoCollectionViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView?.backgroundColor = .white
    title = "易便签"
  }

}
