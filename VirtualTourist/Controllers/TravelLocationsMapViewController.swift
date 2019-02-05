//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Raghad Almatrodi on 1/29/19.
//  Copyright © 2019 raghad almatrodi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class  TravelLocationsMapViewController: UIViewController, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate  {
    var pin = [Pin]()
    var fetchResultVC: NSFetchedResultsController<Pin>!
    
    var dataController: CoreData {
        return CoreData.shared
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tapPinsLabel: UILabel!
    @IBOutlet weak var topButton: UIBarButtonItem!
    
    var removePin:Bool = false
    
    let locationManager = CLLocationManager()
    
    @IBAction func editPressed(_ sender: Any) {
        self.tapPinsLabel.isHidden = false
        if topButton.title == "Done" {
            topButton.title = "Edit"
            self.tapPinsLabel.isHidden = true
            removePin = false
        }else{
            topButton.title = "Done"
            removePin = true
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tapPinsLabel.isHidden = true
        bringData()
        bringPins()
        prepareMap()
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        
    }
    @objc func longPress(_ sender: UILongPressGestureRecognizer){
        print("long tap")
        if sender.state == .began && removePin == false {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            addAnnotation(location: locationOnMap)
        }
    }
    func bringData() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultVC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreData.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultVC.delegate = self
        do {
            try fetchResultVC.performFetch()
        } catch {
        }
    }
    func bringPins() {
        guard (fetchResultVC.fetchedObjects?.count) != nil else {
            return
        }
        for pin in fetchResultVC.fetchedObjects! {
            let addPin = MKPointAnnotation()
            addPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            print(addPin.coordinate.latitude)
            self.mapView.addAnnotation(addPin)
            self.pin.append(pin)
        }
        
    }
    
    func prepareMap() {
        locationManager.requestWhenInUseAuthorization()
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.delegate = self
    }
    
    
    
    func addAnnotation(location: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Some Title"
        annotation.subtitle = "Some Subtitle"
        print(annotation.coordinate)
        let savePin = Pin(context: dataController.viewContext)
        savePin.latitude = annotation.coordinate.latitude
        savePin.longitude = annotation.coordinate.longitude
        try? dataController.viewContext.save()
        
        print(savePin.latitude)
        pin.append(savePin)
        
        
        self.mapView.addAnnotation(annotation)
    }
}

extension  TravelLocationsMapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "Pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("tapped on pin ")
        if removePin == true{
            let remove = self.pin.first(where: { $0.latitude == view.annotation?.coordinate.latitude && $0.longitude == view.annotation?.coordinate.longitude})
            self.mapView.removeAnnotation(view.annotation!)
            CoreData.shared.viewContext.delete(remove!)
            try? CoreData.shared.viewContext.save()
        } else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "myVCID") as! PhotoAlbumViewController
            let tmp = self.pin.first(where: { $0.latitude == view.annotation?.coordinate.latitude && $0.longitude == view.annotation?.coordinate.longitude})
            vc.pin = tmp
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
