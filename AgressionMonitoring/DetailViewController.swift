//
//  ViewController.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/5/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,  UITextViewDelegate {
    
    @IBOutlet weak var actionTableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var hamburger: UIBarButtonItem!
    @IBOutlet weak var seclectedCount: UILabel!
    @IBOutlet weak var sendActionButton: UIButtonX!
    @IBOutlet weak var eventButton: UIButtonX!
    @IBOutlet weak var clearActionsButton: UIButtonX!
    @IBOutlet weak var picture: UIImageViewX!
    //@IBOutlet weak var age: UILabel!
    //@IBOutlet weak var gender: UILabel!
    @IBOutlet weak var detailsView: UIViewX!
    @IBOutlet weak var runningTime: UILabelX!
    @IBOutlet weak var pickerTextField: UITextFieldX!
    @IBOutlet weak var commentButton: UIButtonX!
    
    fileprivate let reuseTIdentifier = "actionTableCell"
    fileprivate let reuseCIdentifier = "actionCollectionCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
    fileprivate var itemsPerRow = 10
    fileprivate var actionList = [[String?]](repeating: [String?](repeating:nil, count:12), count: 4)
    fileprivate var actionParameterList = [[String?]](repeating: [String?](repeating:nil, count:12), count: 4)
    fileprivate var actionParameterIds = [[Int?]](repeating: [Int?](repeating:nil, count:12), count: 4)
    fileprivate var storedOffsets: [[CGFloat?]] = Array(repeating: Array(repeating:0, count:3), count: 4)
    fileprivate var actionHeaders: [String]?
    fileprivate var selectedIndices = Set<IndexPath>()
    
    var actionTimeStamp: String?
    var observerParameters: Dictionary<String,Any>?
    var patient: [String:Any]?
    //var locationSet: Set<String> = [] //["Room 1", "Room 2", "Room 3", "Room 4", "Room 5"]
    var pickOption = [String]()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var cellHeightBooster: CGFloat = 1.5
    var cellWidthBooster: CGFloat = 1
    let commentPlaceholder: String = "write your observations"
    var isStop: Bool = false
    
    var sharing: Bool = false {
        didSet{
            if let count = self.actionHeaders?.count {
                for i in 0..<count {
                    if let cell = self.actionTableView.cellForRow(at: IndexPath(row: 0, section: i)) as? ActionTableViewCell {
                        cell.actionCollectionView.allowsMultipleSelection = sharing
                        cell.actionCollectionView.selectItem(at: nil, animated: true, scrollPosition: UICollectionViewScrollPosition())
                    }
                }
            }
            self.selectedIndices.removeAll(keepingCapacity: false)
            self.actionTimeStamp = self.getTimestamp()
            print("time noted:\(self.actionTimeStamp)")
            //self.sendActionButton.isHidden = false
            //self.seclectedCount.isHidden = false
            //guard let _ = self.sendActionButton else {
            //    return
            //}
            
            //guard sharing else {
            //    self.sendActionButton.isHidden = true
            //    return
            //}
            
            self.updateSharedIndicesCount()
            
            
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.updateTime()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        self.commentTextView.delegate = self
        if !(self.commentTextView?.text.isEmpty)!  {
            self.commentTextView.textColor = UIColor.black
        } else {
            self.commentTextView.text = self.commentPlaceholder
            self.commentTextView.textColor = UIColor.lightGray
        }
        
        self.enableInterfaceOutlets(flag: true)
        self.clearActionsButton.isHidden = true
        self.seclectedCount.isHidden = true
        
        //self.configurePic()
        //self.configureView()
        //self.configureDetails()

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.imageTapped(_:)))
        imageTap.numberOfTapsRequired = 1
        self.picture.addGestureRecognizer(imageTap)
        
        
        /*Marshall McLuhan’s 106th birthday
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        splitViewController?.preferredPrimaryColumnWidthFraction = 0.31*/
        //let minimumWidth =  min((splitViewController?.view.bounds)!.width,(splitViewController?.view.bounds)!.height)
        //if ((splitViewController?.view.bounds)!.width < (splitViewController?.view.bounds)!.height) {
        //    splitViewController?.preferredPrimaryColumnWidthFraction = 0.25//*(splitViewController?.view.bounds)!.width
        //    splitViewController?.maximumPrimaryColumnWidth = minimumWidth/2;
        //} else {
        //    splitViewController?.preferredPrimaryColumnWidthFraction = 0.33;
        //    splitViewController?.maximumPrimaryColumnWidth = minimumWidth/2;
       // }
        
        //splitViewController?.preferredPrimaryColumnWidthFraction = 0.2*minimumWidth
        //splitViewController?.minimumPrimaryColumnWidth = minimumWidth / (3*100);
        //splitViewController?.maximumPrimaryColumnWidth = minimumWidth/3;
        self.startActivityIndicator()
        
        var parameters: Parameters = [:]
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getActionParameters.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
            
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                    self.actionHeaders = /*["Physical / Aggressive", "Physical / Non-Aggressive", "Verbal / Aggressive", "Verbal / Non-aggressive"]*/json["sections"] as? [String]
                    if let actionDict = json["categories"]  as? [Dictionary<String,Any>] {
                        //print("actioDict:\(actionDict)")
                        if 0 < actionDict.count && self.actionHeaders?.count == actionDict.count {
                            for section in 0..<(self.actionHeaders?.count)! {
                                
                                let sectionDict = actionDict[section][(self.actionHeaders?[section])!] as! [Dictionary<String,String>]
                                //let sectionDict = actionDict[(self.actionHeaders?[section])!] as! [Dictionary<String,String>]
                                for param in 0..<sectionDict.count {
                                    print("section,row: \(section),\(param)")
                                    print("**********")
                                    print(sectionDict[param]["short_name"]!)
                                    self.actionList[section].insert(sectionDict[param]["short_name"]!, at: param)
                                    self.actionParameterList[section].insert(sectionDict[param]["parameter_name"]!, at: param)
                                    self.actionParameterIds[section].insert(Int(sectionDict[param]["parameter_id"]!), at: param)
                                    
                                    // #get the id's as well in a separate list
                                    //self.actionParameterList?[section][param] = sectionDict[param]["parameter_name"]!
                                    print("result:\(self.actionList[section][param])")
                                    /*
                                     let section1 = actionDict["Physical / Aggressive"/*(self.actionHeaders?[0])!*/] as? [String]
                                     let section2 = actionDict[(self.actionHeaders?[1])!] as? [String]
                                     let section3 = actionDict[(self.actionHeaders?[2])!] as? [String]
                                     let section4 = actionDict[(self.actionHeaders?[3])!] as? [String]
                                     
                                     
                                     self.actionList = [section1!,section2!,section3!,section4!]*/
                                    //self.constructActionDict(sectionCount: actionDict.count)
                                    DispatchQueue.main.async(execute: {
                                        self.actionTableView.reloadData()
                                        self.getAllPatients()
                                        self.stopActivityIndicator()
                                    })
                                }
                                print("************size if actionList:\(self.actionList[0].count)")
                            }
                            print("final list: \(self.actionList)::::)")
                            
                        }
                    }
                }
                catch{
                    print("error serializing JSON: \(error)")
                }
            }
        }
        
        
        

        if (revealViewController() != nil) {
            hamburger.target = revealViewController()
            hamburger.action = #selector(SWRevealViewController.revealToggle(_:))
            //revealViewController().rearViewRevealWidth = 275
            //revealViewController().rightViewRevealWidth  =
            //view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //self.stackHeader.backgroundColor = UIColor.
        
        
        actionTableView.rowHeight = UITableViewAutomaticDimension
        actionTableView.estimatedRowHeight = 240
        
        //pickOption.append(contentsOf: self.locationSet.sorted())
        self.initPicker()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func constructActionDict(sectionCount: Int) {
        for i in 0..<sectionCount {
            if let list = self.actionList?[i] {
            for j in 0..<list.count {
                //self.actionDictionary?.updateValue(list[j], forKey: IndexPath(row: j, section: i))
                let key = (i*10)+j
                self.actionDictionary?[key] = list[j]
                print("@@@@@@indexPath:\(IndexPath(row: j, section: i)),value: \(list[j])@@@@@@")
                print(self.actionDictionary?[key])
            }
        }
        }
        print("final dict:\(self.actionDictionary)")
    }*/
    
    func getAllPatients() {
        let userid = Int(Manager.userData!["id"] as! String)
        let role = Manager.userData!["role"] as! String
        // Do any additional setup after loading the view, typically from a nib.
        let parameters: Parameters = ["userid": userid as Any, "role": role]
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getPatientDetails.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
            DispatchQueue.main.async(execute: {
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                    Manager.patientDetails = json["patient_details"] as? [Dictionary<String,Any>]
                    self.patient = Manager.patientDetails?[0]
                    //8888888888888
                    
                    let params: Parameters = ["patient_id": self.patient!["id"], "observer_id": userid as Any]
                    Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getObservationstate.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
                        DispatchQueue.main.async(execute: {
                        if let data = response.data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                                let prevState = json["pastdetails"] as? [Dictionary<String,Any>]
                                
                                self.patient?["action"] = prevState?[0]["ation"] as? String
                                self.patient?["comments"] = prevState?[0]["comments"] as? String
                                //self.patient?["parameters"] = prevState[0]["parameters"] as? [String]
                                self.patient?["parameters"] = [5,10,14]

                                //DispatchQueue.main.async(execute: {
                                      self.configurePic()
                                     /*self.configureView()
                                     */
                                    self.configureDetails()
                                //})
                                
                            }
                            catch{
                                //print("error serializing JSON: \(error)")
                            }
                        }
                        })
                    }
                    
                    //8888888888888
                    self.pickOption = json["locations"] as! [String]
                    self.pickOption.sort()
                    //let paramIds = Manager.patientDetails?[indexPath.section]["stored_param"] as? [String]
                    //DispatchQueue.main.async(execute: {
                        /*self.configurePic()
                         self.configureView()
                         */
                        //self.configureDetails()
                    //})
                    
                }
                catch{
                    //print("error serializing JSON: \(error)")
                }
            }
        })
        }
    }
    
    func startActivityIndicator() {
        //self.sendActionButton.isEnabled = false
        //self.eventButton.isEnabled = false
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.view.addSubview(self.activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        //self.sendActionButton.isEnabled = true
        //self.eventButton.isEnabled = true
        UIApplication.shared.endIgnoringInteractionEvents()
        self.activityIndicator.stopAnimating()
    }
    
    func getTimestamp(forDisplay: Bool = false) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        if (forDisplay) {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        }
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let _ = date.timeIntervalSince1970
        return dateString
    }
    
    func updateTime() {
        self.runningTime.text = self.getTimestamp(forDisplay: true)
    }
    
