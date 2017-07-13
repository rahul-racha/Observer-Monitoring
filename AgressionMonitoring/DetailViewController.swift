//
//  ViewController.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/5/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

extension DetailViewController: /*APLExpandableSectionFlowLayout*/UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = sectionInsets.left * CGFloat(itemsPerRow+1)
        let availableWidth = view.frame.width - padding
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
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
        
        print("no of items indexLoc :\(indexLoc)")
        let sec = indexLoc.section
        if (!(self.actionList?[sec].isEmpty)!) {
            print("####no of cells per row:\(actionList![sec].count)####")
            return actionList![sec].count
        }
        return 0
        
    }
    
    /*func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = actionCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "actionHeader", for: indexPath) as! ActionCollectionReusableView
            headerView.sectionName.text = self.actionHeaders[indexPath.section]
            headerView.expandSupport.layer.setValue(indexPath.section, forKey: "sectionId")
            headerView.expandSupport.isHidden = true
             let headerTap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.headerTapped(_:)))
             headerTap.numberOfTapsRequired = 1
             headerView.addGestureRecognizer(headerTap)
            
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }*/
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        /*guard sharing else {
            return
        }*/
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCIdentifier, for: indexPath) as! ActionCollectionViewCell
        guard let indexLoc = collectionView.layer.value(forKey: "indexLoc") as? IndexPath else { return }
        print("indexLoc at removal:\(indexLoc.section),\(indexPath.row)")
        cell.actionView!.backgroundColor = UIColor.purple
        //if (!self.selectedIndices.contains(IndexPath(row: indexPath.row, section: indexLoc.section))) {
        self.selectedIndices.remove(IndexPath(row: indexPath.row, section: indexLoc.section))
        self.updateSharedIndicesCount()
        //cell.applyViewStatusColor(status: .DESELECTED)
        //cell.selectedBackgroundView = UIView(frame: cell.bounds)
        
        print("after removed indices:\(self.selectedIndices)")
        //}
        if ((self.selectedIndices.count < 1) && self.sharing == true) {
            self.sharing = false
        }
        //collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: indexLoc.section)])
        if let count = self.actionHeaders?.count {
        for i in 0..<count {
            if let cell = self.actionTableView.cellForRow(at: IndexPath(row: 0, section: i)) as? ActionTableViewCell {
                cell.actionCollectionView.reloadData()
            }
        }
    }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (self.sharing == false) {
            self.sharing = true
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCIdentifier, for: indexPath) as! ActionCollectionViewCell
        /*guard self.sharing else {
            return
        }*/
        
        guard let indexLoc = collectionView.layer.value(forKey: "indexLoc") as? IndexPath else { return }
        print("indexLoc:\(indexLoc)")
        cell.actionView!.backgroundColor = UIColor.green
        if (self.selectedIndices.contains(IndexPath(row: indexPath.row, section: indexLoc.section))) {
            self.collectionView(collectionView, didDeselectItemAt: indexPath)
            return
        }
        
        self.selectedIndices.insert(IndexPath(row: indexPath.row, section: indexLoc.section))
        self.updateSharedIndicesCount()
        //cell.applyViewStatusColor(status: .SELECTED)
        //cell.selectedBackgroundView = UIView(frame: cell.bounds)
        //collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: indexLoc.section)])
        self.reloadActionCells()
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool{
        /*guard self.sharing else {
            return true
        }*/
        return true
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseCIdentifier, for: indexPath) as! ActionCollectionViewCell
        guard let indexLoc = collectionView.layer.value(forKey: "indexLoc") as? IndexPath else { return cell }
        print("indexLoc:\(indexLoc)")
        let sec = indexLoc.section
        cell.actionName.text = self.actionList?[sec][indexPath.row]
        cell.actionName.numberOfLines = 0
        //print("********label:\(self.actionList?[sec][indexPath.row])********")
        //cell.applyViewStatusColor(status: .DESELECTED)
        //cell.selectedBackgroundView = UIView(frame: cell.bounds)
        if (self.selectedIndices.contains(IndexPath(row: indexPath.row, section: sec))) {
            cell.actionView.backgroundColor/*selectedBackgroundView!.backgroundColor*/ = UIColor.green
        } else {
            cell.actionView!.backgroundColor = UIColor.purple
        }
        return cell
        
    }

    /*func headerTapped(_ gestureRecognizer: UIGestureRecognizer) {
        //if (self.actionDictionary["id"])
        self.itemsPerRow = 0
        let indexPath = IndexPath(row: 0, section: 0)
        self.actionCollectionView.reloadItems(at: [indexPath])
    }*/
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
        if self.actionList != nil {
            //if self.actionList![section].count < 5 {
                return 1
            //} else {
            //    return 2
            //}
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = actionTableView.dequeueReusableCell(withIdentifier: self.reuseTIdentifier, for: indexPath) as! ActionTableViewCell
        cell.frame = tableView.bounds
        cell.layoutIfNeeded()
        cell.actionCollectionView.reloadData()
        if let layout = cell.actionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        cell.collectionViewHeight.constant = 200//cell.actionCollectionView.collectionViewLayout.collectionViewContentSize.height
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

class DetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,  UITextViewDelegate/*,PatientRootSelectionDelegate*/ {
    
    @IBOutlet weak var actionTableView: UITableView!
    fileprivate let reuseTIdentifier = "actionTableCell"
    fileprivate let reuseCIdentifier = "actionCollectionCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
    fileprivate var itemsPerRow = 5
    @IBOutlet weak var commentTextView: UITextView!
    var actionTimeStamp: String?
    var observerParameters: Dictionary<String,Any>?
    /*
    var section1: String? // = ["A","B","C","D","E","F","G","H","I","J","K"]
    var section2: String? // = ["A1","B1","C1","D1","E1"]
    var section3: String? //= ["A2","B2","C2","D2","E2","F2","G2","H2","I2","J2","K2"]
    var section4: String? //= ["G3","H3","I3","J3","K3"]
    */
    fileprivate var actionList: [[String]]?
    fileprivate var storedOffsets: [[CGFloat?]] = Array(repeating: Array(repeating:0, count:3), count: 4)
    
    //fileprivate var actionDictionary: [Int:String]?
    
    
    fileprivate var actionHeaders: [String]? /*= ["Physical-Aggressive", "Physical-NonAggressive", "Verbal-Aggressive", "Verbal-NonAggressive"]*/
    
    fileprivate var selectedIndices = Set<IndexPath>()
    @IBOutlet weak var seclectedCount: UILabel!
    @IBOutlet weak var sendActionButton: UIButtonX!
    
    @IBOutlet weak var stackHeader: UIView!
    
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
    
    
    var patient: [String:Any]?
    var holdLimbTap: Bool?
    var holdVoiceTap: Bool?
    var holdPulseTap: Bool?
    
    //var pc: PatientRootTableViewController!
    //let pc = PatientRootTableViewController()
    

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var stableButton: UIButton!
    @IBOutlet weak var statisticButton: UIButton!
    
    @IBOutlet weak var pickerTextField: UITextField!
    
    var locationSet: Set<String> = ["Room 1", "Room 2", "Room 3", "Room 4", "Room 5"]
    var pickOption = [String]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //let pc = PatientRootTableViewController()
        //pc.delegatePatient = self
        //self.commentTextView.
        self.commentTextView.delegate = self
        if !(self.commentTextView?.text.isEmpty)!  {
            self.commentTextView.textColor = UIColor.black
        } else {
            self.commentTextView.text = "write your observations"
            self.commentTextView.textColor = UIColor.lightGray
        }

      /*
        actionDictionary = [
            ["id":0, "values":section1, "areCellsShown":true ],
            ["id":1, "values":section2, "areCellsShown":true],
            ["id":2, "values":section3, "areCellsShown":true],
            ["id":3, "values":section4, "areCellsShown":true],
        ]
*/
        
        self.sendActionButton.isHidden = true
        self.seclectedCount.isHidden = true
        
        self.statisticButton.layer.cornerRadius = self.statisticButton.frame.size.width/14
        self.stableButton.layer.cornerRadius = self.stableButton.frame.size.width/14
        self.stableButton.isHidden = false
        
        self.configurePic()
        self.configureView()
        self.configureDetails()

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.imageTapped(_:)))
        imageTap.numberOfTapsRequired = 1
        self.picture.addGestureRecognizer(imageTap)

        /*
        let doubleTapVoice = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.voiceSliderTapped(_:)))
        doubleTapVoice.numberOfTapsRequired = 2
        self.voiceSlider.addGestureRecognizer(doubleTapVoice)
         */
        
        
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        splitViewController?.preferredPrimaryColumnWidthFraction = 0.31
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
        
        let parameters: Parameters = [:]
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getActionParameters.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
            
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                    self.actionHeaders = json["sections"] as? [String]
                    if let actionDict = json["actions"]  as? Dictionary<String,Any> {
                        if 4 == actionDict.count {
                    let section1 = actionDict[(self.actionHeaders?[0])!] as? [String]
                    let section2 = actionDict[(self.actionHeaders?[1])!] as? [String]
                    let section3 = actionDict[(self.actionHeaders?[2])!] as? [String]
                    let section4 = actionDict[(self.actionHeaders?[3])!] as? [String]
                    self.actionList = [section1!,section2!,section3!,section4!]
                    //self.constructActionDict(sectionCount: actionDict.count)
                    DispatchQueue.main.async(execute: {
                        self.actionTableView.reloadData()
                    })
                    }
                    }
                }
                catch{
                    print("error serializing JSON: \(error)")
                }
            }
        }

        //self.stackHeader.backgroundColor = UIColor.
        actionTableView.rowHeight = UITableViewAutomaticDimension
        actionTableView.estimatedRowHeight = 240
        
        pickOption.append(contentsOf: self.locationSet.sorted())
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
    
    func getTimestamp() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let _ = date.timeIntervalSince1970
        return dateString
    }
    
    func updateSharedIndicesCount() {
        self.seclectedCount.textColor = UIColor.purple
        self.seclectedCount.text = "\(self.selectedIndices.count) actions selected"
        self.seclectedCount.sizeToFit()
        print("selected indices:\(self.selectedIndices)")
        if self.selectedIndices.count > 0 {
            self.seclectedCount.isHidden = false
            self.sendActionButton.isHidden = false
        } else {
            self.seclectedCount.isHidden = true
            self.sendActionButton.isHidden = true
        }
    }
    
    func prepareToSendData() {
        var selectedParameters = [String]()
        //if let selList = self.selectedIndices? {
        for idx in self.selectedIndices {
            //print("action dict:\(self.actionDictionary)")
            //let key = (idx.section*10)+(idx.row)
            //if let _ = self.actionDictionary?.index(forKey: key) {
            //    selectedParameters.append((self.actionDictionary?[key])!)
            //}
            selectedParameters.append((self.actionList?[idx.section][idx.row])!)
        }
        //}
        self.sendObservation(selectedParameters: selectedParameters)
    }
    
    @IBAction func share(_ sender: Any) {
        guard !self.selectedIndices.isEmpty else {
            self.sharing = !self.sharing
            return
        }
        
        guard sharing else { return }
        self.prepareToSendData()
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
    
    @IBAction func sendStableStatus(_ sender: Any) {
        self.sharing = false
        self.reloadActionCells()
        self.sendObservation(selectedParameters: ["stable"])
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
    func configurePic() {
        self.picture.image = #imageLiteral(resourceName: "labimg")
        self.picture.layer.cornerRadius = self.detailsView.frame.size.width / 10//self.picture.frame.size.width/10
        self.picture.clipsToBounds = true
        self.picture.layer.borderColor = UIColor.gray.cgColor
        self.picture.layer.borderWidth = 1
    }
    
    func configureView() {
        self.detailsView.layer.cornerRadius = self.detailsView.frame.size.width / 10
        self.detailsView.clipsToBounds = true
        self.detailsView.layer.borderWidth = 3.0
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
    
    
    
    func sendObservation(selectedParameters: [String]) {
        
        var actionString = "["
        for param in selectedParameters {
            actionString = actionString+param+","
        }
        actionString = actionString+"]"
        
        var cmt: String? = nil
        if (self.commentTextView.text != "write your observations") {
            cmt = self.commentTextView.text!
        }
        
        let parameters: Parameters = ["patient_id": patient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "start_time": self.actionTimeStamp!, "comment": (cmt != nil) ? cmt! : cmt, "parameters": actionString]
        print("para:\(parameters)")
        
        
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObservedParameters.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
            DispatchQueue.main.async(execute: {
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"successs") != nil{
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

    
    
    
   /*
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
 
    
    func getAngerStatus() {
        pulseSlider.value = roundf(pulseSlider.value)
        if (pulseSlider.value == 0) {
            pulseSlider.thumbTintColor = UIColor.green
            pulseSlider.minimumTrackTintColor = UIColor.green
            self.angerStatus = "stable"
        } else if (pulseSlider.value == 1) {
            pulseSlider.thumbTintColor = UIColor.yellow
            pulseSlider.minimumTrackTintColor = UIColor.yellow
            self.angerStatus = "slightly agitated"
        } else if (pulseSlider.value == 2) {
            pulseSlider.thumbTintColor = UIColor.red
            pulseSlider.minimumTrackTintColor = UIColor.red
            self.angerStatus = "agitated"
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
            self.stableButton.isHidden = false
            self.countdown.isHidden = true
            self.timerText.isHidden = true
            self.cancel.isHidden = true
            self.send.isHidden = true
            self.seconds = self.timeConst
            self.sendObservation(timestamp: self.sliderTimeStamp!, isStableClick: "false")
            self.resetFlags()
        }
    }

    @IBAction func sendRightAway(_ sender: Any) {
        //self.allowSend = true
        self.timer.invalidate()
        self.stableButton.isHidden = false
        self.countdown.isHidden = true
        self.timerText.isHidden = true
        self.cancel.isHidden = true
        self.send.isHidden = true
        self.seconds = self.timeConst
        if (self.sliderTimeStamp != nil) {
            self.sendObservation(timestamp: self.sliderTimeStamp!, isStableClick: "false")
        }
        self.resetFlags()
    }
    
    
    @IBAction func cancelSubmit(_ sender: Any) {
        //self.allowCancel = true
        self.timer.invalidate()
        self.stableButton.isHidden = false
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
            self.stableButton.isHidden = true
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
    */
 /*
    func sendObservation(timestamp: String, isStableClick: String) -> Bool {
        //print("Checking if run on cancel")
        var result: Bool = true
        var cause: String = "unknown"
        if ((self.voiceStatus != "stable" && self.voiceStatus != "unknown") && (self.limbStatus != "stable" && self.limbStatus != "unknown")) {
            cause = "hands & voice"
        } else if (self.voiceStatus == "slightly aggressive" || self.voiceStatus == "aggressive") {
            cause = "voice"
        } else if (self.limbStatus == "slightly aggressive" || self.limbStatus == "aggressive") {
            cause = "hands"
        } else if (self.voiceStatus == "stable" && self.limbStatus == "stable") {
            cause = "stable"
        } else {
            //
        }
        
        print("voice:\(self.voiceStatus)")
        print("hands:\(self.limbStatus)")
        print("anger:\(self.angerStatus)")
        print(isStableClick)
        let parameters: Parameters = ["patient_id": patient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "start_time": timestamp, "status":self.angerStatus ?? "unknown", "cause":cause, "stable_click": isStableClick]
        print("here para: \(parameters)")
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObserverData.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
            DispatchQueue.main.async(execute: {
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"success") != nil{
                        self.displayAlertMessage(message: "Submitted :)")
                    } else {
                        // Perform ACTION
                        self.displayAlertMessage(message: "Something went wrong :(")
                        result = false
                    }
                    
                } else {
                    self.displayAlertMessage(message: "Server response is empty")
                    result = false
                }
                
            })
        }
        print("pat: \(patient!["id"] as! String)")
        print("obs: \(Manager.userData!["id"] as! String)")
        let parameters2: Parameters = ["patient_id": patient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "start_time": timestamp, "location": self.pickerTextField.text!, "stable_click": isStableClick]
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObservedLocation.php",method: .post,parameters: parameters2, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/string"])*/.responseData { response in
            DispatchQueue.main.async(execute: {
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"success") != nil{
                        self.displayAlertMessage(message: "Submitted :)")
                    } else {
                        // Perform ACTION
                        self.displayAlertMessage(message: "Location not updated :(")
                        result = false
                    }
                    
                } else {
                    self.displayAlertMessage(message: "Server response is empty")
                    result = false
                }
                
            })
        }
        return result
    }
 */
    
  /*
    @IBAction func sendStableStatus(_ sender: Any) {
        let angry = self.pulseSlider.value
        let limbs = self.limbSlider.value
        let voice = self.voiceSlider.value
        self.initSliders(p: 0, v: 0, l: 0)
        let result = self.sendObservation(timestamp: self.getTimestamp(), isStableClick: "true")
        if result == false {
            self.initSliders(p: Int(angry), v: Int(voice), l: Int(limbs))
        }
    }
    */
    
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
        if (comment == "write your observations") {
            self.commentTextView.textColor = UIColor.lightGray
        } else {
            self.commentTextView.textColor = UIColor.black
        }
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
