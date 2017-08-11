//
//  AddPatientViewController.swift
//  AggressionMonitoring
//
//  Created by admin on 6/20/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class AddPatientViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    var pickGender = ["Male", "Female", "Prefer not to say"]
    var age: Int?
    var date: Date?
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var dob: UITextField!
    //@IBOutlet weak var hamburger: UIBarButtonItem!
    @IBOutlet weak var patientDesc: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        /*if (revealViewController() != nil) {
            hamburger.target = revealViewController()
            hamburger.action = #selector(SWRevealViewController.revealToggle(_:))
            //revealViewController().rearViewRevealWidth = 275
            //revealViewController().rightViewRevealWidth  =
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }*/
        self.patientDesc.delegate = self
        self.patientDesc.text = "write description (optional)"
        self.patientDesc.textColor = UIColor.lightGray
        
        self.initPicker()
        self.initDatePicker()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.patientDesc.textColor == UIColor.lightGray {
            self.patientDesc.text = nil
            self.patientDesc.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.patientDesc.text.isEmpty {
            self.patientDesc.text = "write description (optional)"
            self.patientDesc.textColor = UIColor.lightGray
        }
    }

    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        
        gender.text = "Male"
        
        gender.resignFirstResponder()
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        
        gender.resignFirstResponder()
        dob.resignFirstResponder()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickGender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickGender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gender.text = pickGender[row]
    }
    
    func initPicker() {
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        gender.inputView = pickerView
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.black
        
        
        let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddPatientViewController.tappedToolBarBtn))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(AddPatientViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Pick the patient's gender"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([defaultButton,flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        gender.inputAccessoryView = toolBar
    }

    
    func datePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        dob.text = formatter.string(from: sender.date)
        self.date = sender.date
    }
    
    
    func initDatePicker() {
        let datePickerView = UIDatePicker()
        datePickerView.minimumDate = Calendar.current.date(byAdding: .year, value: -150, to: Date())
        datePickerView.maximumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
        
        dob.inputView = datePickerView
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.black
        
        
        //let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddPatientViewController.tappedDateToolBarBtn))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(AddPatientViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Pick the patient's date of birth"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([/*defaultButton,*/flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        dob.inputAccessoryView = toolBar
    }
    
    @IBAction func clearAll(_ sender: Any) {
        self.firstName.text = nil
        self.lastName.text = nil
        self.gender.text = nil
        self.dob.text = nil
        self.patientDesc.text = nil
        
    }
    
    
    @IBAction func dismissAddPatient(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPatient(_ sender: Any) {
        //let components = Calendar.current.dateComponents([.year, .month, .day], from: self.date!)
        //if let day = components.day, let month = components.month, let year = components.year {
            //print("\(day) \(month) \(year)")
            //let fromDOB = Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
            //self.age = fromDOB.age
        //}
        
        if ((self.firstName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (self.lastName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
            self.displayAlertMessage(message: "first name / last name should not be empty")
            return
        } else if ((self.gender.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
            self.displayAlertMessage(message: "enter the gender")
            return
        } else if ((self.dob.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
            self.displayAlertMessage(message: "enter the date of bith of the patient (approximate estimation if not known")
            return
        }
        
        
        let gregorian = Calendar(identifier: .gregorian)
        let fromDOB = gregorian.dateComponents([.year], from: self.date!, to: Date())
        self.age = fromDOB.year!
        print("AGE:\(self.age)")
        var isResponseSuccess: Bool? = nil
        print(self.age!)
        let name = self.firstName.text!+" "+self.lastName.text!
        var genderText = ""
        if (self.gender.text == "Male") {
            genderText = "m"
        } else if (self.gender.text == "Female") {
            genderText = "f"
        }
        
        let parameters: Parameters = ["name": name, "age": self.age, "gender": self.gender.text, "description": self.patientDesc.text]
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/addNewUser.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
            DispatchQueue.main.async(execute: {
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"success") != nil{
                        self.displayAlertMessage(message: "Created :)")
                        isResponseSuccess = true
                        self.firstName.text = nil
                        self.lastName.text = nil
                        self.gender.text = nil
                        self.dob.text = nil
                        self.patientDesc.text = nil
                    } else {
                        // Perform ACTION
                        self.displayAlertMessage(message: "Something went wrong :(")
                        isResponseSuccess = false
                    }
                    
                } else {
                    self.displayAlertMessage(message: "Server response is empty")
                    isResponseSuccess = false
                }
                
            })
        }
    }
    
    /*@IBAction func dismissAddPatient(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }*/
    
}

extension Date {
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
}
