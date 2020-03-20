//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Agnidhra Gangopadhyay on 3/11/20.
//  Copyright © 2020 Agnidhra Gangopadhyay. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit
import FacebookCore
class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var studentLocationDetails =  StudentLocationDetails(results: [])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentLocationDetails.results = Client.studentLocationDetails
        UpdateAnotations()
     }
    
    @IBAction func tappedRefresh(_ sender: Any) {
        self.studentLocationDetails.results.removeAll()
        Client.studentLocationDetails.removeAll()
        Client.getStudentLocationDetails(limit: "100", orderBy: "-updatedAt", completion: handlestudentLocationDetailsRespone)
    }
    
    @IBAction func tappedLogoutButton(_ sender: Any) {
        
        AccessToken.current = nil
        Profile.current = nil
        LoginManager().logOut()
        
        let cookies = HTTPCookieStorage.shared
        let facebookCookies = cookies.cookies(for: URL(string: "https://facebook.com/")!)
        for cookie in facebookCookies! {
            cookies.deleteCookie(cookie )
        }
        self.studentLocationDetails.results.removeAll()
        Client.studentLocationDetails.removeAll()
        Client.logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func UpdateAnotations() {
    
        var annotations = [MKPointAnnotation]()
        
        for dictionary in studentLocationDetails.results {
            let lat = CLLocationDegrees(dictionary.latitude )
            let long = CLLocationDegrees(dictionary.longitude )
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let first = dictionary.firstName
            let last = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    func handlestudentLocationDetailsRespone(responseData: StudentLocationDetails?, error: Error?){
        print("Inside handlestudentLocationDetailsRespone")
        if let responseData = responseData {
            Client.studentLocationDetails = responseData.results
            self.studentLocationDetails.results = responseData.results
            removeAllAnnotations()
            UpdateAnotations()
        } else {
            self.present(AlertVC.getAlert(alertMessage: "Something Went Wrong, Hit Refresh."), animated: true)
        }
    }
    
    func removeAllAnnotations() {
        let annotations = mapView.annotations.filter {
            $0 !== self.mapView.userLocation
        }
        self.mapView.removeAnnotations(annotations)
    }
}
