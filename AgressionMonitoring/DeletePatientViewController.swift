//
//  DeletePatientViewController.swift
//  AggressionMonitoring
//
//  Created by admin on 8/10/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class DeletePatientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate {

    @IBOutlet var tableView: UITableView!
    //@IBOutlet weak var hamburger: UIBarButtonItem!
    
    let cellSpacingHeight: CGFloat = 15
    var selectedPatient: [String:Any]?
    var patientList = [IndexPath: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let userid = Int(Manager.userData!["id"] as! String)
        let role = Manager.userData!["role"] as! String
        //if (Manager.reloadAllCells == true) {
            // Do any additional setup after loading the view, typically from a nib.
            let parameters: Parameters = ["userid": userid as Any, "role": role]
            Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getPatientDetails.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        Manager.patientDetails = json["patient_details"] as? [Dictionary<String,Any>]
                        //self.locationList = json["locations"] as! [String]
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                            if (Manager.userData!["role"] as! String != "admin") {
                                self.displayAlertMessage(message: "Contact admin")
                            }
                        })
                        
                    }
                    catch{
                        //print("error serializing JSON: \(error)")
                    }
                }
            }
        //}

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(message: String) {
        
        let confirmationAlert = UIAlertController(title: "Permission denied", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        
        present(confirmationAlert, animated: true, completion: nil)
        
    }
    
    
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deletePatientCell", for: indexPath) as! DeletePatientTableViewCell
        //print(Manager.patientDetails)
        if(Manager.patientDetails != nil) {
            print("index:\(indexPath)")
            print("section indx:\(indexPath.section)")
            
            print("id:\(Manager.patientDetails?[indexPath.section]["id"])")
            cell.name.text = Manager.patientDetails?[indexPath.section]["name"] as? String

            cell.layer.cornerRadius = 5.0
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = UIColor.black.cgColor
            cell.deleteView.backgroundColor = UIColor.orange
            cell.clipsToBounds = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            if (!self.patientList.isEmpty) {
                let x = self.patientList.removeValue(forKey: indexPath)
                print(x)
            }
           
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            //if (self.patientList != nil) {
                self.patientList[indexPath] = Manager.patientDetails?[indexPath.section]["id"] as? String
            print(self.patientList[indexPath])
            //}
        }
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    
    @IBAction func dismissDeletePatient(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deletePatients(_ sender: Any) {
        
        if (self.patientList.isEmpty) {
            self.displayAlertMessage(message: "Select a patient to delete")
            return
        }
        var isResponseSuccess: Bool?
        let patientIds = [String](self.patientList.values)
        print(patientIds)
        
        let parameters: Parameters = ["patientIds": patientIds, "observer_id": Manager.userData!["id"] as! String]
        print("para:\(parameters)")
        
        
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/deletePatients.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
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

            })
        }
        
    }
    

}
