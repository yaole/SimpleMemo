//
//  MemoViewController.swift
//  EverMemo
//
//  Created by  李俊 on 15/8/5.
//  Copyright (c) 2015年  李俊. All rights reserved.
//

import UIKit
import CoreData
import EvernoteSDK

class MemoViewController: UIViewController, UITextViewDelegate {

  var memo: Memo?

  fileprivate let textView = UITextView()
  fileprivate var textViewBottomConstraint: NSLayoutConstraint?
  fileprivate var sharedItem: UIBarButtonItem!
  fileprivate var isTextChanged = false

  override func viewDidLoad() {
    super.viewDidLoad()

    setUI()
    setTextView()
    textViewAttrubt()

    NotificationCenter.default.addObserver(self, selector: #selector(changeLayOut(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
  }

  // MARK: - 监听键盘的改变
  func changeLayOut(_ notification: Notification) {
    let keyboarFrame: CGRect? = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
    let keyboardY = keyboarFrame?.origin.y ?? 0
    textViewBottomConstraint!.constant = -(view.bounds.size.height - keyboardY + 5)
  }

  // MARK: - 设置视图控件
  fileprivate func setUI() {
    view.backgroundColor = UIColor.white
    sharedItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(MemoViewController.perpormShare(_:)))
    navigationItem.rightBarButtonItem = sharedItem
    if memo == nil {
      title = "新便签"
      textView.becomeFirstResponder()
      sharedItem.isEnabled = false
    } else {
      textView.text = memo!.text
    }
  }

  /// 分享
  func perpormShare(_ barButton: UIBarButtonItem) {
    let activityController = UIActivityViewController(activityItems: [textView.text], applicationActivities: nil)
    let drivce = UIDevice.current
    let model = drivce.model
    if model == "iPhone Simulator" || model == "iPhone" || model == "iPod touch"{
      present(activityController, animated: true, completion: nil)
    } else {
      let popoverView =  UIPopoverController(contentViewController: activityController)
      popoverView.present(from: barButton, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
    }
  }

  fileprivate func setTextView() {
    textView.delegate = self
    textView.layoutManager.allowsNonContiguousLayout = false
    textView.keyboardDismissMode = .interactive
    textView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(textView)

    view.addConstraint(NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
    view.addConstraint(NSLayoutConstraint(item: textView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 5))
    view.addConstraint(NSLayoutConstraint(item: textView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -5))
    view.addConstraint(NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -5))
    let constraints = view.constraints
    textViewBottomConstraint = constraints.last
  }

  fileprivate func textViewAttrubt() {
    let paregraphStyle = NSMutableParagraphStyle()
    paregraphStyle.lineSpacing = 5
    let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSParagraphStyleAttributeName: paregraphStyle]
    textView.typingAttributes = attributes
    textView.font = UIFont.systemFont(ofSize: 16)
  }

  // MARK: - 视图消失时,
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true)
    if let memo = memo, textView.text.isEmpty {
      ENSession.shared.deleteFromEvernote(with: memo)
      CoreDataStack.default.managedContext.delete(memo)
    }
    CoreDataStack.default.saveContext()
  }

  // MARK: - UITextViewDelegate

  func textViewDidChange(_ textView: UITextView) {
    isTextChanged = true
    memo?.isUpload = false
    sharedItem.isEnabled = !textView.text.isEmpty
    memo = memo ?? Memo.newMemo()
    memo!.text = textView.text
    memo!.updateDate = Date()
    CoreDataStack.default.saveContext()
  }

}
