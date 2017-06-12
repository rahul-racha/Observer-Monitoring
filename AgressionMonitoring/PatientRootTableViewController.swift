//
//  PatientTableViewController.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/6/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

protocol PatientRootSelectionDelegate: class {
    func patientSelected(patientDetails: [String:Any])
}

class PatientRootTableViewController: UITableViewController, NSURLConnectionDelegate {

    //@IBOutlet var tableView: UITableView!
    let cellSpacingHeight: CGFloat = 15
    weak var delegatePatient: PatientRootSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        if (Manager.reloadAllCells == true) {
            // Do any additional setup after loading the view, typically from a nib.
            let parameters: Parameters = ["userid":1]
            Alamofire.request("http://qav2.cs.odu.edu/AggressionDetection/getPatientDetails.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        Manager.patientDetails = json["patient_details"] as? [Dictionary<String,Any>]
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
        
        tableView.backgroundColor = UIColor.gray
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 70
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
        viewDidLoad()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(Manager.patientDetails == nil) {
            return 0
        }
        return Manager.patientDetails!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }

    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientRootTableViewCell", for: indexPath) as! PatientRootTableViewCell
  
        if(Manager.patientDetails != nil) {
            
            cell.patientName.text = Manager.patientDetails?[indexPath.section]["name"] as? String
            let status = Manager.patientDetails?[indexPath.section]["status"] as? String
            let voice_status = Manager.patientDetails?[indexPath.section]["voice_status"] as? String
            //let view = UIView(frame: cell.bounds)
            // Set background color that you want
            //view.backgroundColor = UIColor(colorLiteralRed: 0, green: 0.8, blue: 0, alpha: 1.00)
            //cell.selectedBackgroundView = view
            //self.collectionView.reloadItems(at: [indexPath])
            //cell.causeTime.isHidden = false
            if(status == "stable" && voice_status == "stable") {
                //cell.status.text = "stable"
                //cell.causeTime.isHidden = true
                cell.status.text = "stable"
                cell.patientStatus(status: PatientRootTableViewCell.Status.stable)
            } else if (status == "aggressive" && voice_status == "aggression") {
                //cell.status.text = "aggressive"
                //let name = Manager.patientDetails?[indexPath.row]["status_timestamp"] as? String
                //let endIndex = name?.index((name?.endIndex)!, offsetBy: -4)
                //let truncated = name?.substring(to: endIndex!)
                //cell.causeTime.text = truncated
                cell.status.text = "hands & voice"
                cell.patientStatus(status: PatientRootTableViewCell.Status.aggressive)
            } else if (status == "aggressive" || voice_status == "aggression") {
                //cell.status.text = "slightly aggressive"
                if status == "aggressive" {
                    /*let name = Manager.patientDetails?[indexPath.row]["status_timestamp"] as? String
                    let endIndex = name?.index((name?.endIndex)!, offsetBy: -4)
                    let truncated = name?.substring(to: endIndex!)
                    cell.causeTime.text = truncated*/
                    cell.status.text = "hands"
                    
                } else if voice_status == "aggression" {
                    cell.status.text = "voice"
                    /*let name = Manager.patientDetails?[indexPath.row]["voicestatus_timestamp"] as? String
                    let endIndex = name?.index((name?.endIndex)!, offsetBy: -9)
                    let truncated = name?.substring(to: endIndex!)
                    cell.causeTime.text = truncated*/
                    
                } else {
                    cell.status.text = "unknown"
                    cell.patientStatus(status:  PatientRootTableViewCell.Status.unknown)
                }
                cell.patientStatus(status:  PatientRootTableViewCell.Status.partiallyaggressive)
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // note that indexPath.section is used rather than indexPath.row
        //print("You tapped cell number \(indexPath.section).")
        let selectedPatient = Manager.patientDetails?[indexPath.section]
        self.delegatePatient?.patientSelected(patientDetails: selectedPatient!)
        
        if let detailViewController = self.delegatePatient as? DetailViewController {
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }
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