//    func switchValueDidChange(_ sender: UISwitch!) {
//        let window = UIApplication.shared.keyWindow!
//        if (splitViewController?.isViewLoaded)! && splitViewController?.view.window != nil {
//        //if sender.isOn {
//            splitViewController?.view.removeFromSuperview()
//            splitViewController?.viewControllers = NSArray(objects: self.leftNav!, self.leftNav!) as! [UINavigationController]
//            window.addSubview(self.view)
//            
//        } else {
//            self.view.removeFromSuperview()
//            self.view.transform = CGAffineTransform.identity
//            splitViewController?.viewControllers = NSArray(objects: self.leftNav!, self.rightNav!) as! [UIViewController]
//            window.addSubview((splitViewController?.view)!)
//            self.view.sizeToFit()
//            
//    }
//    }
    
    func updateSharedIndicesCount() {
        self.seclectedCount.textColor = UIColor.purple
        self.seclectedCount.text = "\(self.selectedIndices.count) actions selected"
        self.seclectedCount.sizeToFit()
        print("selected indices:\(self.selectedIndices)")
        if self.selectedIndices.count > 0 {
            self.seclectedCount.isHidden = false
            self.clearActionsButton.isHidden = false
        } else {
            self.seclectedCount.isHidden = true
            self.clearActionsButton.isHidden = true
        }
    }
    
    
    func reloadActionCells() {
        if let count = self.actionHeaders?.count {
            for i in 0..<count {
                if let cell = self.actionTableView.cellForRow(at: IndexPath(row: 0, section: i)) as? ActionTableViewCell {
                    cell.actionCollectionView.reloadData()
                }
            }
        }
    }
    
    func prepareToSendData(actionType: String, isEvent: Bool) -> Bool?{
        var selectedParameters = [String]()
        //if let selList = self.selectedIndices? {
        for idx in self.selectedIndices {
            //print("action dict:\(self.actionDictionary)")
            //let key = (idx.section*10)+(idx.row)
            //if let _ = self.actionDictionary?.index(forKey: key) {
            //    selectedParameters.append((self.actionDictionary?[key])!)
            //}
            selectedParameters.append((self.actionParameterList[idx.section][idx.row])!)
        }
        //}
        return self.sendObservation(selectedParameters: selectedParameters, type: actionType, isEvent: isEvent)
    }

    func processActions(isSendAction: Bool, response: Bool?) {
        var resp: Bool? = response
        if (self.sendActionButton.title(for: .normal) == "Start Action") {
            if (isSendAction == true) {
                resp = self.prepareToSendData(actionType: "start event", isEvent: false)
            }
                if (resp != nil && resp! == true) {
                    self.sendActionButton.setTitle("Stop Action", for: .normal)
                    self.sendActionButton.backgroundColor = UIColor.red
                    self.eventButton.isEnabled = false
                    self.isStop = true
                }
            
        } else {
            self.actionTimeStamp = self.getTimestamp()
            if (isSendAction == true) {
            resp = self.prepareToSendData(actionType: "stop event", isEvent: false)
            }
                if (resp != nil && resp! == true) {
                    self.sharing = false
                    self.reloadActionCells()
                    self.sendActionButton.setTitle("Start Action", for: .normal)
                    self.sendActionButton.backgroundColor = UIColor.blue
                    self.eventButton.isEnabled = true
                    self.isStop = false
                }
            
        }
    }
    
    @IBAction func share(_ sender: Any) {
        guard !self.selectedIndices.isEmpty else {
            self.displayAlertMessage(message: "No actions selected")
            //self.sharing = !self.sharing
            return
        }
        
        guard sharing else { return }
        self.processActions(isSendAction: true, response: nil)
    }
    
    func processEvent(isSendEvent: Bool, response: Bool?) {
        var resp: Bool? = response
        if (isSendEvent == true) {
            resp = self.prepareToSendData(actionType: "single event", isEvent: true)
        }
        if (resp != nil && resp! == true) {
            self.sharing = false
            self.reloadActionCells()
        }
    }
    
    @IBAction func shareEvent(_ sender: Any) {
        guard !self.selectedIndices.isEmpty else {
            self.displayAlertMessage(message: "No actions selected")
            //self.sharing = !self.sharing
            return
        }
        
        guard sharing else { return }
        self.processEvent(isSendEvent: true, response: nil)
        
    }
    
    
    @IBAction func clearActions(_ sender: Any) {
        self.sharing = false
        self.reloadActionCells()
    }

    
    func sendPatientState() {
        var isResponseSuccess: Bool? = nil
        var cmt: String? = nil
        if (self.commentTextView.text != self.commentPlaceholder) {
            cmt = self.commentTextView.text!
        }
        
        var selectedIds = [Int]()
        for idx in self.selectedIndices {
            selectedIds.append((self.actionParameterIds[idx.section][idx.row])!)
        }
        
        let parameters: Parameters = ["patient_id": patient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "comment": (cmt != nil) ? cmt! : cmt as Any, "parameters": selectedIds, "action": "stop"]
        print("para:\(parameters)")
        
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObservationState.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
            DispatchQueue.main.async(execute: {
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"successs") != nil{
                        //self.displayAlertMessage(message: "Submitted :)")
                        isResponseSuccess = true
                    } else {
                        // Perform ACTION
                        //self.displayAlertMessage(message: "Something went wrong :(")
                        isResponseSuccess = false
                    }
                    
                } else {
                    //self.displayAlertMessage(message: "Server response is empty")
                    isResponseSuccess = false
                }

            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modelSegue" {
            if let destinationController = segue.destination as? ModelViewController {
                destinationController.delegate = self
                if let data = self.commentTextView?.text {
                    destinationController.data = data
                } else {
                    destinationController.data = nil
                }
            }
        } else if (segue.identifier == "patientSegue") {
            if (self.isStop == true || self.commentTextView.text != self.commentPlaceholder) {
                self.sendPatientState()
            }
            if let destinationVC = segue.destination as? PatientRootTableViewController {
                destinationVC.patientDelegate = self
            }
        }
    }
    
    func imageTapped(_ gestureRecognizer: UIGestureRecognizer) {
        let graphController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NextDetailViewController") as! NextDetailViewController
        self.present(graphController, animated: true, completion: nil)
    }
    
    /*
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
    */
    
    func enableInterfaceOutlets(flag: Bool) {
        self.sendActionButton.isEnabled = flag
        self.eventButton.isEnabled = flag
        self.clearActionsButton.isEnabled = flag
        self.commentButton.isEnabled = flag
        self.pickerTextField.isEnabled = flag
    }
    
    func configurePic() {
        self.picture.image = #imageLiteral(resourceName: "labimg")
        /*self.picture.layer.cornerRadius = self.picture.frame.size.width/10
        self.picture.clipsToBounds = true
        self.picture.layer.borderColor = UIColor.gray.cgColor
        self.picture.layer.borderWidth = 1*/
    }
    
    func configureView() {
        self.detailsView.layer.cornerRadius = self.detailsView.frame.size.width / 10
        self.detailsView.clipsToBounds = true
        self.detailsView.layer.borderWidth = 3.0
        if (patient != nil) {
           // self.detailsView.layer.borderColor = (patient?["status_color"] as! UIColor).cgColor
        } else {
            self.detailsView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func configureDetails() -> Bool {
        var isReloadCells: Bool = true
        if (patient != nil) {
            if let cmt = self.patient?["comment"] as? String {
                self.commentTextView.text = cmt
            }
            if (self.patient?["action"] as? String != nil && "stop" == self.patient?["action"] as? String) {
            self.sharing = true
                if (self.patient?["observer_id"] as? String != Manager.userData!["id"] as? String) {
                    self.enableInterfaceOutlets(flag: false)
                    
                }
            let paramIds = self.patient?["parameters"] as? [Int]
            if (paramIds?.count)! > 0 {
            //if paramIds.count != 0 {
                for i in 0..<(paramIds?.count)! {
                    for j in 0..<(self.actionHeaders?.count)! {
                        let id = paramIds?[i]
//                        if let index = self.actionParameterIds[j].index(where: ()) {
//                            self.selectedIndices.insert(IndexPath(row: index, section: j))
//                        }
                        for k in 0..<(self.actionParameterIds[j].count) {
                            if id == self.actionParameterIds[j][k] {
                               self.selectedIndices.insert(IndexPath(row: k, section: j))
                                break
                            }
                        }
                    }
                }

            //}
            }
               self.reloadActionCells()
               self.updateSharedIndicesCount()
               self.sendActionButton.setTitle("Stop Action", for: .normal)
               self.sendActionButton.backgroundColor = UIColor.red
               self.eventButton.isEnabled = false
               self.isStop = true
               isReloadCells = false
        }
 
            //self.age.text = patient?["age"] as? String
            //self.gender.text = patient?["gender"] as? String
            self.pickerTextField.text = patient?["location"] as? String
        }
        return isReloadCells
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
    
   
    func sendObservation(selectedParameters: [String], type: String, isEvent: Bool) -> Bool? {
        var isResponseSuccess: Bool? = nil
        /*var actionString = "["
        for param in selectedParameters {
            actionString = actionString+param+","
        }
        actionString = actionString+"]"*/
        
        var cmt: String? = nil
        if (self.commentTextView.text != self.commentPlaceholder) {
            cmt = self.commentTextView.text!
        }
        
        let parameters: Parameters = ["patient_id": patient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "start_time": self.actionTimeStamp!, "comment": (cmt != nil) ? cmt! : cmt, "parameters": selectedParameters, "action": type]
        print("para:\(parameters)")
        
        
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObservedParameters.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
            DispatchQueue.main.async(execute: {
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"successs") != nil{
                        self.displayAlertMessage(message: "Submitted :)")
                        isResponseSuccess = true
                    } else {
                        // Perform ACTION
                        self.displayAlertMessage(message: "Something went wrong :(")
                        isResponseSuccess = false
                    }
                    
                } else {
                    self.displayAlertMessage(message: "Server response is empty")
                    isResponseSuccess = false
                }
                
                if (isEvent == true) {
                    self.processEvent(isSendEvent: false, response: isResponseSuccess)
                } else {
                    self.processActions(isSendAction: false, response: isResponseSuccess)
                }
            })
        }
        return isResponseSuccess
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

extension DetailViewController: CommentEntryDelegate {
    func commentTextEntered(comment: String) {
        self.commentTextView.text = comment
        if (comment == self.commentPlaceholder) {
            self.commentTextView.textColor = UIColor.lightGray
        } else {
            self.commentTextView.textColor = UIColor.black
        }
    }
}

extension DetailViewController: PatientRootSelectionDelegate {
    
    func patientSelected(patientDetails: [String : Any], locationList: [String]) {
        print("inside detail's delegate")
        if (patientDetails.count > 0) {
        self.patient = patientDetails
        print(self.patient)
        //viewDidLoad()
            let doReload = self.configureDetails()
        self.configurePic()
            if (doReload == true) {
        self.sharing = false
        self.reloadActionCells()
            }
        }
        if (locationList.count > 0) {
            self.pickOption = locationList
            self.pickOption.sort()
        }
        
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = sectionInsets.left * CGFloat(itemsPerRow+1)
        let availableWidth = view.frame.width - padding
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem*self.cellWidthBooster, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let indexLoc = collectionView.layer.value(forKey: "indexLoc") as? IndexPath else { return 0}
        var itemCount = 0
        let sec = indexLoc.section
        if (!(self.actionList[sec].isEmpty)) {
            for i in 0..<actionList[sec].count {
                if (self.actionList[sec][i] == nil) {
                    break
                }
                itemCount += 1
            }
            return itemCount
        }
        return 0
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if Manager.userData!["id"] as! String == self.patient?["observer_id"] as? String || self.patient?["observer_id"] as? String == nil {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCIdentifier, for: indexPath) as! ActionCollectionViewCell
        guard let indexLoc = collectionView.layer.value(forKey: "indexLoc") as? IndexPath else { return }
        cell.actionView!.backgroundColor = UIColor.purple
        self.selectedIndices.remove(IndexPath(row: indexPath.row, section: indexLoc.section))
        self.updateSharedIndicesCount()
        
        if ((self.selectedIndices.count < 1) && self.sharing == true) {
            self.sharing = false
        }
        
        if let count = self.actionHeaders?.count {
            for i in 0..<count {
                if let cell = self.actionTableView.cellForRow(at: IndexPath(row: 0, section: i)) as? ActionTableViewCell {
                    cell.actionCollectionView.reloadData()
                }
            }
        }
    }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Manager.userData!["id"] as? String == self.patient?["observer_id"] as? String || self.patient?["observer_id"] as? String == nil {
        if (self.sharing == false) {
            self.sharing = true
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCIdentifier, for: indexPath) as! ActionCollectionViewCell
        
        guard let indexLoc = collectionView.layer.value(forKey: "indexLoc") as? IndexPath else { return }
        print("indexLoc:\(indexLoc)")
        cell.actionView!.backgroundColor = UIColor.green
        if (self.selectedIndices.contains(IndexPath(row: indexPath.row, section: indexLoc.section))) {
            self.collectionView(collectionView, didDeselectItemAt: indexPath)
            return
        }
        
        self.selectedIndices.insert(IndexPath(row: indexPath.row, section: indexLoc.section))
        self.updateSharedIndicesCount()
        self.reloadActionCells()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCIdentifier, for: indexPath) as! ActionCollectionViewCell
        guard let indexLoc = collectionView.layer.value(forKey: "indexLoc") as? IndexPath else { return cell }
        let sec = indexLoc.section
        cell.actionName.text = self.actionList[sec][indexPath.row]
        cell.actionName.numberOfLines = 0
        if (self.selectedIndices.contains(IndexPath(row: indexPath.row, section: sec))) {
            cell.actionView.backgroundColor = UIColor.green
        } else {
            cell.actionView!.backgroundColor = UIColor.purple
        }
        return cell
        
    }
    
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (actionHeaders != nil) {
            if let heading = actionHeaders?[section] {
                return heading
            }
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if actionHeaders != nil {
            if let count = actionHeaders?.count {
                return count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.actionList.count != 0 {
            return 1
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let padding = sectionInsets.left * CGFloat(itemsPerRow+1)
        let availableWidth = view.frame.width - padding
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        //cell.collectionViewHeight.constant = 200//widthPerItem+40//
        return widthPerItem*self.cellHeightBooster
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = actionTableView.dequeueReusableCell(withIdentifier: self.reuseTIdentifier, for: indexPath) as! ActionTableViewCell
        //cell.frame = tableView.bounds
        //cell.layoutIfNeeded()
        //cell.actionCollectionView.reloadData()
        //if let layout = cell.actionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
        //    layout.scrollDirection = .horizontal
        //}
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplayCell cell: UITableViewCell,
                   forRowAtIndexPath indexPath: NSIndexPath) {
        guard let tableViewCell = cell as? ActionTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row, forSection: indexPath.section)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.section][indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   didEndDisplayingCell cell: UITableViewCell,
                   forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? ActionTableViewCell else { return }
        
        storedOffsets[indexPath.section][indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    
}

