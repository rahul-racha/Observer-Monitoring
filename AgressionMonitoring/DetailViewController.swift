//
//  ViewController.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/5/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var limbSlider: UISlider!
    @IBOutlet weak var voiceSlider: UISlider!
    @IBOutlet weak var pulseSlider: UISlider!
    var patient: [String:Any]?
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var detailsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configurePic()
        self.configureView()
        self.configureDetails()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.detailsView.layer.borderWidth = 1.0
        self.detailsView.layer.borderColor = UIColor.white.cgColor
    }
    
    func configureDetails() {
        if (patient != nil) {
            self.age.text = patient?["age"] as? String
            self.gender.text = patient?["gender"] as? String
        }
    }

    @IBAction func updateLimbAction(_ sender: Any) {
        limbSlider.value = roundf(limbSlider.value)
        if (limbSlider.value == 0) {
            limbSlider.thumbTintColor = UIColor.green
            limbSlider.minimumTrackTintColor = UIColor.green
        } else if (limbSlider.value == 1) {
            limbSlider.thumbTintColor = UIColor.yellow
            limbSlider.minimumTrackTintColor = UIColor.yellow
        } else if (limbSlider.value == 2) {
            limbSlider.thumbTintColor = UIColor.red
            limbSlider.minimumTrackTintColor = UIColor.red
        } else {
            limbSlider.thumbTintColor = UIColor.gray
            limbSlider.minimumTrackTintColor = UIColor.lightGray
        }
    }

    @IBAction func updateVoiceAction(_ sender: Any) {
        voiceSlider.value = roundf(voiceSlider.value)
        if (voiceSlider.value == 0) {
            voiceSlider.thumbTintColor = UIColor.green
            voiceSlider.minimumTrackTintColor = UIColor.green
        } else if (voiceSlider.value == 1) {
            voiceSlider.thumbTintColor = UIColor.yellow
            voiceSlider.minimumTrackTintColor = UIColor.yellow
        } else if (voiceSlider.value == 2) {
            voiceSlider.thumbTintColor = UIColor.red
            voiceSlider.minimumTrackTintColor = UIColor.red
        } else {
            voiceSlider.thumbTintColor = UIColor.gray
            voiceSlider.minimumTrackTintColor = UIColor.lightGray
        }
        
    }
    
    
    @IBAction func updatePulseAction(_ sender: Any) {
        pulseSlider.value = roundf(pulseSlider.value)
        if (pulseSlider.value == 0) {
            pulseSlider.thumbTintColor = UIColor.green
            pulseSlider.minimumTrackTintColor = UIColor.green
        } else if (pulseSlider.value == 1) {
           pulseSlider.thumbTintColor = UIColor.yellow
            pulseSlider.minimumTrackTintColor = UIColor.yellow
        } else if (pulseSlider.value == 2) {
            pulseSlider.thumbTintColor = UIColor.red
            pulseSlider.minimumTrackTintColor = UIColor.red
        } else {
            pulseSlider.thumbTintColor = UIColor.gray
            pulseSlider.minimumTrackTintColor = UIColor.lightGray
        }

    }
    
}

extension DetailViewController: PatientRootSelectionDelegate {
    func patientSelected(patientDetails: [String : Any]) {
        self.patient = patientDetails
        print(self.patient)
        viewDidLoad()
    }
}
