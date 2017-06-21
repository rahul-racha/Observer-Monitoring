//
//  SlideOutViewController.swift
//  AggressionMonitoring
//
//  Created by admin on 6/20/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class SlideOutViewController: UIViewController {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userName.text = Manager.userData?["name"] as? String
        print("Name: \(Manager.userData)")
        print(Manager.userData?["name"] as? String)
        self.configurePic()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configurePic() {
        self.profilePic.image = #imageLiteral(resourceName: "labimg")
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderColor = UIColor.gray.cgColor
        self.profilePic.layer.borderWidth = 2
    }

    
    @IBAction func logout(_ sender: Any) {
        Manager.triggerNotifications = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.keyWindow?.rootViewController = loginViewController
        self.dismiss(animated: true, completion: nil)
        self.present(loginViewController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
