//
//  ViewController.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/5/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import CoreBluetooth

class DetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,  UITextViewDelegate {
    
    @IBOutlet weak var actionTableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var hamburger: UIBarButtonItem!
    @IBOutlet weak var sendActionButton: UIButtonX!
    //@IBOutlet weak var eventButton: UIButtonX!
    @IBOutlet weak var multiSelect: UIButtonX!
    
    @IBOutlet weak var selectedCount: UILabelX!
    @IBOutlet weak var clearActionsButton: UIButtonX!
    @IBOutlet weak var picture: UIImageViewX!
    @IBOutlet weak var age: UILabelX!
    //@IBOutlet weak var gender: UILabel!
    @IBOutlet weak var detailsView: UIViewX!
    @IBOutlet weak var runningTime: UILabelX!
    @IBOutlet weak var pickerTextField: UITextFieldX!
    @IBOutlet weak var commentButton: UIButtonX!
    
    fileprivate let reuseTIdentifier = "actionTableCell"
    fileprivate let reuseCIdentifier = "actionCollectionCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
    fileprivate var itemsPerRow = 11
    fileprivate var actionList = [[String?]](repeating: [String?](repeating:nil, count:12), count: 4)
    fileprivate var actionParameterList = [[String?]](repeating: [String?](repeating:nil, count:12), count: 4)
    fileprivate var actionParameterIds = [[String?]](repeating: [String?](repeating:nil, count:12), count: 4)
    fileprivate var storedOffsets: [[CGFloat?]] = Array(repeating: Array(repeating:0, count:3), count: 4)
    fileprivate var actionHeaders: [String]?
    fileprivate var selectedIndices = Set<IndexPath>()
    fileprivate var multiSelectedIndices = Set<IndexPath>()
    fileprivate var fSelectedParameters = [String]()
    fileprivate var fType: String?
    fileprivate var fSelectionType: String?
    fileprivate var fRecordedTime: String?
    fileprivate var fCell: ActionCollectionViewCell?
    fileprivate var fIndexPath: IndexPath?
    
    var actionTimeStamp: String?
    var observerParameters: Dictionary<String,Any>?
    var patient: [String:Any]?
    var commentTextVar: String?
    //var locationSet: Set<String> = [] //["Room 1", "Room 2", "Room 3", "Room 4", "Room 5"]
    var pickOption = [String]()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var cellHeightBooster: CGFloat = 1.7
    var cellWidthBooster: CGFloat = 1
    let commentPlaceholder: String = "write your observations"
    var isStop: Bool = false
    var multiOn: String = "On Multi-select"
    var multiOff: String = "Off Multi-select"
    var reloadView: Bool = true
    var location: String?
    
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
            //self.actionTimeStamp = self.getTimestamp()
            //print("time noted:\(self.actionTimeStamp)")
            //self.sendActionButton.isHidden = false
            //self.selectedCount.isHidden = false
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
        //if (self.reloadView == true) {
        self.updateTime()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        //let mvc = ModelViewController()
        //mvc.delegate = self
        self.commentTextView.delegate = self
        if !(self.commentTextView?.text.isEmpty)!  {
            self.commentTextView.textColor = UIColor.black
        } else {
            self.commentTextView.text = self.commentPlaceholder
            self.commentTextView.textColor = UIColor.lightGray
        }
        self.title = "Agitation Monitor"
        self.picture.image = #imageLiteral(resourceName: "labimg")
        
        self.multiSelect.isEnabled = false
        self.sendActionButton.isEnabled = false
        
        self.multiSelect.backgroundColor = UIColor.blue
        self.sendActionButton.backgroundColor = UIColor.blue
        self.commentButton.backgroundColor = UIColor.blue
        
        self.enableInterfaceOutlets(flag: true)
        self.clearActionsButton.isHidden = true
        self.selectedCount.isHidden = true
        
