//
//  ViewController.swift
//  AgressionMonitoring
//
//  Created by admin on 6/13/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class LoginViewController: UIViewController, NSURLConnectionDelegate {

    
    //@IBOutlet weak var _username: UIView!
    @IBOutlet weak var _username: UITextField!
    @IBOutlet weak var _password: UITextField?
    @IBOutlet weak var rememberCredentials: UISwitch!
    @IBOutlet weak var viewBox: UIViewX!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var isScroll: Bool?
    
    //@IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
   // @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var keyChainUser: String?
    var keyChainPwd: String?
    var isUsrSaved:Bool = false
    var isPwdSaved:Bool = false
    var isUsrRemoved:Bool = true
    var isPwdRemoved:Bool = true

    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }

    
    func keyboardWillShow(notification: NSNotification) {
        if (self.isScroll == true) {
       adjustHeight(show: true, notification: notification)
            self.isScroll = false
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (self.isScroll == false) {
        adjustHeight(show: false, notification: notification)
            self.isScroll = true
        }
    }
    
    func adjustHeight(show:Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let changeInHeight = (keyboardFrame.height) * (show ? 1 : -1)
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
            //if self.viewBox.frame.origin.y == 0{
                //self.viewBox.frame.origin.y += changeInHeight
            //}
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isScroll = true
        Manager.triggerNotifications = false
        keyChainUser = KeychainWrapper.standard.string(forKey: "username")
        if(keyChainUser != nil) {
            _username?.text = keyChainUser!
            print(keyChainUser)
        }
        keyChainPwd = KeychainWrapper.standard.string(forKey: "password")
        if(keyChainPwd != nil) {
            _password?.text = keyChainPwd!
            print(keyChainPwd)
        }
        rememberCredentials.addTarget(self, action: #selector(setWhenStateChanged(_:)), for: UIControlEvents.valueChanged)
        //        switchState = UserDefaults.standard.bool(forKey: "switchState")
        //        userName = UserDefaults.standard.string(forKey: "keepUsername")!
        //        password = UserDefaults.standard.string(forKey: "keepPassword")!
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setWhenStateChanged(_ sender:UISwitch!) {
        if(sender.isOn == false) {
            self.isUsrRemoved = KeychainWrapper.standard.removeObject(forKey: "username")
            self.isPwdRemoved = KeychainWrapper.standard.removeObject(forKey: "password")
        }
        
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    
    @IBAction func login(_ sender: UIButton) {
        let username = _username?.text
        let password = _password?.text
        var user: String?
        
        if (username?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (password?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            print(username)
            print(password)
            displayAlertMessage(message: "All fields are required")
            //self._username?.placeholder = "username"
            //self._password?.placeholder = "password"
            return
        }
        
        
        let parameters: Parameters = ["user_name":username! , "password": password!, "device_id": Manager.deviceId == nil ? "abc" : Manager.deviceId!, "device_type": "apple"]
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/login.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseJSON { response in
                
                debugPrint("All Response Info: \(response)")
                
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    
                    print("Data: \(utf8Text)")
                    print("After data")
                    if let dict = self.convertToDictionary(text: utf8Text) {
                        print(dict as Any)
                        let userFromData = (dict["name"] as! String)
                        if !userFromData.isEmpty {
                            print(userFromData as Any)
                            user = userFromData
                        }
                        
                        
                        print("user from dict:\(String(describing: user))")
                    
                        if user != nil,user! == username! {
                            
                            if(/*self.keyChainUser != nil && */self.rememberCredentials.isOn == true) {
                                self.isUsrSaved = KeychainWrapper.standard.set(user!, forKey: "username")
                                
                                let retrievedUsername: String? = KeychainWrapper.standard.string(forKey: "username")
                                if (retrievedUsername != nil) {
                                    self.keyChainUser = retrievedUsername!
                                }
                                self.isPwdSaved = KeychainWrapper.standard.set(password!, forKey: "password")
                                let retrievedPwd: String? = KeychainWrapper.standard.string(forKey: "password")
                                if(retrievedPwd != nil) {
                                    self.keyChainPwd = retrievedPwd!
                                }
                                
                            }
                            else if(self.rememberCredentials.isOn == false) {
                                self.isUsrRemoved = KeychainWrapper.standard.removeObject(forKey: "username")
                                self.isPwdRemoved = KeychainWrapper.standard.removeObject(forKey: "password")
                            }
                            
                            Manager.userData = dict
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            /*let splitViewController = storyboard.instantiateViewController(withIdentifier: "splitViewController") as! UISplitViewController
                            UIApplication.shared.keyWindow?.rootViewController = splitViewController
                            self.present(splitViewController, animated: true, completion: nil)*/
                            let swRevViewController = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                            UIApplication.shared.keyWindow?.rootViewController = swRevViewController
                            Manager.triggerNotifications = true
                            self.present(swRevViewController, animated: true, completion: nil)
                            
   
                        }
                        else {
                            self.displayAlertMessage(message: "Invalid username or password")
                            self._username?.text = nil
                            self._password?.text = nil
                        }
                    }
                    else {
                        self.displayAlertMessage(message: "Response data is empty. Check your Internet Connection.")
                        self._username?.text = nil
                        self._password?.text = nil
                    }

                }
                else {
                    self.displayAlertMessage(message: "response data is empty. Check your Internet Connection.")
                    self._username?.text = nil
                    self._password?.text = nil
                }
        }
    }

}
