//
//  PageViewController.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/9/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

protocol PageSelectionDelegate: class {
    func patientSelected(patientDetails: [String:Any])
}


class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var orderedViewControllers: [UIViewController]?
    weak var delegatePatientDetails: PageSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        self.orderedViewControllers = {
            return [self.newViewController(vc: "Detail"),
                    self.newViewController(vc: "NextDetail")]
        }()
        
        // Do any additional setup after loading the view.
        //var firstViewController = DetailViewController()
        let firstViewController = orderedViewControllers?.first as! DetailViewController //{
        setViewControllers([firstViewController],
                            direction: .forward,
                            animated: true,
                            completion: nil)
        //}
        
        if (Manager.patientDetails != nil && Manager.patientDetails!.count > 0) {
            firstViewController.patient = Manager.patientDetails![0]//masterViewController.patientDetails[0]
        } else {
            //firstPatient[""] =
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func newViewController(vc: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(vc)ViewController")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers?.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard (orderedViewControllers?.count)! > previousIndex else {
            return nil
        }
        
        return orderedViewControllers?[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers?.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = (orderedViewControllers?.count)!
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers?[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers!.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let  firstViewControllerIndex = orderedViewControllers?.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

/*extension PageViewController: PatientRootSelectionDelegate {
    func patientSelected(patientDetails: [String : Any]) {
        //self.patient = patientDetails
        //print(self.patient)
        //viewDidLoad()
        print("HOLA in PAGE \(patientDetails)")
        self.delegatePatientDetails?.patientSelected(patientDetails: patientDetails)
        if let pageViewController = self.delegatePatientDetails as? PageViewController {
            
        //    splitViewController?.showDetailViewController(pageViewController.navigationController!, sender: nil)
             //viewDidLoad()
        }

    }
}*/

    

