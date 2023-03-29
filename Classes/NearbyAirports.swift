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
//  NearbyAirports.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/29/23.
//

import Foundation
import MapKit
import CoreLocation

@objc public protocol NearbyAirportsDelegate {
    func routeUpdated(_ newRoute : String)
}

@objc public class NearbyAirports : UIViewController, UISearchBarDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var segMapSelector : UISegmentedControl!
    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var toolbar : UIToolbar!
    @IBOutlet weak var bbAction : UIBarButtonItem!
    @IBOutlet weak var bbAddCurloc : UIBarButtonItem!
    @IBOutlet weak var constraintSearchHeight : NSLayoutConstraint!

    @objc public var pathAirports : Airports? = nil
    @objc public var routeText = ""
    @objc public var rgImages : [CommentedImage] = []
    @objc public var delegateNearest : NearbyAirportsDelegate? = nil
    @objc public var associatedFlight : LogbookEntry? = nil

    private var nearbyAirports = Airports()
    private var rgFlightPath : MFBWebServiceSvc_ArrayOfLatLong? = nil
    private var fFirstRun = true
    private var flightPathInProgress = false
    private var fHasAnnotations = false
    private var docController : UIDocumentInteractionController? = nil
    private var defaultSearchHeight : CGFloat = 0.0
    
    private let imageDimension = 50.0
    private let imageCornerRadius = 20.0
    
    // MARK: - Show route vs. airports
    private var showRoute : Bool {
        get {
            return segMapSelector.selectedSegmentIndex == 1
        }
        set (val) {
            segMapSelector.selectedSegmentIndex = val ? 1 : 0
        }
    }

    private var showNearbyAirports : Bool {
        get {
            return segMapSelector.selectedSegmentIndex == 0
        }
        set (val) {
            segMapSelector.selectedSegmentIndex = val ? 0 : 1
        }
    }
    
    func setUpRoute() {
        // auto-select route view if there is a route
        // (I.e., delegate presumes that the flight is being modified and thus is new)
        if !routeText.isEmpty && (pathAirports?.rgAirports.count ?? 0) > 0 {
            searchBar.text = routeText
            showRoute = true
        }
    }
    
    @objc public func addImage(_ ci : CommentedImage) {
        rgImages.append(ci)
    }
    
    // MARK: - View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        setUpRoute()
        // set the target AFTER adjusting the highlighted index above to avoid two calls to updateNearbyAirports
        segMapSelector.addTarget(self, action: #selector(updateNearbyAirports), for: .valueChanged)
        defaultSearchHeight = searchBar.frame.size.height
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(appendAdHoc))
        lpgr.minimumPressDuration = 0.7; // in seconds
        lpgr.delegate = self
        mapView.addGestureRecognizer(lpgr)
        
        // Load a path if necessary
        if associatedFlight != nil {
            getPathForLogbookEntry()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        setUpRoute()
        updateNearbyAirports()
        navigationController?.isToolbarHidden = true

        /*
         // when we switch to iOS 16...
        switch UserPreferences.current.mapType {
        case .hybrid, .hybridFlyover:
            mapView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .flat)
        case .satellite, .satelliteFlyover:
            mapView.preferredConfiguration = MKImageryMapConfiguration(elevationStyle: .flat)
        case .standard, .mutedStandard:
            mapView.preferredConfiguration = MKStandardMapConfiguration()
        default:
            mapView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .flat)
        }
         */
        mapView.mapType = UserPreferences.current.mapType
        enableSendTelemetry()
        bbAddCurloc.isEnabled = delegateNearest != nil
        searchBar.placeholder = String(localized: "RouteSearchPrompt", comment: "Airport codes to map")

        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        if showRoute {
            delegateNearest?.routeUpdated(searchBar.text ?? "")
        }
        super.viewWillDisappear(animated)
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
    
    // MARK: - Flight path
    func addFlightPath() {
        if (rgFlightPath?.latLong.count ?? 0) > 0 && showRoute {
            if let mcr = pathAirports?.defaultZoomRegionWithPath(rgFlightPath) {
                let fr = FlightRoute()
                fr.rgll = rgFlightPath
                fr.lineColor = UserPreferences.current.pathColor
                fr.center = mcr.center
                mapView.addOverlay(fr.getOverlay())
            }
        }
    }
    
    func getPathForLogbookEntry() {
        if !flightPathInProgress && associatedFlight != nil {
            NSLog("GetPathForLogbookEntry in NearbyAirports")
            flightPathInProgress = true
            associatedFlight!.setDelegate(self, completionBlock: { sc, ao in
                if self.flightPathInProgress {
                    self.flightPathInProgress = false
                    self.rgFlightPath = (ao as! LogbookEntry).rgPathLatLong
                    self.addFlightPath()
                    self.enableSendTelemetry()
                    NSLog("Path returned")
                }
            })
            associatedFlight!.getFlightPath()
        }
    }
    
    // MARK: - MKMapViewDelegate
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        let c = NSClassFromString((overlay as! MKPolyline).title!) as! RouteAnnotation.Type
        renderer.strokeColor = c.colorForPolyline()
        return renderer
    }
    
    // MARK: - Add airports and images
    func refreshAirportsOnMap(_ mcr : MKCoordinateRegion) {
        if showNearbyAirports {
            // remove all previous annotations
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            fHasAnnotations = false
            
            if MFBAppDelegate.threadSafeAppDelegate.mfbloc.lastSeenLoc != nil {
                nearbyAirports.loadAirportsNearPosition(mcr, max: -1)
            }
            
            mapView.addAnnotations(nearbyAirports.rgAirports)
        } else if showRoute {
            // nothing to do if we have the path annotations - we'll re-use them
            if !fHasAnnotations {
                let mcr2 = pathAirports?.defaultZoomRegionWithPath(rgFlightPath)
                if !(pathAirports?.rgAirports.isEmpty ?? true) {
                    mapView.addAnnotations(pathAirports!.rgAirports)
                    if pathAirports!.rgAirports.count > 1 {
                        let ar = AirportRoute()
                        ar.airports = pathAirports!
                        ar.lineColor = UserPreferences.current.routeColor
                        ar.center = mcr2!.center
                        
                        // if displaying route, we already have the individual airports.
                        // Now, we just want to add one more pseudo-annotation which is the Routeannotation.
                        mapView.addOverlay(ar.getOverlay())
                    }
                }
                
                addFlightPath()
            }
        }
        
        // add any images as well, but do this on a background thread
        DispatchQueue.global(qos: .background).async {
            for ci in self.rgImages {
                if !ci.hasThumbnailCache {
                    ci.GetThumbnail()
                }
                DispatchQueue.main.async {
                    self.mapView.addAnnotation(ci)
                    self.mapView.setNeedsDisplay()
                }
            }
        }
        
        fHasAnnotations = true
        mapView.setNeedsDisplay()
    }
    
    
    func enableSendTelemetry() {
        bbAction.isEnabled = (rgFlightPath?.latLong.count ?? 0) > 0
    }
    
    func resizeForFrame() {
        constraintSearchHeight.constant = showNearbyAirports ? 0 : defaultSearchHeight
        view.setNeedsUpdateConstraints()
        view.setNeedsLayout()
    }

    // MARK: - IBActions
    @IBAction func updateNearbyAirports() {
        resizeForFrame()
        if showNearbyAirports {
            if let loc = MFBAppDelegate.threadSafeAppDelegate.mfbloc.lastSeenLoc {
                mapView.setRegion(Airports.defaultRegionForPosition(loc), animated: !fFirstRun)
            }
            refreshAirportsOnMap(mapView.region)
        } else if showRoute {   // show the path, zooming appropriately for it.
            if let ap = self.pathAirports {
                // set the region AFTER refreshing any annotations
                refreshAirportsOnMap(mapView.region)
                let mcr = ap.defaultZoomRegionWithPath(rgFlightPath)
                if mcr.span.latitudeDelta > 0 && mcr.span.longitudeDelta > 0 {
                    mapView.setRegion(mcr, animated: !fFirstRun)
                }
            }
        }
        fFirstRun = false
    }
    
    @IBAction func appendCurloc(_ sender : Any) {
        if let loc = MFBAppDelegate.threadSafeAppDelegate.mfbloc.lastSeenLoc {
            showRoute = true    // switch to route, so that we return a new path
            let szLatLong = MFBWebServiceSvc_LatLong(coord: loc.coordinate).toAdhocString()

            let ap = MFBWebServiceSvc_airport.getAdHoc(szLatLong)!
            
            // Append this to the route
            searchBar.text = Airports.appendAirport(ap, szRouteSoFar: searchBar.text ?? "")

            navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    @IBAction func switchView() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        fHasAnnotations = false
        refreshAirportsOnMap(mapView.region)
    }
    
    // MARK: - Gesture delegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func appendAdHoc(_ sender : UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        
        let touchPoint = sender.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let ll = MFBWebServiceSvc_LatLong(coord: touchMapCoordinate)
        let szAdHoc = ll.toAdhocString()
        routeText = "\(routeText.trimmingCharacters(in: CharacterSet.whitespaces)) \(szAdHoc)"
        setUpRoute()
        delegateNearest?.routeUpdated(routeText)
    }
    
    // MARK: - GPX
    func sendTelemetryCompletion() {
        if (associatedFlight?.gpxPath ?? "").isEmpty {
            showErrorAlertWithMessage(msg: String(localized: "errNoTelemetry", comment: "No telemetry to share"))
            return
        }
        
        var fSuccess = false
        
        if let path = MFBAppDelegate.threadSafeAppDelegate.mfbloc.writeToFile(associatedFlight!.gpxPath!) {
            let url = NSURL(fileURLWithPath: path) as URL
            docController = UIDocumentInteractionController(url: url)
            docController?.delegate = nil
            fSuccess = docController?.presentOptionsMenu(from: bbAction, animated: true) ?? false
        }
        
        if !fSuccess {
            showErrorAlertWithMessage(msg: String(localized: "errCantShareTelemetry", comment: "Unable to share telemetry"))
        }
    }
    
    @IBAction func sendTelemetry(_ sender : Any) {
        if !(associatedFlight?.gpxPath ?? "").isEmpty {
            sendTelemetryCompletion()
        } else {
            if !flightPathInProgress && associatedFlight != nil {
                flightPathInProgress = true
                associatedFlight?.setDelegate(self, completionBlock: { sc, ao in
                    self.flightPathInProgress = false
                    self.sendTelemetryCompletion()
                })
                associatedFlight?.getGPXDataForFlight()
            }
        }
    }
    
    // MARK: - MKMapViewDelegate functions
    
    public func mapView(_ mv: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? MKUserLocation {
            // Need to return nil to get updates to work.
            return nil
        } else if let ci = annotation as? CommentedImage {
            let identifier = "pixloc"
            
            let curLocView = (mv.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)) as MKAnnotationView
            
            if ci.hasThumbnailCache {
                let imgView = UIImageView(image: ci.GetThumbnail())
                curLocView.frame = CGRectMake(curLocView.frame.origin.x, curLocView.frame.origin.y, imageDimension, imageDimension)
                imgView.frame = CGRectMake(0.0, 0.0, imageDimension, imageDimension);
                imgView.contentMode = .scaleAspectFill
                curLocView.contentMode = .scaleAspectFill;
                curLocView.addSubview(imgView)
                let layer = imgView.layer
                layer.cornerRadius = imageCornerRadius
                layer.masksToBounds = true
                layer.borderColor = UIColor.lightGray.cgColor
                layer.borderWidth = 2.0
                curLocView.centerOffset = CGPointMake(0.0, 0.0)
            } else {
                curLocView.image = UIImage(named: "cameramarker.png")
                curLocView.contentMode = .center
            }
            curLocView.canShowCallout = true
            
            // add a little + button on the right to display the image
            curLocView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return curLocView;
        } else {
            let identifier = "pinLoc"
            
            let curLocView = (mv.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)) as MKAnnotationView
            
            if let ap = annotation as? MFBWebServiceSvc_airport {
                curLocView.image = UIImage(named: ap.isPort() ? "airport.png" : "tower.png")
                
                // add a little + button on the right if the airport is for an in-progress flight (i.e., that we
                // may want to click on "add" to add the nearest airport)
                if self.delegateNearest != nil && !ap.isAdhoc() {
                    curLocView.rightCalloutAccessoryView = UIButton(type: .contactAdd)
                }
            }
            curLocView.canShowCallout = true
            
            
            return curLocView;
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        refreshAirportsOnMap(mapView.region)
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let ap = view.annotation as? MFBWebServiceSvc_airport {
            // switch to route mode
            showRoute = true
            
            // Append this to the route
            searchBar.text = Airports.appendAirport(ap, szRouteSoFar: searchBar.text ?? "")
            // and then pop ourselves off of the stack
            navigationController?.popViewController(animated: true)
        } else if let ci = view.annotation as? CommentedImage {
            navigationController?.pushViewController(SwiftConversionHackBridge.imageComment(withImage: ci), animated: true)
        }
    }
    
    // MARK: - Search Bar Delegate
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
    
    public func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let ap = Airports()
        routeText = searchBar.text ?? ""
        ap.loadAirportsFromRoute(routeText)
        pathAirports = ap
        
        if !routeText.isEmpty && !ap.rgAirports.isEmpty {
            showRoute = true
        }
        
        searchBar.resignFirstResponder()
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        fHasAnnotations = false
        updateNearbyAirports()
    }
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
}
