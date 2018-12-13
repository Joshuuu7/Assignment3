//
//  AttachPhotoViewController.swift
//  Assignment3
//
//  Created by Joshua Aaron Flores Stavedahl on 12/5/18.
//  Copyright © 2018 Northern Illinois University. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class FindBookViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var bookMapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        bookMapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        bookMapView.showsUserLocation = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
    }
    
    private func reverseGeocode( address: String ) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) {
            (placemarks, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks, let placemark = placemarks.first else {
                return
            }
            
            self.addPlacemarkToMap(placemark: placemark)
        }
    }
    
    private func addPlacemarkToMap( placemark: CLPlacemark ) {
        let coordinate = placemark.location?.coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        bookMapView.addAnnotation(annotation)
    }
    
}
