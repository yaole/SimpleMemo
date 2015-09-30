//
//  MemoInterFaceController+WCSession.swift
//  Memo
//
//  Created by  李俊 on 15/9/27.
//  Copyright © 2015年  李俊. All rights reserved.
//

import WatchConnectivity
import UIKit

extension MemoInterfaceController: WCSessionDelegate {
    
    func sharedSession() -> WCSession? {
        
        let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
        
        session?.delegate = self
        session?.activateSession()
        
        return session
        
    }
    
    func shareMessage(message: [String : AnyObject]){
      if let session = sharedSession() where session.reachable {
        
        session.sendMessage(message, replyHandler: { (replyData) -> Void in
          
          }, errorHandler: { (error) -> Void in
            
        })
        
      }else{
        do {
            try sharedSession()?.updateApplicationContext(message)
        }catch {
            
        }
      }
      
    }
  
  func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      
      self.readSharedMemos(message)
      
    }
  }
  
  
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
      
      readSharedMemos(applicationContext)
     
    }
  
  func readSharedMemos(sharedMemos: [String : AnyObject]){
    
    let sharedMemo = sharedMemos["sharedMemos"] as? [[String : AnyObject]]
    
    if sharedMemo == nil {
      
      self.memos.insert(sharedMemos, atIndex: 0)
      
    }else{
      
      self.memos = sharedMemo!
      sharedDefaults?.setObject(memos, forKey: "WatchMemo")
      sharedDefaults?.synchronize()
      
    }
    self.setTable()
    
  }
  
}
