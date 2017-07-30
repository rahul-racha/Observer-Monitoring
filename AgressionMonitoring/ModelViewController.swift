//
//  ModelViewController.swift
//  AggressionMonitoring
//
//  Created by admin on 7/11/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

protocol CommentEntryDelegate: class {
    func commentTextEntered(comment: String)
}

class ModelViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var commentBox: UITextView!
    weak var delegate: CommentEntryDelegate?
    var data: String?
    //@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    //var holdConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentBox.delegate = self
        print("in model:\(self.data)")
        if (!(self.data?.isEmpty)! && self.data != "write your observations")  {
            self.commentBox.text = data
            self.commentBox.textColor = UIColor.black
        } else {
            self.commentBox.text = "write your observations"
            self.commentBox.textColor = UIColor.lightGray
        }
        
        //self.holdConstraint = self.bottomConstraint
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil);
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissModelView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func clearComments(_ sender: Any) {
        self.commentBox.text = nil
        self.commentBox.text = "write your observations"
        self.commentBox.textColor = UIColor.lightGray
        
    }
    
    @IBAction func saveComments(_ sender: Any) {
        if (self.commentBox?.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            displayAlertMessage(message: "comments not entered!")
        } else {
            self.delegate?.commentTextEntered(comment: self.commentBox.text)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.commentBox.textColor == UIColor.lightGray {
            self.commentBox.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.commentBox.text.isEmpty {
            self.commentBox.text = "write your observations"
            self.commentBox.textColor = UIColor.lightGray
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= (keyboardSize.height/2) - 40
            }
        }
        /*let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height + 20

        })*/
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += (keyboardSize.height/2) - 40
            }
        }
        /*let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomConstraint.constant = self.holdConstraint.constant
        })
        */
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
}
