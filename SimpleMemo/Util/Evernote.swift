//
//  Evernote.swift
//  SimpleMemo
//
//  Created by  李俊 on 2017/2/25.
//  Copyright © 2017年 Lijun. All rights reserved.
//

import Foundation
import EvernoteSDK

extension ENSession {

  /// 上传便签到印象笔记
  func uploadMemoToEvernote(_ memo: Memo) {
    if self.isAuthenticated == false {
      return
    }
    guard let text = memo.text, text.characters.count > 0 else {
      return
    }

    let note = ENNote()
    note.title = text.fetchTitle()
    note.content = ENNoteContent(string: text)

    if memo.noteRef == nil {
      self.upload(note, notebook: nil, completion: { (noteRef, error) -> Void in
        if noteRef != nil {
          memo.noteRef = noteRef
          memo.isUpload = true
          CoreDataStack.default.saveContext()
        }
      })
    } else {
      self.upload(note, policy: .replaceOrCreate, to: nil, orReplace: memo.noteRef, progress: nil, completion: { (noteRef, error) -> Void in
        if noteRef != nil {
          memo.noteRef = noteRef
          memo.isUpload = true
          CoreDataStack.default.saveContext()
        }
      })
    }
  }

  /// 删除印象笔记中的便签
  func deleteFromEvernote(with memo: Memo) {
    if memo.noteRef == nil || !ENSession.shared.isAuthenticated {
      return
    }

    ENSession.shared.delete(memo.noteRef!, completion: { (error) -> Void in
      if error != nil {
        printLog(message: error.debugDescription)
      }
    })
  }

}
