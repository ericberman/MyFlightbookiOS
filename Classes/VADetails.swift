/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2017-2023 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  VADetails.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/31/23.
//

import Foundation
import MapKit

public class VADetails : UIViewController, MKMapViewDelegate {
    public var rgVA : [MFBWebServiceSvc_VisitedAirport] = []
    
    var mapView : MKMapView {
        get {
            return view as! MKMapView
        }
    }
    
    // MARK: View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if rgVA.count == 1 {
            let va = rgVA[0]
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(findFlights))
            navigationItem.title = va.airport.code
        } else {
            navigationItem.rightBarButtonItem = nil
            navigationItem.title = ""
        }
        
        showAirports()
    }
    
    public override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .all
        }
    }
    
    // MARK: - ShowAirport or airports
    func showAirports() {
        let llb = LatLongBox()
        
        // remove all previous annotations
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
     
        for va in rgVA {
            llb.addPoint(va.airport.latLong.coordinate())
        }
        mapView.addAnnotations(rgVA)
        
        if rgVA.count == 1 {
            let va = rgVA[0]
            let ll = va.airport.latLong!
            // 0.008 degrees is approximately 1nm delta
            let mcr = MKCoordinateRegion(center: ll.coordinate(), span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
            mapView.setRegion(mcr, animated: true)
        } else {
            mapView.setRegion(llb.getRegion(), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate Functions
    public func mapView(_ mv: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? MKUserLocation {
            // Need to return nil to get updates to work.
            return nil
        } else {
            let identifier = "pinLoc"
            
            let curLocView = mv.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            curLocView.image = UIImage(named: "airport.png")
            curLocView.canShowCallout = true
            curLocView.rightCalloutAccessoryView = UIButton(type: .infoLight)
            return curLocView
        }
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // The annotation is a visited-airport object
        findFlightsForAirport(view.annotation as! MFBWebServiceSvc_VisitedAirport)
    }
    
    // MARK: - View matching flights
    @objc public func findFlights(_ sender : AnyObject) {
        if rgVA.count != 1 || navigationController == nil {
            return
        }
        findFlightsForAirport(rgVA[0])
    }
    
    func findFlightsForAirport(_ va : MFBWebServiceSvc_VisitedAirport) {
        let fq = MFBWebServiceSvc_FlightQuery.getNewFlightQuery()
        fq.airportList.string.addObjects(from: Airports.CodesFromString(va.AllCodes()))
        let rfv = SwiftConversionHackBridge.recentFlights(with: fq)
        navigationController?.pushViewController(rfv, animated: true)
    }
}
