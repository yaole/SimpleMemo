//
//  Memo+CoreDataProperties.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation
import CoreData
import EvernoteSDK

extension Memo {

  public class func defaultRequest() -> NSFetchRequest<Memo> {
    return NSFetchRequest<Memo>(entityName: "Memo");
  }

  @NSManaged public var text: String?
  @NSManaged public var noteRef: ENNoteRef?
  @NSManaged public var isUpload: Bool
  @NSManaged public var createDate: Date?
  @NSManaged public var updateDate: Date?

}
