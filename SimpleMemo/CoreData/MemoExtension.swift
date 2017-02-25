//
//  MemoExtension.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation
import CoreData

extension Memo {
  static func newMemo() -> Memo {
    let context = CoreDataStack.default.managedContext
    let entityDescription = NSEntityDescription.entity(forEntityName: "Memo", in: context)
    let memo = Memo(entity: entityDescription!, insertInto: context)
    memo.createDate = Date()
    memo.isUpload = false
    return memo
  }
}
