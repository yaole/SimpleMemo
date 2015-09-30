//
//  MemoListViewController+WCSession.swift
//  Memo
//
//  Created by  李俊 on 15/9/27.
//  Copyright © 2015年  李俊. All rights reserved.
//

import WatchConnectivity
import UIKit

@available(iOS 9.0, *)
extension MemoListViewController: WCSessionDelegate {
    
    func wcSession() -> WCSession? {
        
        let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
        
        session?.delegate = self
        session?.activateSession()
        
        return session

    }
    
    func shareMessage(message: [String : AnyObject]){
      
      if let session = wcSession() where session.reachable {
        
       session.sendMessage(message, replyHandler: { (replyData) -> Void in
        
        }, errorHandler: { (error) -> Void in
          
       })
        
      }else{
      
        do {
            try wcSession()?.updateApplicationContext(message)
        }catch {
            
        }
      }
  }
  
      func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
          
          
          CoreDataStack.shardedCoredataStack.addMemo(message)
          
        }
      }
      
  
      func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        
        CoreDataStack.shardedCoredataStack.addMemo(applicationContext)
        
      }
  
//      func readSharedMemos(sharedMemos: [String : AnyObject]){
//        
//        CoreDataStack.shardedCoredataStack.addMemo(sharedMemos)
//        
//      }
    
}
