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
import CoreData

class FindBookViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UINavigationControllerDelegate {
    
    var books: [Book] = []
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet weak var bookMapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let deKalb = ", DeKalb, IL, 60115"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let addressString = "855 Regent Dr" + deKalb
        let holmesStudentCenter = "340 Carroll Ave" + deKalb
        let classicBooks = "115 N 1st St" + deKalb
        let villageComons = "901 Lucinda Ave k" + deKalb
        let dekalbPublicLibrary = "309 Oak St" + deKalb
        let foundersMemorialLibrary = "217 Normal Rd" + deKalb
        let davidCShapiroLibrary = "Swen Parson Hall, Northern Illinois University" + deKalb
        
        locationManager.delegate = self
        bookMapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        bookMapView.showsUserLocation = true
        //reverseGeocode(address: addressString + deKalb)
        reverseGeocode(address: holmesStudentCenter)
        reverseGeocode(address: classicBooks)
        reverseGeocode(address: villageComons)
        reverseGeocode(address: dekalbPublicLibrary)
        reverseGeocode(address: foundersMemorialLibrary)
        reverseGeocode(address: davidCShapiroLibrary)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var bookAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "BookAnnotationView")
        
        
        if bookAnnotationView == nil {
            bookAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "BookAnnotationView")
            bookAnnotationView?.canShowCallout = true
        }
        else {
            bookAnnotationView?.annotation = annotation
        }
        
        bookAnnotationView?.canShowCallout = true
        
        if let bookAnnotation = annotation as? BookAnnotation {
            bookAnnotationView?.image = UIImage(named: bookAnnotation.imageURL)
        }
        
        return bookAnnotationView
    }
    
    private func reverseGeocode( address: String ) {
        let geoCoder = CLGeocoder()
        let holmesStudentCenter = "340 Carroll Ave" + deKalb
        let classicBooks = "115 N 1st St" + deKalb
        let villageComons = "901 Lucinda Ave k" + deKalb
        let dekalbPublicLibrary = "309 Oak St" + deKalb
        let foundersMemorialLibrary = "217 Normal Rd" + deKalb
        let davidCShapiroLibrary = "Swen Parson Hall, Northern Illinois University" + deKalb
        
        var addressChange = address
        
        geoCoder.geocodeAddressString(address) {
            (placemarks, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks, let placemark = placemarks.first else {
                return
            }
            
            if ( address ==  holmesStudentCenter) {
                addressChange = "Holmes Student Center Book Store"
            } else if ( address == classicBooks ) {
                addressChange = "Classic Books"
            } else if ( address == villageComons) {
                addressChange = "Village Commons Book Store"
            } else if ( address == dekalbPublicLibrary ) {
                addressChange = "Dekalb Public Library"
            } else if ( address == foundersMemorialLibrary ) {
                addressChange = "Founders Memorial Library"
            } else if ( address == davidCShapiroLibrary ) {
                addressChange = "David C. Shapiro Library"
            }
            
            self.addPlacemarkToMap(placemark: placemark, title: addressChange, subtitle: address)
        }
    }
    
    private func addPlacemarkToMap( placemark: CLPlacemark, title: String, subtitle: String ) {
        let coordinate = placemark.location?.coordinate
        let annotation = BookAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 41.933870, longitude: -88.773029)
        
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.imageURL = "book-pin"
        bookMapView.addAnnotation(annotation)
        annotation.coordinate = coordinate!
    }
    
    
    var detailItem: Book? {
        didSet {
            // Update the view.
            //configureView()
        }
    }
}