        //self.configurePic()
        //self.configureView()
        //self.configureDetails()

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.imageTapped(_:)))
        imageTap.numberOfTapsRequired = 1
        self.picture.addGestureRecognizer(imageTap)
        
        /*
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
                    self.actionHeaders = json["sections"] as? [String]/*["Physical / Aggressive", "Physical / Non-Aggressive", "Verbal / Aggressive", "Verbal / Non-aggressive"]*/
                    //self.actionHeaders?.remove(at: 3)
                    //self.actionHeaders?.remove(at: 2)
                    //self.actionHeaders?.append("Verbal")
                    if let actionDict = json["categories"] as? [Dictionary<String,Any>] {
                        //print("actioDict:\(actionDict)")
                        var secVerbalCount = 0
                        if 0 < actionDict.count && self.actionHeaders?.count == actionDict.count {
                            for section in 0..<(self.actionHeaders?.count)! {
                                
                                let sectionDict = actionDict[section][(self.actionHeaders?[section])!] as! [Dictionary<String,String>]
                                //let sectionDict = actionDict[(self.actionHeaders?[section])!] as! [Dictionary<String,String>]
                                
                                if ((self.actionHeaders?[section])! == "Verbal / Agitated" && section == 2) {
                                    self.actionList[section].insert("Agitated", at: 0)
                                    self.actionParameterList[section].insert("Agitated", at: 0)
                                    self.actionParameterIds[section].insert("100", at: 0)
                                } else if ((self.actionHeaders?[section])! == "Verbal / Non-Agitated" && section == 3) {
                                    secVerbalCount = secVerbalCount + 1
                                    self.actionList[2].insert("Non-Agitated", at: secVerbalCount)
                                    self.actionParameterList[2].insert("Non-Agitated", at: secVerbalCount)
                                    self.actionParameterIds[2].insert("101", at: secVerbalCount)
                                    
                                }

                            
                                for param in 0..<sectionDict.count {
                                    print("section,row: \(section),\(param)")
                                    print("**********")
                                   /* if (section == 2 || section == 3) {
                                        let tempActionList = sectionDict[param]["short_name"]!
                                        if (section == 2) {
                                        self.actionList[2].append("Agitated")
                                        } else {
                                            self.actionList[2].append("Non-Agitated")
                                        }
                                        self.actionList[2].append(tempActionList)
                                        
                                        let tempParameterList = sectionDict[param]["parameter_name"]!
                                        if (section == 2) {
                                        self.actionList[2].append("Agitated")
                                        } else {
                                            self.actionList[2].append("Non-Agitated")
                                        }
                                    self.actionParameterList[2].append(tempParameterList)
                                       
                                        let tempParameterIds = sectionDict[param]["parameter_id"]!
                                        if (section == 2) {
                                        self.actionParameterIds[2].append("100")
                                        } else {
                                            self.actionParameterIds[2].append("101")
                                        }
                                        self.actionParameterIds[2].append(tempParameterIds)
                                        
                                    } else {*/
                                    
                                    if (section == 2 || section == 3) {
                                        //if (section == 2) {
                                            secVerbalCount = secVerbalCount + 1
                                        //}
                                    print(sectionDict[param]["short_name"]!)
                                        self.actionList[2].insert(sectionDict[param]["short_name"]!, at: secVerbalCount)
                                        self.actionParameterList[2].insert(sectionDict[param]["parameter_name"]!, at: secVerbalCount)
                                        self.actionParameterIds[2].insert(sectionDict[param]["parameter_id"]!, at: secVerbalCount)
                                    } else {
                                        self.actionList[section].insert(sectionDict[param]["short_name"]!, at: param)
                                        self.actionParameterList[section].insert(sectionDict[param]["parameter_name"]!, at: param)
                                        self.actionParameterIds[section].insert(sectionDict[param]["parameter_id"]!, at: param)
                                    }
                                    //}
                                    // #get the id's as well in a separate list
                                    //self.actionParameterList?[section][param] = sectionDict[param]["parameter_name"]!
                                    //print("result:\(self.actionList[section][param])")
                                    
                                    /*
                                     let section1 = actionDict["Physical / Aggressive"/*(self.actionHeaders?[0])!*/] as? [String]
                                     let section2 = actionDict[(self.actionHeaders?[1])!] as? [String]
                                     let section3 = actionDict[(self.actionHeaders?[2])!] as? [String]
                                     let section4 = actionDict[(self.actionHeaders?[3])!] as? [String]
                                     
                                     
                                     self.actionList = [section1!,section2!,section3!,section4!]*/
                                    //self.constructActionDict(sectionCount: actionDict.count)
                                }
                                print("***********************************")
                                print(self.actionList[section])
                                print("***********************************")
                            }
                        }
                        secVerbalCount = 0
                    }
                    //print("************size if actionList:\(self.actionList[0].count)")
                    print("final list: \(self.actionList)::::)")
                                    DispatchQueue.main.async(execute: {
                                        self.actionTableView.reloadData()
                                        self.addGestureToCells()
                                        self.getAllPatients()
                                        self.stopActivityIndicator()
                                    })
                                }
                
                            //}
            
                            
                       //}
                    //}
                //}
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
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //self.stackHeader.backgroundColor = UIColor.
        
        
        actionTableView.rowHeight = UITableViewAutomaticDimension
        actionTableView.estimatedRowHeight = 240
        
        //pickOption.append(contentsOf: self.locationSet.sorted())
        self.initPicker()
       /* } else {
            self.reloadView = true
            //Manager.reloadAllView = true
            if (self.location != nil) {
             self.pickerTextField.text = self.patient?["location"] as! String
             //self.location = nil
            }
        }*/
        
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
    func strToArray(explodeString: String?) -> [String] {
        if (explodeString != nil) {
            let temp = explodeString?.trimmingCharacters(in: ["[","]"])
            return (temp?.components(separatedBy: ","))!
        }
        return []
    }
    
    func getAllPatients() {
        let userid = Manager.userData!["id"] as! String
        let role = Manager.userData!["role"] as! String
        // Do any additional setup after loading the view, typically from a nib.
        let parameters: Parameters = ["user_id": userid, "role": role]
        print(parameters)
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getPatientDetails.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
            DispatchQueue.main.async(execute: {
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                    Manager.patientDetails = json["patient_details"] as? [Dictionary<String,Any>]
                    self.patient = Manager.patientDetails?[0]
                    if self.patient != nil {
                    print("PATIENT, obser: \(self.patient), \(userid)")
                    let params: Parameters = ["patient_id": self.patient!["id"], "observer_id": userid as Any]
                    Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getObservationstate.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
                        DispatchQueue.main.async(execute: {
                        if let data = response.data {
                            do {
                                
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                                let prevState = json["pastdetails"] as? [Dictionary<String,Any>]
                                if (prevState != nil) {
                                self.patient?["action"] = prevState?[0]["action"] as? String
                                self.patient?["comment"] = prevState?[0]["comments"] as? String
                                self.patient?["observer_id"] = prevState?[0]["observer_id"] as? String
                                let strToArray: [String] = self.strToArray(explodeString: prevState?[0]["parameters"] as? String)
                                self.patient?["parameters"] = strToArray
                                    
                                self.patient?["multi_parameters"] = self.strToArray(explodeString: prevState?[0]["multi_parameters"] as? String)
                                //self.patient?["parameters"] = [5,10,14]
                                }
                                //DispatchQueue.main.async(execute: {
                                      //self.configurePic()
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
                }
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
    
    func addGestureToCells() {
        /*
        let collectionViewCellTap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.onCellDoubledTapped(_:)))
        collectionViewCellTap.numberOfTapsRequired = 2
        collectionViewCellTap.delaysTouchesBegan = true
        if let count = self.actionHeaders?.count {
            for i in 0..<count {
                if let cell = self.actionTableView.cellForRow(at: IndexPath(row: 0, section: i)) as? ActionTableViewCell {
                    //cell.actionCollectionView.reloadData()
                    cell.actionCollectionView.addGestureRecognizer(collectionViewCellTap)
                }
            }
        }
         */
    }
    
    func onCellDoubledTapped(_ sender: UITapGestureRecognizer) {
        
        print("I AM DOUBLE")
        if let count = self.actionHeaders?.count {
            for i in 0..<count {
                if let tCell = self.actionTableView.cellForRow(at: IndexPath(row: 0, section: i)) as? ActionTableViewCell {
                    if let indexPath = tCell.actionCollectionView?.indexPathForItem(at: sender.location(in: tCell.actionCollectionView)) {
                        if (indexPath.section == 2 && (indexPath.row == 0 || indexPath.row == 4)) {
                            return
                        }
                        
                        if Manager.userData!["id"] as? String == self.patient?["observer_id"] as? String || self.patient?["observer_id"] as? String == nil {
                            if (self.pickerTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                                self.displayAlertMessage(message: "Please choose location first")
                                return
                            }
                            if (self.sharing == false) {
                                self.sharing = true
                            }
                        
                        //let cell = cell.collectionView?.cellForItem(at: indexPath)
                        print("you can do something with the cell or index path here")
                        //////////////
                        
                       
                            
                            let cell = tCell.actionCollectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCIdentifier, for: indexPath) as! ActionCollectionViewCell
                            
                            guard let indexLoc = tCell.actionCollectionView.layer.value(forKey: "indexLoc") as? IndexPath else { return }
                            print("indexLoc:\(indexLoc)")
                            
                            if (self.selectedIndices.contains(IndexPath(row: indexPath.row, section: indexLoc.section))) {
                                self.collectionView(tCell.actionCollectionView, didDeselectItemAt: indexPath)
                                return
                            }
                            
                            //if (self.multiSelect.title(for: .normal) == self.multiOn) {
                                if let parameter = self.actionParameterList[indexLoc.section][indexPath.row] {
                                    let timeClicked: String = self.getTimestamp()
                                    /*if (self.multiSelect.title(for: .normal) == self.multiOff) {
                                     timeClicked = self.actionTimeStamp != nil ? self.actionTimeStamp! : self.getTimestamp()
                                     } else {
                                     timeClicked = self.getTimestamp()
                                     }*/
                                    //self.displayConfirmation(message: "Click 'Ok' to capture continuous action", selectedParameters: [parameter], type: "start event", selectionType: "select", cell: cell, indexPath: IndexPath(row: indexPath.row, section: indexLoc.section), recordedTime: timeClicked)
                                    self.displayActions(selectedParameters: [parameter], type: "start event", selectionType: "select", cell: cell, indexPath: IndexPath(row: indexPath.row, section: indexLoc.section), recordedTime: timeClicked)
                                    
                                }
                                
                                
                                /*print("HEHEEEEEEEEEEEEEEEEeeeeeeeeeeee")
                                 if (isSuccess != nil && isSuccess == true) {
                                 print("HEHEEEEEEEEEEEEEEEEeeeeeeeeeeee inside")
                                 self.selectedIndices.insert(IndexPath(row: indexPath.row, section: indexLoc.section))
                                 self.updateSharedIndicesCount()
                                 cell.actionView!.backgroundColor = UIColor.green
                                 self.reloadActionCells()
                                 }*/
                            /*} else {
                                self.configSelectedCell(isSuccess: true, cell: cell, indexPath: IndexPath(row: indexPath.row, section: indexLoc.section))
                            }*/
                        } else {
                            self.displayAlertMessage(message: "you cannot modify other observer's record. Allow \(self.patient?["observer_id"] as? String) to submit the action(s)")
                        }

                        
                        /////////////
                    } else {
                        print("collection view was tapped")
                    }
                }
            }
        }
        
        
    }
    
    func changePatientDetails(modifiedPatient: [String: Any]) {
        if (Manager.patientDetails != nil) {
        for i in 0..<(Manager.patientDetails?.count)! {
            if (String(describing: Manager.patientDetails?[i]["id"]) == String(describing: modifiedPatient["id"])) {
                Manager.patientDetails?[i]["location"] = modifiedPatient["location"] as? String
                break
            }
        }
            if (self.patient != nil) {
                if (String(describing: self.patient?["id"]) == String(describing:modifiedPatient["id"])) {
                    self.patient?["location"] = modifiedPatient["location"] as? String
                        self.pickerTextField.text = modifiedPatient["location"] as! String
                        print("whats in picker? \(self.pickerTextField.text)")
                    
                }
            }
        }
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
        self.selectedCount.textColor = UIColor.blue
        self.selectedCount.text = "\(self.selectedIndices.count) actions selected"
        self.selectedCount.sizeToFit()
        print("selected indices:\(self.selectedIndices)")
        if self.selectedIndices.count > 0 {
            self.selectedCount.isHidden = false
            self.clearActionsButton.isHidden = false
        } else {
            self.selectedCount.isHidden = true
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
    
    /*func prepareToSendData(actionType: String) -> Bool?{
        var selectedParameters = [String]()
        //if let selList = self.selectedIndices? {
       //# for idx in self.multiSelectedIndices {
            //print("action dict:\(self.actionDictionary)")
            //let key = (idx.section*10)+(idx.row)
            //if let _ = self.actionDictionary?.index(forKey: key) {
            //    selectedParameters.append((self.actionDictionary?[key])!)
            //}
         //#   selectedParameters.append((self.actionParameterList[idx.section][idx.row])!)
        //#}
        //}
        let tCell = self.actionTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ActionTableViewCell
        let cell = tCell?.actionCollectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCIdentifier, for: IndexPath(row: 0, section: 0)) as! ActionCollectionViewCell
        return self.sendObservation(selectedParameters: selectedParameters, type: actionType, selectionType: "multi", cell: cell, indexPath: IndexPath(row: 0, section: 0), recordedTime: self.actionTimeStamp == nil ? self.getTimestamp() : self.actionTimeStamp!)
    }*/
    
    
    
   /* func processActions(isSendAction: Bool, response: Bool?) {
        var resp: Bool? = response
        if (self.sendActionButton.title(for: .normal) == "Start Action") {
            if (isSendAction == true) {
                resp = self.prepareToSendData(actionType: "start event")
            }
                if (resp != nil && resp! == true) {
                    self.sendActionButton.setTitle("Stop Action", for: .normal)
                    self.sendActionButton.backgroundColor = UIColor.orange
                    
                    self.multiSelect.setTitle(self.multiOn, for: .normal)
                    self.multiSelect.backgroundColor = UIColor.blue
                    self.multiSelect.isEnabled = false
                    //self.eventButton.isEnabled = false
                    self.isStop = true
                }
            
        } else {
            self.actionTimeStamp = self.getTimestamp()
            if (isSendAction == true) {
            resp = self.prepareToSendData(actionType: "stop event")
            }
                if (resp != nil && resp! == true) {
                    
                    for index in self.multiSelectedIndices {
                        if (self.selectedIndices.contains(index)) {
                            self.selectedIndices.remove(index)
                        }
                    }
                    self.multiSelectedIndices.removeAll(keepingCapacity: false)
                    if (self.selectedIndices.isEmpty) {
                        self.sharing = false
                    } else {
                    self.updateSharedIndicesCount()
                    }
                    
                    self.reloadActionCells()
                    self.sendActionButton.setTitle("Start Action", for: .normal)
                    self.sendActionButton.backgroundColor = UIColor.blue
                    //self.eventButton.isEnabled = true
                    //self.multiSelect.isEnabled = true
                    self.isStop = false
                }
            
        }
    }*/
    
    @IBAction func onMultiSelect(_ sender: Any) {
       /* for index in self.multiSelectedIndices {
            if (self.selectedIndices.contains(index)) {
                self.selectedIndices.remove(index)
            }
        }
        self.multiSelectedIndices.removeAll(keepingCapacity: false)
        self.updateSharedIndicesCount()
        self.reloadActionCells()
        if (self.multiSelect.title(for: .normal) == self.multiOn) {
            self.actionTimeStamp = self.getTimestamp()
            self.multiSelect.setTitle(self.multiOff, for: .normal)
            self.multiSelect.backgroundColor = UIColor.orange
        } else {
            self.multiSelect.setTitle(self.multiOn, for: .normal)
            self.multiSelect.backgroundColor = UIColor.blue
        }*/
    }
    
    @IBAction func shareMultiAction(_ sender: Any) {
       /* guard !self.multiSelectedIndices.isEmpty else {
            self.displayAlertMessage(message: "No actions selected")
            //self.sharing = !self.sharing
            return
        }
        
        //guard sharing else { return }
        self.processActions(isSendAction: true, response: nil)*/
    }
    /*
    func processEvent(isSendEvent: Bool, response: Bool?) {
        var resp: Bool? = response
        if (isSendEvent == true) {
            resp = self.prepareToSendData(actionType: "single event", isEvent: true)
        }
        if (resp != nil && resp! == true) {
            self.sharing = false
            self.reloadActionCells()
        }
    }*/
    
    /*@IBAction func shareEvent(_ sender: Any) {
        guard !self.selectedIndices.isEmpty else {
            self.displayAlertMessage(message: "No actions selected")
            //self.sharing = !self.sharing
            return
        }
        
        guard sharing else { return }
        self.processEvent(isSendEvent: true, response: nil)
        
    }*/
    
    
    @IBAction func clearActions(_ sender: Any) {
        var selectedParameters = [String]()
        var allSelIndices = self.selectedIndices
       /* if (self.sendActionButton.title(for: .normal) == "Stop Action") {
            if (!self.multiSelectedIndices.isEmpty) {
                for idx in self.multiSelectedIndices {
                    selectedParameters.append((self.actionParameterList[idx.section][idx.row])!)
                    if (allSelIndices.contains(idx)) {
                        allSelIndices.remove(idx)
                    }
                }
            }
            
            self.sendActionButton.setTitle("Start Action", for: .normal)
            self.sendActionButton.backgroundColor = UIColor.blue
            //self.multiSelect.isEnabled = true
        }*/
        
        if (!allSelIndices.isEmpty) {
        for idx in allSelIndices {
            selectedParameters.append((self.actionParameterList[idx.section][idx.row])!)
        }
            let tCell = self.actionTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ActionTableViewCell
            let cell = tCell?.actionCollectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCIdentifier, for: IndexPath(row: 0, section: 0)) as! ActionCollectionViewCell
            self.sendObservation(selectedParameters: selectedParameters, type: "stop event", selectionType: "clear", cell: cell, indexPath: IndexPath(row: 0, section: 0), recordedTime: self.getTimestamp())
        } else {
        
        //self.multiSelectedIndices.removeAll(keepingCapacity: false)
        self.sharing = false
        self.reloadActionCells()
        }
    }
    
    func clearActions(isSuccess: Bool?) {
        
        if (isSuccess != nil && isSuccess == true) {
        //self.multiSelectedIndices.removeAll(keepingCapacity: false)
        self.sharing = false
        self.reloadActionCells()
        } else {
            self.displayAlertMessage(message: "Cannot clear as server is unable to stop actions")
        }

    }

    
    func sendPatientState() {
        var isResponseSuccess: Bool? = nil
        var cmt: String? = nil
        if (self.commentTextView != nil && self.commentTextView.text != self.commentPlaceholder) {
            cmt = self.commentTextView.text!
        } else {
            cmt = ""
        }
        
        var selectedIds = [Int]()
        var multiSelectedIds = [Int]()
        var selIndices = self.selectedIndices
        
       /* for idx in self.multiSelectedIndices {
            multiSelectedIds.append(Int(self.actionParameterIds[idx.section][idx.row]!)!)
            if (selIndices.contains(idx)) {
                selIndices.remove(idx)
            }
        }*/
        
        
        for idx in selIndices {
            print("track ids selected: \(self.actionParameterIds[idx.section][idx.row]!)")
            selectedIds.append(Int(self.actionParameterIds[idx.section][idx.row]!)!)
        }
        
        let parameters: Parameters = ["patient_id": patient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "comment": (cmt != nil) ? cmt! : cmt as Any, "parameters": selectedIds, "multi_parameters": multiSelectedIds/*, "action": "stop"*/]
        
        print("para:\(parameters)")
        
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObservationState.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
            DispatchQueue.main.async(execute: {
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"success") != nil {
                        //self.displayAlertMessage(message: "Submitted :)")
                        print("Success")
                        isResponseSuccess = true
                    } else {
                        // Perform ACTION
                        //self.displayAlertMessage(message: "Something went wrong :(")
                        isResponseSuccess = false
                        print("no success")
                    }
                    
                } else {
                    //self.displayAlertMessage(message: "Server response is empty")
                    isResponseSuccess = false
                    print("no success")
                }

            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if segue.identifier == "modelSegue" {
            if let destinationController = segue.destination as? ModelViewController {
                destinationController.delegate = self
                if let data = self.commentTextView?.text {
                    destinationController.data = data
                } else {
                    destinationController.data = nil
                }
            }
        } else*/ if (segue.identifier == "patientSegue") {
            if (/*self.isStop == true || */self.commentTextView.text != self.commentPlaceholder || self.selectedIndices.count > 0) {
                self.sendPatientState()
            }
            if let destinationVC = segue.destination as? PatientRootTableViewController {
                destinationVC.patientDelegate = self
            }
        }
    }
    
    func imageTapped(_ gestureRecognizer: UIGestureRecognizer) {
        /*let graphController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NextDetailViewController") as! NextDetailViewController
        self.present(graphController, animated: true, completion: nil)
         */
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
        //self.sendActionButton.isEnabled = flag
        //self.eventButton.isEnabled = flag
        self.clearActionsButton.isEnabled = flag
        //self.commentButton.isEnabled = flag
        self.pickerTextField.isEnabled = flag
    }
    
    func configurePic() {
        //self.picture.image = #imageLiteral(resourceName: "labimg")
        if let gender = patient?["gender"] as? String {
            if (gender == "m") {
                self.picture.image = #imageLiteral(resourceName: "Male-1400")
            } else if (gender == "f") {
                self.picture.image = #imageLiteral(resourceName: "Female User-1400")
            } else {
                self.picture.image = #imageLiteral(resourceName: "labimg")
            }
        }
        //self.picture.layer.cornerRadius = self.picture.frame.size.width/10
        self.picture.clipsToBounds = true
        self.picture.contentMode = .scaleAspectFill
        //self.picture.layer.borderColor = UIColor.gray.cgColor
        //self.picture.layer.borderWidth = 1*/
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
            //if let cmt = self.patient?["comment"] as? String {
            if (self.patient?["comment"] != nil && self.patient?["comment"] as! String != "nil" && self.patient?["comment"] as! String != self.commentPlaceholder) {
                self.commentTextView.text = self.patient?["comment"] as! String
            } else {
                    self.commentTextView.text = self.commentPlaceholder
                    self.commentTextView.textColor = UIColor.lightGray
            }
            //if (self.patient?["action"] as? String != nil && "stop" == self.patient?["action"] as? String) {
            //if ((((self.patient?["parameters"] as? [String])?.count)! > 0) || (((self.patient?["multi_parameters"] as? [String])?.count)! > 0)) {
            if (self.patient?["parameters"] as? [String] != nil /*|| self.patient?["multi_parameters"] as? [String] != nil*/) {
            self.sharing = true
            self.multiSelectedIndices.removeAll(keepingCapacity: false)
                print("observer in selected patient:\(self.patient?["observer_id"] as? String), \(Manager.userData!["id"] as? String)")
                if (self.patient?["observer_id"] as? String != Manager.userData!["id"] as? String) {
                    self.enableInterfaceOutlets(flag: false)
                    
                } else {
                    self.enableInterfaceOutlets(flag: true)
                    //self.eventButton.isEnabled = false
                }
                
                if let paramIds = self.patient?["parameters"] as? [String] {
            if (paramIds.count > 0) {
            //if paramIds.count != 0 {
                for i in 0..<(paramIds.count) {
                    for j in 0..<(self.actionHeaders?.count)! {
                        let id = Int((paramIds[i]))
//                        if let index = self.actionParameterIds[j].index(where: ()) {
//                            self.selectedIndices.insert(IndexPath(row: index, section: j))
//                        }
                        for k in 0..<(self.actionParameterIds[j].count) {
                            print("is null id: \(actionParameterIds[j][k])")
                            if self.actionParameterIds[j][k] == nil {
                                break
                            }
                            if id == Int(self.actionParameterIds[j][k]!) {
                               self.selectedIndices.insert(IndexPath(row: k, section: j))
                                break
                            }
                        }
                    }
                }

            //}
            }
                }
                
                
                
               /* if let multiParamIds = self.patient?["multi_parameters"] as? [String] {
                if (multiParamIds.count > 0) {
                    for i in 0..<multiParamIds.count {
                        for j in 0..<(self.actionHeaders?.count)! {
                            let id = Int((multiParamIds[i]))

                            for k in 0..<(self.actionParameterIds[j].count) {
                                if self.actionParameterIds[j][k] == nil {
                                    break
                                }
                                if id == Int(self.actionParameterIds[j][k]!) {
                                    self.multiSelectedIndices.insert(IndexPath(row: k, section: j))
                                    self.selectedIndices.insert(IndexPath(row: k, section: j))
                                    break
                                }
                            }
                        }
                    }
                    self.sendActionButton.setTitle("Stop Action", for: .normal)
                    self.sendActionButton.backgroundColor = UIColor.orange
                    self.multiSelect.isEnabled = false
                }
                }*/
                
               self.reloadActionCells()
               self.updateSharedIndicesCount()
               
               //self.isStop = true
               isReloadCells = false
            } else {
                //self.sendActionButton.setTitle("Start Action", for: .normal)
                //self.sendActionButton.backgroundColor = UIColor.blue
                //self.sendActionButton.isEnabled = true
                //self.multiSelect.isEnabled = true
                //self.eventButton.isEnabled = true
                //self.isStop = false
                isReloadCells = true
 
            }
            self.title = patient?["name"] as? String
            self.configurePic()
            self.age.text = (patient?["age"] as? String)! + " yrs"
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
    
    func displayConfirmation(message: String, selectedParameters: [String], type: String, selectionType: String, cell: ActionCollectionViewCell, indexPath: IndexPath, recordedTime: String) {

        let confirmationAlert = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.sendObservation(selectedParameters: selectedParameters, type: type, selectionType: selectionType, cell: cell, indexPath: indexPath, recordedTime: recordedTime)
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(confirmationAlert, animated: true, completion: nil)

    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        
        pickerTextField.resignFirstResponder()
        
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        
        pickerTextField.text = "Town Center"
        
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
    
    func configSelectedCell(isSuccess: Bool, cell: ActionCollectionViewCell, indexPath: IndexPath) {
        if (isSuccess == true) {
            self.selectedIndices.insert(indexPath)
            self.updateSharedIndicesCount()
            if (self.multiSelect.title(for: .normal) == self.multiOn) {
            cell.actionView!.backgroundColor = UIColor.green
            } else {
                cell.actionView!.backgroundColor = UIColor.orange
                self.multiSelectedIndices.insert(indexPath)
            }
            self.reloadActionCells()
        }
    }
    
    func configDeselectedCell(isSuccess: Bool, cell: ActionCollectionViewCell, indexPath: IndexPath) {
        if (isSuccess == true) {
            cell.actionView!.backgroundColor = UIColor.darkGray
            cell.actionName.textColor = UIColor.white
            self.selectedIndices.remove(indexPath)
            if ((self.selectedIndices.count < 1) && self.sharing == true) {
                self.sharing = false
            } else {
            self.updateSharedIndicesCount()
            }
            
            //if (self.multiSelect.title(for: .normal) == self.multiOn) {
            if (self.multiSelectedIndices.contains(indexPath)) {
                self.multiSelectedIndices.remove(indexPath)
            }
            //}
            
            if ((self.multiSelectedIndices.count < 1)) {
                if (self.sendActionButton.title(for: .normal) == "Stop Action") {
                    self.sendActionButton.setTitle("Start Action", for: .normal)
                    self.sendActionButton.backgroundColor = UIColor.blue
                    //self.multiSelect.isEnabled = true
                }
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
    
    func addComment() {
        var mVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ModelViewController") as! ModelViewController
        var modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.coverVertical
        mVC.modalTransitionStyle = modalStyle
        mVC.delegate = self
        mVC.data = self.commentTextVar
        self.present(mVC, animated: true, completion: nil)
    }
   
    func displayActions(selectedParameters: [String], type: String, selectionType: String, cell: ActionCollectionViewCell, indexPath: IndexPath, recordedTime: String) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let commentAction = UIAlertAction(title: "Add comment", style: .default) { (action) in
            self.fSelectedParameters = selectedParameters
            self.fType = type
            self.fSelectionType = selectionType
            self.fRecordedTime = recordedTime
            self.fCell = cell
            self.fIndexPath = indexPath
            self.addComment()
        }
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { (action) in
            self.commentTextVar = nil
            self.sendObservation(selectedParameters: selectedParameters, type: type, selectionType: selectionType, cell: cell, indexPath: indexPath, recordedTime: recordedTime)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(commentAction)
        alertController.addAction(continueAction)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func sendObservation(selectedParameters: [String], type: String, selectionType: String, cell: ActionCollectionViewCell, indexPath: IndexPath, recordedTime: String) -> Bool? {
        var isResponseSuccess: Bool? = nil
        
        /*
        var selection: String = ""
        if (selectionType == "clear") {
            selection = "deselect"
        } else {
            selection = selectionType
        }*/
        /*var actionString = "["
        for param in selectedParameters {
            actionString = actionString+param+","
        }
        actionString = actionString+"]"*/
        
        /*var cmt: String? = nil
        if (self.commentTextView != nil && self.commentTextView.text != self.commentPlaceholder) {
            cmt = self.commentTextView.text!
        } else {
            cmt = ""
        }*/
        
        var loc: String = ""
        if (self.pickerTextField.text != nil) {
            loc = self.pickerTextField.text!
        } else {
            loc = ""
        }
        
        if (self.patient != nil && Manager.userData != nil) {
            let parameters: Parameters = ["patient_id": patient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "start_time": recordedTime, "comment": (self.commentTextVar != nil) ? self.commentTextVar! : self.commentTextVar, "parameters": selectedParameters, "action": type, "selectionType": selectionType ,"location" : loc ]
        print("para:\(parameters)")
        
        
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObservedParameters.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
            DispatchQueue.main.async(execute: {
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"success") != nil{
                        //self.displayAlertMessage(message: "Submitted :)")
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
                
                /*if (isEvent == true) {
                    self.processEvent(isSendEvent: false, response: isResponseSuccess)
                } else {
                    self.processActions(isSendAction: false, response: isResponseSuccess)
                }*/
                
                if (selectionType == "select") {
                    self.configSelectedCell(isSuccess: isResponseSuccess!, cell: cell, indexPath: indexPath)
                } else if (selectionType == "deselect") {
                    self.configDeselectedCell(isSuccess:isResponseSuccess!, cell: cell, indexPath: indexPath)
                } /*else if (selectionType == "multi") {
                    self.processActions(isSendAction: false, response: isResponseSuccess)
                }*/ else if (selectionType == "clear") {
                    self.clearActions(isSuccess: isResponseSuccess)
                } else if (selectionType == "single") {
                    //to do
                }
            })
        }
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
        /*self.commentTextView.text = comment
        if (comment == self.commentPlaceholder) {
            self.commentTextView.textColor = UIColor.lightGray
        } else {
            self.commentTextView.textColor = UIColor.black
        }*/
        if (comment == self.commentPlaceholder) {
            self.commentTextVar = nil
        } else {
            self.commentTextVar = comment
        }
        if (self.fSelectedParameters != nil && self.fSelectionType != nil && self.fRecordedTime != nil &&
            self.fType != nil && self.fCell != nil && self.fIndexPath != nil) {
            self.sendObservation(selectedParameters: self.fSelectedParameters, type: self.fType!, selectionType: self.fSelectionType!, cell: self.fCell!, indexPath: self.fIndexPath!, recordedTime: self.fRecordedTime!)
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
        //self.configurePic()
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
        
        return CGSize(width: widthPerItem*self.cellWidthBooster, height: widthPerItem*self.cellHeightBooster)
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
            if (indexLoc.section == 2 && (indexPath.row == 0 || indexPath.row == 4)) {
                return
            }
           // if (self.multiSelect.title(for: .normal) == self.multiOn) {
            if let parameter = self.actionParameterList[indexLoc.section][indexPath.row] {
                let timeClicked = self.getTimestamp()
                //if (self.multiSelectedIndices.contains(IndexPath(row: indexPath.row, section: indexLoc.section))) {
                     //self.configDeselectedCell(isSuccess: true, cell: cell, indexPath: IndexPath(row: indexPath.row, section: indexLoc.section))
                //    self.displayConfirmation(message: "Click 'Ok' to send", selectedParameters: [parameter], type: "stop event", selectionType: "multi", cell: cell, indexPath: IndexPath(row: indexPath.row, section: indexLoc.section), recordedTime: timeClicked)
                //}
                //    else {
                
                self.displayConfirmation(message: "Click 'Ok' to stop action", selectedParameters: [parameter], type: "stop event", selectionType: "deselect", cell: cell, indexPath: IndexPath(row: indexPath.row, section: indexLoc.section), recordedTime: timeClicked)
                //}
            }
            /*} else {
                self.configDeselectedCell(isSuccess: true, cell: cell, indexPath: IndexPath(row: indexPath.row, section: indexLoc.section))
            }*/
            
//            if (isSuccess != nil && isSuccess == true) {
//        cell.actionView!.backgroundColor = UIColor.darkGray
//        cell.actionName.textColor = UIColor.white
//        self.selectedIndices.remove(IndexPath(row: indexPath.row, section: indexLoc.section))
//        self.updateSharedIndicesCount()
//        
//        if ((self.selectedIndices.count < 1) && self.sharing == true) {
//            self.sharing = false
//        }
//        
//        if let count = self.actionHeaders?.count {
//            for i in 0..<count {
//                if let cell = self.actionTableView.cellForRow(at: IndexPath(row: 0, section: i)) as? ActionTableViewCell {
//                    cell.actionCollectionView.reloadData()
//                }
//            }
//        }
//            }
    }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("I AM SINGLE")
        if Manager.userData!["id"] as? String == self.patient?["observer_id"] as? String || self.patient?["observer_id"] as? String == nil {
            if (self.pickerTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                self.displayAlertMessage(message: "Please choose location first")
                return
            }
        if (self.sharing == false) {
            self.sharing = true
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCIdentifier, for: indexPath) as! ActionCollectionViewCell
        
        guard let indexLoc = collectionView.layer.value(forKey: "indexLoc") as? IndexPath else { return }
        print("indexLoc:\(indexLoc)")
        
        if (indexLoc.section == 2 && (indexPath.row == 0 || indexPath.row == 4)) {
                return
        }
            
        if (self.selectedIndices.contains(IndexPath(row: indexPath.row, section: indexLoc.section))) {
            self.collectionView(collectionView, didDeselectItemAt: indexPath)
            return
        }

            //if (self.multiSelect.title(for: .normal) == self.multiOn) {
        if let parameter = self.actionParameterList[indexLoc.section][indexPath.row] {
            let timeClicked: String = self.getTimestamp()
            /*if (self.multiSelect.title(for: .normal) == self.multiOff) {
                timeClicked = self.actionTimeStamp != nil ? self.actionTimeStamp! : self.getTimestamp()
            } else {
                timeClicked = self.getTimestamp()
            }*/
        //self.displayConfirmation(message: "Click 'Ok' to capture event", selectedParameters: [parameter], type: "start event", selectionType: "single", cell: cell, indexPath: IndexPath(row: indexPath.row, section: indexLoc.section), recordedTime: timeClicked)
            self.displayActions(selectedParameters: [parameter], type: "start event", selectionType: "single", cell: cell, indexPath: IndexPath(row: indexPath.row, section: indexLoc.section), recordedTime: timeClicked)
        
        }
                
                
            /*print("HEHEEEEEEEEEEEEEEEEeeeeeeeeeeee")
            if (isSuccess != nil && isSuccess == true) {
                print("HEHEEEEEEEEEEEEEEEEeeeeeeeeeeee inside")
        self.selectedIndices.insert(IndexPath(row: indexPath.row, section: indexLoc.section))
        self.updateSharedIndicesCount()
        cell.actionView!.backgroundColor = UIColor.green
        self.reloadActionCells()
            }*/
           /* } else {
                self.configSelectedCell(isSuccess: true, cell: cell, indexPath: IndexPath(row: indexPath.row, section: indexLoc.section))
            }*/
        } else {
            self.displayAlertMessage(message: "you cannot modify other observer's record. Allow \(self.patient?["observer_id"] as? String) to submit the action(s)")
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
        if (sec == 2 && (indexPath.row == 0 || indexPath.row == 4)) {
            cell.actionView!.backgroundColor = UIColor.lightGray
            cell.actionName.textColor = UIColor.black
        } else {
        /*if (self.multiSelectedIndices.contains(IndexPath(row: indexPath.row, section: sec))) {
            cell.actionView.backgroundColor = UIColor.orange
            cell.actionName.textColor = UIColor.black
        } else */if (self.selectedIndices.contains(IndexPath(row: indexPath.row, section: sec))) {
            cell.actionView.backgroundColor = UIColor.green
            cell.actionName.textColor = UIColor.black
        } else {
            cell.actionView!.backgroundColor = UIColor.darkGray
            cell.actionName.textColor = UIColor.white
        }
        
        let collectionViewCellTap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.onCellDoubledTapped(_:)))
        collectionViewCellTap.numberOfTapsRequired = 2
        collectionViewCellTap.delaysTouchesBegan = true
        cell.addGestureRecognizer(collectionViewCellTap)
        }
        
        return cell
    }
    
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (actionHeaders != nil) {
            if let heading = actionHeaders?[section] {
                if (section == 2) {
                    return "Verbal"
                } else {
                return heading
                }
            }
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if actionHeaders != nil {
            if let count = actionHeaders?.count {
                return count - 1
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
        return (widthPerItem*self.cellHeightBooster)+30
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

