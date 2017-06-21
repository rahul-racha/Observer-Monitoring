//
//  AddPatientViewController.swift
//  AggressionMonitoring
//
//  Created by admin on 6/20/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class AddPatientViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var pickGender = ["Male", "Female", "Neutral"]
    var age: Int?
    var date: Date?
    @IBOutlet weak var patientName: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var hamburger: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if (revealViewController() != nil) {
            hamburger.target = revealViewController()
            hamburger.action = #selector(SWRevealViewController.revealToggle(_:))
            //revealViewController().rearViewRevealWidth = 275
            //revealViewController().rightViewRevealWidth  =
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.initPicker()
        self.initDatePicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    
    @IBAction func addPatient(_ sender: Any) {
        //let components = Calendar.current.dateComponents([.year, .month, .day], from: self.date!)
        //if let day = components.day, let month = components.month, let year = components.year {
            //print("\(day) \(month) \(year)")
            //let fromDOB = Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
            //self.age = fromDOB.age
        //}
        let gregorian = Calendar(identifier: .gregorian)
        let fromDOB = gregorian.dateComponents([.year], from: self.date!, to: Date())
        self.age = fromDOB.year!
        
        print(self.age!)
        
    }
    
}

extension Date {
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
}
