//
//  NewLocationOnMapViewController.swift
//  OnTheMap
//
//  Created by Agnidhra Gangopadhyay on 3/11/20.
//  Copyright © 2020 Agnidhra Gangopadhyay. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class NewLocationOnMapViewController: UIViewController, MKMapViewDelegate {
    
    var pecker: CLPlacemark?
    var mediaURL: String?
    var placeName: String?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Location"
        UpdateAnotations()
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    @IBOutlet weak var finishButton: UIButton!
    
    @IBAction func finishButtonTapped(_ sender: Any) {
        
        Client.postStudentLocation(latitude: (pecker?.location?.coordinate.latitude)!,
                                   longitude: ((pecker?.location?.coordinate.longitude)!),
                                   address: placeName!, mediaURL: mediaURL!, completion: handlePostStudentlocationResponse(postSuccessResponse:failureResponse:error:))
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .system)
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func UpdateAnotations() {
        var annotations = [MKPointAnnotation]()
        let coordinate = pecker?.location?.coordinate
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        annotation.title = placeName
        annotation.subtitle = mediaURL
        
        annotations.append(annotation)
        
        self.mapView.addAnnotations(annotations)
    }
    

    func handlePostStudentlocationResponse(postSuccessResponse: PostSuccessResponse?, failureResponse: FailureType?, error: Error?){
        guard  postSuccessResponse != nil else {
            if let failureResponse = failureResponse {
                self.present(AlertVC.getAlert(alertMessage: failureResponse.error), animated: true)
            } else {
                self.present(AlertVC.getAlert(alertMessage: "Some Issue Try Again Latter"), animated: true)
            }
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}


