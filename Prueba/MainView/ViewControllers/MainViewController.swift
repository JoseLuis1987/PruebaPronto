//
//  MainViewController.swift
//  Prueba
//
//  Created by Pronto on 10/14/19.
//  Copyright © 2019 Pronto. All rights reserved.
//
import UIKit
import Foundation
import MapKit
import CoreLocation
import ObjectMapper
import GoogleMaps
import GooglePlaces

class MainViewController: UIViewController{
    let dataSource = ViewDataSourceTablaList()
    lazy var miViewModel :  MiViewModel = {
          let viewModel = MiViewModel(dataSource: dataSource)
          return viewModel
      }()
    static var apiKey = "AIzaSyB00BsWrcR6n1KBk8ap9_Zqm2GPYBtJbdk"
    //@IBOutlet weak var mapMainView: MKMapView!
    var searchActive : Bool = false
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var results: Dynamic<ConsultaRestaurantsResponse?> = Dynamic<ConsultaRestaurantsResponse?>(nil)
    var sesion: URLSession = URLSession(configuration: .default)
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    

    private lazy var mapMainView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.mapType = MKMapType.standard
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    private lazy var tableViewDetails: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "DatosCell", bundle: nil), forCellReuseIdentifier: "DatosCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorColor = UIColor.clear
        tableView.backgroundColor = UIColor.white
        tableView.sectionIndexColor = UIColor.clear
        tableView.allowsSelection = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mapMainView)
        self.view.addSubview(tableViewDetails)
        tableViewDetails.dataSource = self.dataSource
        tableViewDetails.delegate = self
        initLocationManager()
        setupSearchController()
        bindData()
        addAllConstraints()
    }
    func bindData()  {
        self.dataSource.data.addAndNotify(observer: self) { [weak self] in
                print("hay cambios !!! recargo tabla")
                DispatchQueue.main.async {
                   self!.tableViewDetails.reloadData()
                }
        }
        //add observer to response and set values specific if needed
        self.miViewModel.responseResultSearch.bind({ [weak self](datosObtenidos) in
            if (datosObtenidos?.statusRes?.elementsEqual("OK"))! {
                //Set anotation point correspond
                self?.dataSource.data.value = []
                var aux = 0
                for data in datosObtenidos!.results! {
                    self!.mapMainView.addAnnotation(RestaurantPin.init(coordinate: CLLocationCoordinate2D(latitude: data.latitude!, longitude: data.longitude!), title: data.name!, subtitle: data.vicinity! , iconName: data.icon!, index: aux))
                    self?.dataSource.data.value.append(DatosToSetTable(name: data.name! , icono:data.icon!))
                    aux += 1
                }
            }
        })
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 19.395951, longitude: -99.1789056)
        //find default restaurants
        self.miViewModel.fetchData(textToSearch: "restaurants", current: defaultCoordinate )
    }
    fileprivate func addAllConstraints() {
        NSLayoutConstraint.activate([NSLayoutConstraint(item: tableViewDetails, attribute: .width, relatedBy: .equal, toItem: self.view, attribute:.width, multiplier: 1.0, constant:0.0),NSLayoutConstraint(item: tableViewDetails, attribute: .height, relatedBy: .equal, toItem: self.view, attribute:.height, multiplier: 0.25, constant:0.0),NSLayoutConstraint(item: tableViewDetails, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute:.bottom, multiplier: 1.0, constant:0.0),NSLayoutConstraint(item: mapMainView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute:.width, multiplier: 1.0, constant:0.0),NSLayoutConstraint(item: mapMainView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute:.height, multiplier: 1.0, constant:0.0),NSLayoutConstraint(item: mapMainView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute:.centerX, multiplier: 1.0, constant:0.0),NSLayoutConstraint(item: mapMainView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute:.centerY, multiplier: 1.0, constant:0.0)])
    }
    func initLocationManager()  {
        locationManager.requestWhenInUseAuthorization()
        mapMainView.delegate = self
    }
    func setupSearchController() {
        resultsViewController = GMSAutocompleteResultsViewController()
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
        resultsViewController?.delegate = self
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    @objc func requestTimeout() {
      print("requestTimeout")
      sesion.invalidateAndCancel()
    }
}

extension MainViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    guard status == .authorizedWhenInUse else {
      return
    }
    self.locationManager.startUpdatingLocation()
  }
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
           let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    self.mapMainView.setRegion(region, animated: true)
    self.miViewModel.fetchData(textToSearch: "restaurants", current: location.coordinate)
    self.locationManager.stopUpdatingLocation()
  }
}
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is RestaurantPin) {
            return nil
        }
        let reuseId = "idMapAnotation"
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }else {
            anView!.annotation = annotation
        }
        anView!.calloutOffset = CGPoint(x: -5, y: 5)
        anView!.canShowCallout = true
        anView?.rightCalloutAccessoryView = UIButton(type:.detailDisclosure)
        let cpa = annotation as! RestaurantPin
        anView?.rightCalloutAccessoryView?.tag = cpa.index!
        getData(from: NSURL(string: cpa.iconName!)! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
          //  print(response?.suggestedFilename ?? url.lastPathComponent)
           // print("Download Finished")
            DispatchQueue.main.async() {
                anView!.image = UIImage(data: data)
            }
        }
        return anView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let capital = view.annotation as! RestaurantPin
              let placeName = capital.title
              let placeInfo = capital.subtitle
            let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

extension MainViewController: UITableViewDelegate {
  func updateMapForCoordinate(coordinate: CLLocationCoordinate2D) {
    let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 1000, pitch: 0, heading: 0)
    self.mapMainView.setCamera(camera, animated: false)
        var center = coordinate
        center.latitude -= self.mapMainView.region.span.latitudeDelta / 6.0
    self.mapMainView.setCenter(center, animated: true)
    }
    private func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("select \(indexPath.row)")
        let coordinate = CLLocationCoordinate2D(latitude: (self.miViewModel.responseResultSearch.value?.results![indexPath.row].latitude)!, longitude: (self.miViewModel.responseResultSearch.value?.results![indexPath.row].longitude)!)
        updateMapForCoordinate(coordinate: coordinate)
    }
    
}
