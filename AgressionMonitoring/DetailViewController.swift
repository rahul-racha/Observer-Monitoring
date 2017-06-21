//
//  ViewController.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/5/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate/*,PatientRootSelectionDelegate*/ {
    
    @IBOutlet weak var limbSlider: UISlider!
    @IBOutlet weak var voiceSlider: UISlider!
    @IBOutlet weak var pulseSlider: UISlider!
    var patient: [String:Any]?
    var angerStatus:String?
    var voiceStatus:String?
    var limbStatus:String?
    var controlFlag: Bool?
    var holdAngerChange: Bool?
    var holdVoiceChange: Bool?
    var holdLimbChange: Bool?
    var timeConst: Int = 10
    var seconds: Int?
    var timer = Timer()
    var prevPulseVal: Int?
    var prevLimbVal: Int?
    var prevVoiceVal: Int?
    var stopPrepObs: Bool?
    var sliderTimeStamp: String?
    
    var holdLimbTap: Bool?
    var holdVoiceTap: Bool?
    var holdPulseTap: Bool?
    
    //var pc: PatientRootTableViewController!
    //let pc = PatientRootTableViewController()
    
    @IBOutlet weak var timerText: UILabel!
    @IBOutlet weak var countdown: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var send: UIButton!
    
    @IBOutlet weak var pickerTextField: UITextField!
    
    var pickOption = ["Room 1", "Room 2", "Room 3", "Room 4", "Room 5"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //let pc = PatientRootTableViewController()
        //pc.delegatePatient = self
        self.seconds = self.timeConst
        self.timerText.text = " seconds remaing to submit the change."
        self.timerText.isHidden = true
        self.countdown.isHidden = true
        self.cancel.isHidden = true
        self.send.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        self.controlFlag = false
        self.holdLimbChange = false
        self.holdVoiceChange = false
        self.holdAngerChange = false
        self.stopPrepObs = false
        self.initSliders(p:0,v:0,l:0)
        self.prevLimbVal = Int(roundf(self.limbSlider.value))
        self.prevPulseVal = Int(roundf(self.pulseSlider.value))
        self.prevVoiceVal = Int(roundf(self.voiceSlider.value))
        
        self.holdVoiceTap = false
        self.holdLimbTap = false
        self.holdPulseTap = false
        
        self.configurePic()
        self.configureView()
        self.configureDetails()

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.imageTapped(_:)))
        imageTap.numberOfTapsRequired = 1
        self.picture.addGestureRecognizer(imageTap)
        
        let doubleTapPulse = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.pulseSliderTapped(_:)))
        doubleTapPulse.numberOfTapsRequired = 2
        self.pulseSlider.addGestureRecognizer(doubleTapPulse)
        
        let doubleTapVoice = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.voiceSliderTapped(_:)))
        doubleTapVoice.numberOfTapsRequired = 2
        self.voiceSlider.addGestureRecognizer(doubleTapVoice)
        
        let doubleTapLimb = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.limbSliderTapped(_:)))
        doubleTapLimb.numberOfTapsRequired = 2
        self.limbSlider.addGestureRecognizer(doubleTapLimb)
        
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        
        //let minimumWidth =  min((splitViewController?.view.bounds)!.width,(splitViewController?.view.bounds)!.height)
        if ((splitViewController?.view.bounds)!.width < (splitViewController?.view.bounds)!.height) {
            splitViewController?.preferredPrimaryColumnWidthFraction = 0.25//*(splitViewController?.view.bounds)!.width
        //    splitViewController?.maximumPrimaryColumnWidth = minimumWidth/2;
        } else {
            splitViewController?.preferredPrimaryColumnWidthFraction = 0.33;
        //    splitViewController?.maximumPrimaryColumnWidth = minimumWidth/2;
        }
        
        //splitViewController?.preferredPrimaryColumnWidthFraction = 0.2*minimumWidth
        //splitViewController?.minimumPrimaryColumnWidth = minimumWidth / (3*100);
        //splitViewController?.maximumPrimaryColumnWidth = minimumWidth/3;
        self.initPicker()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageTapped(_ gestureRecognizer: UIGestureRecognizer) {
        let graphController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NextDetailViewController") as! NextDetailViewController
        self.present(graphController, animated: true, completion: nil)
    }
    
    func pulseSliderTapped(_ gestureRecognizer: UIGestureRecognizer) {
        self.holdPulseTap = true
        self.updatePulse()
    }
    
    func voiceSliderTapped(_ gestureRecognizer: UIGestureRecognizer) {
        self.holdVoiceTap = true
        self.updateVoice()
    }
    
    func limbSliderTapped(_ gestureRecognizer: UIGestureRecognizer) {
        self.holdLimbTap = true
        self.updateLimbs()
    }
    
    
    func initSliders(p: Int, v: Int, l: Int) {
        self.pulseSlider.value = Float(p)
        self.limbSlider.value = Float(l)
        self.voiceSlider.value = Float(v)
        self.getAngerStatus()
        self.getLimbStatus()
        self.getVoiceStatus()
    }
    
    func resetFlags() {
        self.controlFlag = false
        self.holdAngerChange = false
        self.holdLimbChange = false
        self.holdVoiceChange = false
        self.seconds = self.timeConst
        self.stopPrepObs = false
        self.holdPulseTap = false
        self.holdVoiceTap = false
        self.holdLimbTap = false
        //self.timer = Timer()
    }
    
    func configurePic() {
        self.picture.image = #imageLiteral(resourceName: "labimg")
        self.picture.layer.cornerRadius = self.picture.frame.size.width/2
        self.picture.clipsToBounds = true
        self.picture.layer.borderColor = UIColor.gray.cgColor
        self.picture.layer.borderWidth = 2
    }
    
    func configureView() {
        self.detailsView.layer.cornerRadius = self.detailsView.frame.size.width / 10
        self.detailsView.clipsToBounds = true
        self.detailsView.layer.borderWidth = 5.0
        if (patient != nil) {
            self.detailsView.layer.borderColor = (patient?["status_color"] as! UIColor).cgColor
        } else {
            self.detailsView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func configureDetails() {
        if (patient != nil) {
            self.age.text = patient?["age"] as? String
            self.gender.text = patient?["gender"] as? String
            self.pickerTextField.text = patient?["location"] as? String
        }
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        
        pickerTextField.resignFirstResponder()
        
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        
        pickerTextField.text = "Room 1"
        
        pickerTextField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickOption[row]
    }
    
    
    func getTimestamp() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let _ = date.timeIntervalSince1970
        return dateString
    }

    @IBAction func updateLimbAction(_ sender: Any) {
        self.updateLimbs()
    }
    
    func updateLimbs() {
        let status = self.limbStatus
        self.getLimbStatus()
        
        if ((self.pickerTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
            //let obj = Manage()
            self.displayAlertMessage(message: "Location cannot be empty")
            return
        }
        
        if (self.holdLimbChange == false) {
            self.holdLimbChange = true
            let prevStatus = status
            self.prevLimbVal = Int(roundf(self.limbSlider.value))
            if (self.stopPrepObs == false) {
                let wait = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: wait) {
                    // Your code with delay
                    if ((prevStatus != self.limbStatus) || self.holdLimbTap == true) {
                        self.prepareObservation(timestamp: self.getTimestamp())
                    }
                    //self.holdLimbChange = false
                }
            }
        }
    }
    
    func getLimbStatus() {
        limbSlider.value = roundf(limbSlider.value)
        if (limbSlider.value == 0) {
            limbSlider.thumbTintColor = UIColor.green
            limbSlider.minimumTrackTintColor = UIColor.green
            self.limbStatus = "stable"
        } else if (limbSlider.value == 1) {
            limbSlider.thumbTintColor = UIColor.yellow
            limbSlider.minimumTrackTintColor = UIColor.yellow
            self.limbStatus = "slightly aggressive"
        } else if (limbSlider.value == 2) {
            limbSlider.thumbTintColor = UIColor.red
            limbSlider.minimumTrackTintColor = UIColor.red
            self.limbStatus = "aggressive"
        } else {
            limbSlider.thumbTintColor = UIColor.gray
            limbSlider.minimumTrackTintColor = UIColor.lightGray
            self.limbStatus = "unknown"
        }
    }

    @IBAction func updateVoiceAction(_ sender: Any) {
        self.updateVoice()
    }
    
    func updateVoice() {
        let status = self.voiceStatus
        self.getVoiceStatus()
        
        if ((self.pickerTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
            //let obj = Manage()
            self.displayAlertMessage(message: "Location cannot be empty")
            return
        }
        
        if (self.holdVoiceChange == false) {
            self.holdVoiceChange = true
            let prevStatus = status
            self.prevVoiceVal = Int(roundf(self.voiceSlider.value))
            if (self.stopPrepObs == false) {
                let wait = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: wait) {
                    // Your code with delay
                    if ((prevStatus != self.voiceStatus) || self.holdVoiceTap == true) {
                        self.prepareObservation(timestamp: self.getTimestamp())
                    }
                    //self.holdVoiceChange = false
                }
            }
        }
    }
    
    func getVoiceStatus() {
        voiceSlider.value = roundf(voiceSlider.value)
        if (voiceSlider.value == 0) {
            voiceSlider.thumbTintColor = UIColor.green
            voiceSlider.minimumTrackTintColor = UIColor.green
            self.voiceStatus = "stable"
        } else if (voiceSlider.value == 1) {
            voiceSlider.thumbTintColor = UIColor.yellow
            voiceSlider.minimumTrackTintColor = UIColor.yellow
            self.voiceStatus = "slightly aggressive"
        } else if (voiceSlider.value == 2) {
            voiceSlider.thumbTintColor = UIColor.red
            voiceSlider.minimumTrackTintColor = UIColor.red
            self.voiceStatus = "aggressive"
        } else {
            voiceSlider.thumbTintColor = UIColor.gray
            voiceSlider.minimumTrackTintColor = UIColor.lightGray
            self.voiceStatus = "unknown"
        }

    }
    
    @IBAction func updatePulseAction(_ sender: Any) {
        self.updatePulse()
    }
    
    func updatePulse() {
        let status = self.angerStatus
        self.getAngerStatus()
        
        if ((self.pickerTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
            //let obj = Manage()
            self.displayAlertMessage(message: "Location cannot be empty")
            return
        }
        
        if (self.holdAngerChange == false) {
            self.holdAngerChange = true
            let prevStatus = status
            self.prevPulseVal = Int(roundf(self.pulseSlider.value))
            if (self.stopPrepObs == false) {
                let wait = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: wait) {
                    // Your code with delay
                    if ((prevStatus != self.angerStatus) || self.holdPulseTap == true) {
                        self.prepareObservation(timestamp: self.getTimestamp())
                    }
                    //self.holdAngerChange = false
                }
            }
        }
    }
    
    func getAngerStatus() {
        pulseSlider.value = roundf(pulseSlider.value)
        if (pulseSlider.value == 0) {
            pulseSlider.thumbTintColor = UIColor.green
            pulseSlider.minimumTrackTintColor = UIColor.green
            self.angerStatus = "stable"
        } else if (pulseSlider.value == 1) {
            pulseSlider.thumbTintColor = UIColor.yellow
            pulseSlider.minimumTrackTintColor = UIColor.yellow
            self.angerStatus = "slightly aggressive"
        } else if (pulseSlider.value == 2) {
            pulseSlider.thumbTintColor = UIColor.red
            pulseSlider.minimumTrackTintColor = UIColor.red
            self.angerStatus = "aggressive"
        } else {
            pulseSlider.thumbTintColor = UIColor.gray
            pulseSlider.minimumTrackTintColor = UIColor.lightGray
            self.angerStatus = "unknown"
        }
    }
    
    func updateTimer() {
        self.seconds! -= 1
        self.countdown.text = "\(self.seconds!)"
        if (self.seconds! <= 0) {
            self.timer.invalidate()
            self.countdown.isHidden = true
            self.timerText.isHidden = true
            self.cancel.isHidden = true
            self.send.isHidden = true
            self.seconds = self.timeConst
            self.sendObservation(timestamp: self.sliderTimeStamp!)
            self.resetFlags()
        }
    }

    @IBAction func sendRightAway(_ sender: Any) {
        //self.allowSend = true
        self.timer.invalidate()
        self.countdown.isHidden = true
        self.timerText.isHidden = true
        self.cancel.isHidden = true
        self.send.isHidden = true
        self.seconds = self.timeConst
        if (self.sliderTimeStamp != nil) {
            self.sendObservation(timestamp: self.sliderTimeStamp!)
        }
        self.resetFlags()
    }
    
    
    @IBAction func cancelSubmit(_ sender: Any) {
        //self.allowCancel = true
        self.timer.invalidate()
        self.countdown.isHidden = true
        self.timerText.isHidden = true
        self.cancel.isHidden = true
        self.send.isHidden = true
        self.seconds = self.timeConst
        self.initSliders(p: self.prevPulseVal!, v: self.prevVoiceVal!, l: self.prevLimbVal!)
        self.resetFlags()
    }
    
    func prepareObservation(timestamp: String)  {
        if (self.controlFlag == false) {
            self.sliderTimeStamp = timestamp
            self.controlFlag = true
            self.countdown.text = "\(self.timeConst)"
            self.countdown.isHidden = false
            self.timerText.isHidden = false
            self.cancel.isHidden = false
            self.send.isHidden = false
            self.stopPrepObs = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(DetailViewController.updateTimer)), userInfo: nil, repeats: true)
            /*let wait = DispatchTime.now() + 10
            if (self.allowCancel == false && self.allowSend == false) {
                DispatchQueue.main.asyncAfter(deadline: wait) {
                    self.sendObservation(timestamp: timestamp)
                    //self.initSliders()
                    self.resetFlags()
                }
            } */
        }
    }
        
    func sendObservation(timestamp: String) {
        print("Checking if run on cancel")
        var cause: String = "unknown"
        if ((self.voiceStatus != "stable" && self.voiceStatus != "unknown") && (self.limbStatus != "stable" && self.limbStatus != "unknown")) {
            cause = "hands & voice"
        } else if (self.voiceStatus == "slightly aggressive" || self.voiceStatus == "aggressive") {
            cause = "voice"
        } else if (self.limbStatus == "slightly aggressive" || self.limbStatus == "aggressive") {
            cause = "hands"
        }
        
        print("voice:\(self.voiceStatus)")
        print("hands:\(self.limbStatus)")
        print("anger:\(self.angerStatus)")
        
        let parameters: Parameters = ["patient_id": patient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "start_time": timestamp, "status":self.angerStatus ?? "unknown", "cause":cause]
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObserverData.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
            DispatchQueue.main.async(execute: {
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"success") != nil{
                        self.displayAlertMessage(message: "Submitted :)")
                    } else {
                        // Perform ACTION
                        self.displayAlertMessage(message: "Something went wrong :(")
                    }
                    
                } else {
                    self.displayAlertMessage(message: "Server response is empty")
                }
                
            })
        }
        print("pat: \(patient!["id"] as! String)")
        print("obs: \(Manager.userData!["id"] as! String)")
        let parameters2: Parameters = ["patient_id": patient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "start_time": timestamp, "location": self.pickerTextField.text!]
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObservedLocation.php",method: .post,parameters: parameters2, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/string"])*/.responseData { response in
            DispatchQueue.main.async(execute: {
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"success") != nil{
                        self.displayAlertMessage(message: "Submitted :)")
                    } else {
                        // Perform ACTION
                        self.displayAlertMessage(message: "Something went wrong :(")
                    }
                    
                } else {
                    self.displayAlertMessage(message: "Server response is empty")
                }
                
            })
        }
    }
    
    func initPicker() {
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        pickerTextField.inputView = pickerView
        
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
        
        label.text = "Pick the patient's location"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([defaultButton,flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        pickerTextField.inputAccessoryView = toolBar
    }
    
}

/*extension DetailViewController: PatientRootSelectionDelegate {
    
    func patientSelected(patientDetails: [String : Any]) {
        self.patient = patientDetails
        print("inside detail's delegate")
        print(self.patient)
        viewDidLoad()
    }
}*/
