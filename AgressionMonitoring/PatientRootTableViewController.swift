//
//  PatientTableViewController.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/6/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire
//import UserNotifications

protocol PatientRootSelectionDelegate: class {
    func patientSelected(patientDetails: [String:Any], locationList: [String])
}

class PatientRootTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate/*, UNUserNotificationCenterDelegate*/,NSURLConnectionDelegate {

    @IBOutlet var tableView: UITableView!
    let cellSpacingHeight: CGFloat = 15
    weak var patientDelegate: PatientRootSelectionDelegate?
    var selectedPatient: [String:Any]?
    var locationList: [String] = []
    //@IBOutlet weak var hamburger: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        /*if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden
        }*/
        
        
        //splitViewController?.preferredPrimaryColumnWidthFraction = 0.30
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
//        let userid = Int(Manager.userData!["id"] as! String)
//        let role = Manager.userData!["role"] as! String
//        if (Manager.reloadAllCells == true) {
//            // Do any additional setup after loading the view, typically from a nib.
//            let parameters: Parameters = ["userid": userid as Any, "role": role]
//            Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getPatientDetails.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
//                
//                if let data = response.data {
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
//                        Manager.patientDetails = json["patient_details"] as? [Dictionary<String,Any>]
//                        DispatchQueue.main.async(execute: {
//                            self.tableView.reloadData()
//                        })
//                        
//                    }
//                    catch{
//                        //print("error serializing JSON: \(error)")
//                    }
//                }
//            }
//        }
        /*else {
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })

        }*/
        
        tableView.backgroundColor = UIColor.gray
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 70
        
        /*if (revealViewController() != nil) {
            hamburger.target = revealViewController()
            hamburger.action = #selector(SWRevealViewController.revealToggle(_:))
            //revealViewController().rearViewRevealWidth = 275
            //revealViewController().rightViewRevealWidth  =
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 8, bottom: 30, right: 8)
    }*/
    
    @IBAction func refresh(_ sender: Any) {
        //viewDidLoad()
        let userid = Int(Manager.userData!["id"] as! String)
        let role = Manager.userData!["role"] as! String
        if (Manager.reloadAllCells == true) {
            // Do any additional setup after loading the view, typically from a nib.
            let parameters: Parameters = ["userid": userid as Any, "role": role]
            Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getPatientDetails.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        Manager.patientDetails = json["patient_details"] as? [Dictionary<String,Any>]
                        self.locationList = json["locations"] as! [String]
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                        
                    }
                    catch{
                        //print("error serializing JSON: \(error)")
                    }
                }
            }
        }
        
    }
    
    
    func reloadIndexPath(patient: [String: Any]) {
        //Add location type too
        print("sections\(self.tableView.numberOfSections)")
        
        if (Manager.patientDetails != nil) {
            for i in 0..<Manager.patientDetails!.count {
                print("rows:\(self.tableView.numberOfRows(inSection: i))")
                print("patient id:\(patient["id"])")
                if Manager.patientDetails?[i]["id"] as? String == patient["id"] as? String {
                    if (patient["type"] as? String == "voice") {
                        Manager.patientDetails?[i]["voice_status"] = patient["voice_status"]
                    } else if (patient["type"] as? String == "hands") {
                        Manager.patientDetails?[i]["limb_status"] = patient["limb_status"]
                    } else if (patient["type"] as? String == "location") {
                        Manager.patientDetails?[i]["location"] = patient["location"]
                    } else if (patient["type"] as? String == "voice and hands") {
                        Manager.patientDetails?[i]["voice_status"] = patient["voice_status"]
                        Manager.patientDetails?[i]["limb_status"] = patient["limb_status"]
                    }
                    let indexPath: IndexPath = IndexPath(row: 0, section: i)
                    var indexPaths = [IndexPath]()
                    indexPaths.append(indexPath)
                    //print(indexPaths)
                    //print(self.tableView)
                    /*if let visibleIndexPaths = tableView.indexPathsForVisibleRows?.index(of: indexPath as IndexPath) {
                        if visibleIndexPaths != NSNotFound {
                            self.tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
                        }
                    }*/
                    let sectionIndex = IndexSet(integer: i)
                    self.tableView.reloadSections(sectionIndex, with: .automatic)
                    break
                }
            }
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(Manager.patientDetails == nil) {
            return 0
        }
        return Manager.patientDetails!.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }

    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
    //}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientRootTableViewCell", for: indexPath) as! PatientRootTableViewCell
        //print(Manager.patientDetails)
        if(Manager.patientDetails != nil) {
            print("index:\(indexPath)")
            print("section indx:\(indexPath.section)")
            
            print("id:\(Manager.patientDetails?[indexPath.section]["id"])")
            cell.patientName.text = Manager.patientDetails?[indexPath.section]["name"] as? String
            print(cell.patientName.text)
            cell.location.text = Manager.patientDetails?[indexPath.section]["location"] as? String
            let limb_status = Manager.patientDetails?[indexPath.section]["limb_status"] as? String
            let voice_status = Manager.patientDetails?[indexPath.section]["voice_status"] as? String
            //let view = UIView(frame: cell.bounds)
            // Set background color that you want
            //view.backgroundColor = UIColor(colorLiteralRed: 0, green: 0.8, blue: 0, alpha: 1.00)
            //cell.selectedBackgroundView = view
            //self.collectionView.reloadItems(at: [indexPath])
            //cell.causeTime.isHidden = false
            if(limb_status == "stable" && voice_status == "stable") {
                //cell.status.text = "stable"
                //cell.causeTime.isHidden = true
                //cell.status.text = "stable"
                cell.patientStatus(status: PatientRootTableViewCell.Status.stable)
                Manager.patientDetails?[indexPath.section]["status_color"] = UIColor.green
            } else if (limb_status == "agitated" && voice_status == "agitated") {
                //cell.status.text = "aggressive"
                //let name = Manager.patientDetails?[indexPath.row]["status_timestamp"] as? String
                //let endIndex = name?.index((name?.endIndex)!, offsetBy: -4)
                //let truncated = name?.substring(to: endIndex!)
                //cell.causeTime.text = truncated
                //cell.status.text = "hands & voice"
                cell.patientStatus(status: PatientRootTableViewCell.Status.aggressive)
                Manager.patientDetails?[indexPath.section]["status_color"] = UIColor.red
            } else if (limb_status == "agitated" || voice_status == "agitated") {
                //cell.status.text = "slightly aggressive"
                if limb_status == "agitated" {
                    /*let name = Manager.patientDetails?[indexPath.row]["status_timestamp"] as? String
                    let endIndex = name?.index((name?.endIndex)!, offsetBy: -4)
                    let truncated = name?.substring(to: endIndex!)
                    cell.causeTime.text = truncated*/
                    //cell.status.text = "hands"
                    
                } else if voice_status == "agitated" {
                    //cell.status.text = "voice"
                    /*let name = Manager.patientDetails?[indexPath.row]["voicestatus_timestamp"] as? String
                    let endIndex = name?.index((name?.endIndex)!, offsetBy: -9)
                    let truncated = name?.substring(to: endIndex!)
                    cell.causeTime.text = truncated*/
                    
                }
                cell.patientStatus(status:  PatientRootTableViewCell.Status.partiallyaggressive)
                Manager.patientDetails?[indexPath.section]["status_color"] = UIColor.yellow
            } else {
                //cell.status.text = "unknown"
                cell.patientStatus(status:  PatientRootTableViewCell.Status.unknown)
                Manager.patientDetails?[indexPath.section]["status_color"] = UIColor.gray
            }
            
            if (indexPath.section == 0) {
                self.selectedPatient = Manager.patientDetails?[0]
                //performSegue(withIdentifier: "DetailView", sender: self)
            } else if (indexPath.section == Manager.patientDetails!.count - 1) {
                //performSegue(withIdentifier: "DetailView", sender: self)
            }
            
            
            //cell.age.text = self.patientDetails?[indexPath.row]["age"] as? String
            // cell.gender.text = self.patientDetails?[indexPath.row]["gender"] as? String
            // cell.wid.text = self.patientDetails?[indexPath.row]["watch_name"] as? String
            //cell.wname.text = self.patientDetails?[indexPath.row]["device_name"] as? String
            //cell.location.text = self.patientDetails?[indexPath.row]["location"] as? String
            //cell.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 8)
            cell.layer.cornerRadius = 5.0
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = UIColor.black.cgColor
            //cell.backgroundColor = UIColor.gray
            cell.clipsToBounds = true
            
            /*cell.contentView.backgroundColor = UIColor.clear
            let whiteRoundedView : UIView = UIView(frame: CGRect(0, 10, self.view.frame.size.width, 70))
            whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.layer.cornerRadius = 3.0
            whiteRoundedView.layer.shadowOffset = CGRect(origin: -1, size: 1)
            whiteRoundedView.layer.shadowOpacity = 0.5
            cell.contentView.addSubview(whiteRoundedView)
            cell.contentView.sendSubview(toBack: whiteRoundedView)
             */
        }
        
        return cell
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "PatientRootTableViewCell", for: indexPath) as! PatientRootTableViewCell
        //cell.layer.borderColor = UIColor.blue.cgColor
        //tableView.cellForRow(at: indexPath)?.textLabel?.textColor = UIColor.white
        //tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.blue
        // note that indexPath.section is used rather than indexPath.row
        //print("You tapped cell number \(indexPath.section).")
        let userid = Int(Manager.userData!["id"] as! String)
        self.selectedPatient = Manager.patientDetails?[indexPath.section]
        //self.delegatePatient?.patientSelected(patientDetails: selectedPatient!)
        //print("at select cell \(selectedPatient)")
        //if let detailViewController = self.delegatePatient as? DetailViewController {
          //  splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        //}
        if (selectedPatient != nil && userid != nil) {
        //performSegue(withIdentifier: "DetailView", sender: self)
        let parameters: Parameters = ["patient_id": self.selectedPatient!["id"]!, "observer_id": userid!]
        print("PARA on click:\(parameters)")
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getObservationstate.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
            DispatchQueue.main.async(execute: {
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                    let prevState = json["pastdetails"] as? [Dictionary<String,Any>]
                    print("prev State: \(prevState)")
                    if (prevState != nil) {
                    self.selectedPatient?["action"] = prevState?[0]["action"] as? String
                    self.selectedPatient?["comments"] = prevState?[0]["comments"] as? String
                    self.selectedPatient?["observer_id"] = prevState?[0]["observer_id"] as? String
                    var temp = prevState?[0]["parameters"] as? String
                    print("id without manipulation :\(temp)")
                    //var charRemSet = NSCharacterSet(charactersIn: "[")
                    temp = temp?.trimmingCharacters(in: ["[","]"])
                    let strToArray: [String] = (temp?.components(separatedBy: ","))!
                    self.selectedPatient?["parameters"] = strToArray
                    print("ID we got back :\(self.selectedPatient?["parameters"])")
                    //self.selectedPatient?["parameters"] = [5,10,14]
                    print("selected patient:\(self.selectedPatient)")
                    //DispatchQueue.main.async(execute: {
                        self.patientDelegate?.patientSelected(patientDetails: self.selectedPatient!, locationList: self.locationList)
                        self.dismiss(animated: true, completion: nil)
                    //})
                    } else {
                        self.patientDelegate?.patientSelected(patientDetails: self.selectedPatient!, locationList: self.locationList)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                catch{
                    //print("error serializing JSON: \(error)")
                    self.patientDelegate?.patientSelected(patientDetails: self.selectedPatient!, locationList: self.locationList)
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
            })
        }
    }
    }

    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DetailView") {
            // initialize new view controller and cast it as your view controller
            let navViewController = segue.destination as? UINavigationController
            // your new view controller should have property that will store passed value
            let dVC = navViewController?.viewControllers.first as! DetailViewController
            dVC.patient = self.selectedPatient
            dVC.locationSet = dVC.locationSet.union(self.locationSet)
            
        }
    }*/

    @IBAction func dismissPatientRootView(_ sender: Any) {
        self.patientDelegate?.patientSelected(patientDetails: [:], locationList: self.locationList)
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension PatientRootTableViewController: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        //if orientation.isLandscape {
            print("IS THIS CALLED?")
            return true
        //}
    }
}
