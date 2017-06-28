//
//  RegisterViewController.swift
//  AggressionMonitoring
//
//  Created by admin on 6/26/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var profileImage: UIButton!
    var imagePicker: UIImagePickerController!
    
    var roleList: [String] = ["Doctor", "Observer", "CNA"]
    
    @IBOutlet weak var roleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initPicker()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addImage(_ sender: UIButtonX) {
        /*guard let _ = sender as? UIButtonX else {
            return
        }*/
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        self.imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let cameraAction = UIAlertAction(title: "Use Camera", style: .default) { (action) in
            self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
             self.present(self.imagePicker, animated: true, completion: nil)
        }
        let photoLibAction = UIAlertAction(title: "Use Photo Library", style: .default) { (action) in
            self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibAction)
        alertController.addAction(cancelAction)
        
        /*let popoverPresent = alertController.popoverPresentationController {
            popoverPresent.sourceView = button
            popoverPresent.sourceRect = button.bounds
        }*/
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        print(pickedImage)
        self.profileImage.imageView?.contentMode = .scaleAspectFill
        self.profileImage.setImage(pickedImage, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
    func donePressed(_ sender: UIBarButtonItem) {
        
        roleTextField.resignFirstResponder()
        
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        
        roleTextField.text = "Doctor"
        
        roleTextField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roleList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roleList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        roleTextField.text = roleList[row]
    }

    func initPicker() {
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        roleTextField.inputView = pickerView
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.black
        
        
        let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController.tappedToolBarBtn))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(DetailViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Pick the user's role"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([defaultButton,flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        roleTextField.inputAccessoryView = toolBar
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func goToLogin(_ sender: Any) {
        Manager.triggerNotifications = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.keyWindow?.rootViewController = loginViewController
        self.dismiss(animated: true, completion: nil)
        self.present(loginViewController, animated: true, completion: nil)
        
    }

    

}
