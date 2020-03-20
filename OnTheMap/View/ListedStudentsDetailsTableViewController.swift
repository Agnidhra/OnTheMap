//
//  ListedStudentsDetailsTableViewController.swift
//  OnTheMap
//
//  Created by Agnidhra Gangopadhyay on 3/10/20.
//  Copyright © 2020 Agnidhra Gangopadhyay. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ListedStudentsDetailsTableViewController: UIViewController {

    var studentLocationDetails =  StudentLocationDetails(results: [])
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logOut: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.studentLocationDetails.results = Client.studentLocationDetails
    }
    
    @IBAction func tappedLogOutButton(_ sender: Any) {
        LoginManager().logOut()
        self.studentLocationDetails.results.removeAll()
        Client.studentLocationDetails.removeAll()
        Client.logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedRefresh(_ sender: Any) {
        self.studentLocationDetails.results.removeAll()
        Client.studentLocationDetails.removeAll()
        Client.getStudentLocationDetails(limit: "100", orderBy: "-updatedAt", completion: handlestudentLocationDetailsRespone)
    }
}

extension ListedStudentsDetailsTableViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return studentLocationDetails.results.count
        
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocationDetailsCellID", for: indexPath)
        let studentLocationDetail = self.studentLocationDetails.results[indexPath.row]
        cell.textLabel?.text = "\(studentLocationDetail.firstName) \(studentLocationDetail.lastName)"
        cell.detailTextLabel?.text = studentLocationDetail.mediaURL
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: self.studentLocationDetails.results[indexPath.row].mediaURL) {
           UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            self.present(AlertVC.getAlert(alertMessage: "Invalid Link"), animated: true)
        }
    }
    
    func handlestudentLocationDetailsRespone(responseData: StudentLocationDetails?, error: Error?){
        print("Inside handlestudentLocationDetailsRespone")
        if let responseData = responseData {
            Client.studentLocationDetails.removeAll()
            self.studentLocationDetails.results.removeAll()
            Client.studentLocationDetails = responseData.results
            self.studentLocationDetails.results = responseData.results
            self.tableView.reloadData()
        } else {
            self.present(AlertVC.getAlert(alertMessage: "Something Went Wrong, Hit Refresh."), animated: true)
        }
    }
}
