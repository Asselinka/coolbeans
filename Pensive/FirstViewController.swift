//
//  FirstViewController.swift
//  Pensive
//
//  Created by Assel Kashkenbayeva on 24/10/2016.
//  Copyright © 2016 Assel Kashkenbayeva. All rights reserved.
//




import UIKit

import GoogleMaps
import GooglePlaces



import Firebase
import FirebaseDatabase
import FirebaseAuth

import BTNavigationDropdownMenu
import IGLDropDownMenu

import BubbleTransition


var STOREDPlaces = [[String:AnyObject]]()
var STOREDFolders = [[String:AnyObject]]()
var itemIndex = Int()

class markerUserData{
    var nameUserData: String
    var addressUserData: String
    var websiteUserData: String
    var telephoneUserData: String
    var firebaseKey : String
    var rating: Int
    var checkbox: Bool
    var tags: String
    var placepicture: String
    var folderName: String
    init(Name: String, Address: String, Website: String, Telephone: String, FirebaseKey: String, Rating: Int, Checkbox: Bool, Tags: String, PlacePicture: String, FolderName: String) {
        self.nameUserData = Name
        self.addressUserData = Address
        self.websiteUserData = Website
        self.telephoneUserData = Telephone
        self.firebaseKey = FirebaseKey
        self.rating = Rating
        self.checkbox = Checkbox
        self.tags = Tags
        self.placepicture = PlacePicture
        self.folderName = FolderName
    }
}
class FirstViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UISearchBarDelegate, GMSAutocompleteViewControllerDelegate, UIGestureRecognizerDelegate, IGLDropDownMenuDelegate, UIViewControllerTransitioningDelegate, DataEnteredDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    
      let transition = BubbleTransition()
    
    //This is for the friend slider view
      var allFilters: [FILTER] = []
    @IBOutlet var friendSlider: UICollectionView!
    
    //Container for viewing Gmaps
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var vwGMap = GMSMapView()
    var Markers = [GMSMarker]()
    
    @IBOutlet var pictureOfPlace: UIImageView!
 
    @IBOutlet var detailsPopUp: UIView!
    
    @IBOutlet var detailsName: UILabel!
    
    
    @IBOutlet var websiteButton: UIButton!
    
    @IBOutlet var telephoneButton: UIButton!
    
    @IBOutlet var shareButton: UIButton!
    
    
    
    @IBOutlet var ratingControl: RatingControl!
    
    
    @IBOutlet var nameWhenAddingPlace: UILabel!
    
    
    @IBOutlet var mapCustomInfoWindow: UIView!
    
  
 
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var AddNewPlaceButton: UIButton!
    
    var place:GMSPlace?
    
    var marker = GMSMarker()
    
    var newPlaceName = ""
    var newPlaceAddress = ""
    var newPlacePlaceID = ""
    var newPlaceTelephone = ""
   
    var folderItem = ""
    var folderIconIndex = ""
    
    var telephone = ""
    var openNowStatus = ""
    var types = ""
    var priceLevel = ""
    var website = ""
    
    
    var latitudeText = ""
    var longitudeText = ""
    var newPlaceNameText = ""
    


    var storedPlaceLatitude = ""
    var storedPlaceLongitude = ""
    
    var user = Auth.auth().currentUser
    var databaseRef = Database.database().reference()
    
    var effect:UIVisualEffect!

 
   
       var dropDownMenuFolder = IGLDropDownMenu()
    
    var tappedMarker = CLLocationCoordinate2D()
    var folderNames = [String]()
    
    var markersArray = [CLLocationCoordinate2D]()
    var placeIDsArray = [String]()
    var placeNamesArray = [String]()
    var placeWebsiteArray = [String]()
    
    var filterSelected = ""
    
    var markerID = ""
 
    var firebaseKey = ""
    var ratingControlRating = Int()
    var checkboxBool: Bool = false
    var tagsMarker = ""
    var markerPlacePictureURL = ""
    var tappedMarkerAddress = ""
    var tappedMarkerTelephone = ""
    var tappedMarkerWebsite = ""
    
    var longPressCoordinate = CLLocationCoordinate2D()
   
   
    
    @IBOutlet var closeDetailsButton: UIButton!
    
    @IBOutlet var moreDetailButton: UIButton!
    
    
    var afterfirebase = Int()
    var updaterating = Int()
    
    var userCurrentLocation = CLLocationCoordinate2D()
    var jim = CLLocation()
    
    var MARKers = [GMSMarker]()
    
    let placesClient = GMSPlacesClient.shared()
    
    let mygroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //This makes sure that the collection view in the container is flush with the searchbar at the top
           self.automaticallyAdjustsScrollViewInsets = false
       self.filterSelected = "All"
    
        // removes the navigation bar
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
       
        let attributes = [NSFontAttributeName : UIFont(name: "Oriya Sangam MN", size: 20)!, NSForegroundColorAttributeName : UIColor.orange]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        
        // this is for the sort by drop down menu
        effect = visualEffectView?.effect
        visualEffectView?.isHidden = true
        visualEffectView?.effect = nil
  
    let frame = CGRect(x: 0, y: friendSlider.frame.maxY, width: self.view.frame.width, height: self.view.frame.height*0.8)
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 22.300000, longitude: 70.783300, zoom: 10.0)
        vwGMap = GMSMapView.map(withFrame: frame , camera: camera)
        vwGMap.camera = camera
        vwGMap.settings.scrollGestures = true
        vwGMap.settings.zoomGestures = true
        vwGMap.settings.myLocationButton = true
        vwGMap.settings.compassButton = true
        vwGMap.settings.allowScrollGesturesDuringRotateOrZoom = true
 
        //setting the delegate
        vwGMap.delegate = self
        
        //allowing and finding the current location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.view.addSubview(vwGMap)
        
//This is getting access to the database and accessing the stored places child information and storing it into a local STOREDPlaces dictionary
        let ref = Database.database().reference().child((user?.uid)!).child("StoredPlaces")
        print("THIS IS STORED PLACES IN GOOGLE MAPS VIEW CONTROLLER")
        ref.observe( .value, with: { (snapshot) in
            print(self.MARKers.count)
          self.MARKers.removeAll()
            print(self.MARKers.count)
            STOREDPlaces.removeAll()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let key = snap.key
                        self.firebaseKey = key
                        var PLACE = (dictionary[key] as? [String: AnyObject]!)!
                        
                        let latitude = (dictionary[key]?["Latitude"] as? NSString)?.doubleValue
                        let longitude = (dictionary[key]?["Longitude"] as? NSString)?.doubleValue

    let markers = GMSMarker()
   markers.position = CLLocationCoordinate2D(latitude: latitude! , longitude: longitude!)
  self.markersArray.append(markers.position)
    
    let folderIcon = (dictionary[key] as? [String: AnyObject]!)!["FolderIcon"]
   markers.icon = UIImage(named:folderIcon! as! String)
                      
    let name = (dictionary[key] as? [String: AnyObject]!)!["StoredPlaceName"]
    let website = (dictionary[key] as? [String: AnyObject]!)!["StoredPlaceWebsite"]
    let address = (dictionary[key] as? [String: AnyObject]!)!["StoredPlaceAddress"]
    let rating = (dictionary[key] as? [String: AnyObject]!)!["Rating"]
    let checkbox = (dictionary[key] as? [String: AnyObject]!)!["Checkbox"]
    let tags = (dictionary[key] as? [String: AnyObject]!)!["Tags"]
    let placePicture = (dictionary[key] as? [String: AnyObject]!)!["StoredPlacePicture"]
    let telephone = (dictionary[key] as? [String: AnyObject]!)!["StoredPlaceTelephone"]
    let foldername = (dictionary[key] as? [String: AnyObject]!)!["PlaceUnderFolder"]
                       
    
  markers.accessibilityValue = name as! String
                       
  self.placeNamesArray.append(name! as! String)
                  
                        
        let storedPlaceUserData = markerUserData(Name: name! as! String, Address: address! as! String, Website: website! as! String, Telephone: telephone! as! String, FirebaseKey: key, Rating: rating! as! Int, Checkbox: checkbox! as! Bool, Tags: tags! as! String, PlacePicture: placePicture! as! String, FolderName: foldername as! String)
                        
    markers.userData = storedPlaceUserData
                        
    PLACE?.updateValue(self.firebaseKey as AnyObject, forKey: "firebaseKey")
                        
                        STOREDPlaces.append(PLACE!)
                        
                        self.MARKers.append(markers)
                        //print(self.MARKers.count)
                        
                    }
                }
               self.filterPlaces()
                
            }
        }
        )
       
        
//This does the same as previous but accesses the stored folders file and places into the STOREDFolders dict
        let refFolders = Database.database().reference().child((user?.uid)!).child("UserFolders")
        print("THIS IS STORED FOLDER IN GOOGLE MAPS VIEW CONTROLLER")
       
        refFolders.observe( .value, with: { (snapshot) in
            
            STOREDFolders.removeAll()
            self.folderNames.removeAll()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                 self.mygroup.enter()
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                
                        let key = snap.key
                        var FOLDER = (dictionary[key] as? [String: AnyObject]!)!
                          let folder = (dictionary[key] as? [String: AnyObject]!)!["FolderName"]
                        self.folderNames.append(folder! as! String)
                        FOLDER?.updateValue(key as AnyObject, forKey: "firebaseKey")
                        STOREDFolders.append(FOLDER!)
                    self.mygroup.leave()
                    }
                    
                }
            }
            self.setupInIt()
          //  self.sortByDropDown()
        }
        )
   // self.lookUpPlaceID()
        mygroup.notify(queue: .main) {
            print("completed storedfolders")
            print(STOREDFolders.count)
        }
        fetchFolder()
        fetchFriends()
    }
    
    

    func filterPlaces() {
        self.vwGMap.clear()
        print("Filter places function is being called")
        print(self.filterSelected)
        if self.filterSelected == "All"
        {
            for m in MARKers {
                var marKER = GMSMarker()
                marKER = m
                marKER.map = self.vwGMap
            }
                self.vwGMap.setNeedsDisplay()
        }
        else if self.filterSelected != "All"  {
            for m in MARKers {
           if (m.userData as! markerUserData).folderName as? String == self.filterSelected {
            
                var marKER = GMSMarker()
                marKER = m
                marKER.map = self.vwGMap
            }
            }
              self.vwGMap.setNeedsDisplay()
        }
      
    }
/*
    func sortByDropDown() {
        let items = self.folderNames
      
        folderNames.append("All")
       // let menuView = BTNavigationDropdownMenu(title: "Sort By", items: items as [AnyObject])
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: "Sort By", items: items as [AnyObject])
        
        menuView.updateItems(self.folderNames as [AnyObject])

         self.navigationItem.titleView = menuView
     
        self.navigationItem.titleView?.isUserInteractionEnabled = true

        menuView.cellTextLabelColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        menuView.menuTitleColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        menuView.cellSelectionColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
 
            menuView.setNeedsDisplay()
            menuView.setNeedsLayout()
            if indexPath != nil {
          self?.filterSelected = (self?.folderNames[indexPath])!
               // print((self?.filterSelected)!)
            self?.filterPlaces()
            }
            return
        }
    }
*/
    func setupInIt() {
        
        let dropdownItems: NSMutableArray = NSMutableArray()

        if STOREDFolders.count > 0 {
            for i in 0...(STOREDFolders.count-1) {
                let item = IGLDropDownItem()
                item.text = (STOREDFolders[i]["FolderName"] as! String!)
                item.iconImage = UIImage(named: STOREDFolders[i]["FolderIcon"] as! String!)
                item.iconImage.accessibilityIdentifier = STOREDFolders[i]["FolderIcon"] as! String!
              //  print("This is in the choose folder drop down menu")
              //  print(item.text)
          
                dropdownItems.add(addObject:item)
               // print(item.iconImage.accessibilityIdentifier)
            }
          
        }
        else {
            //If there are no folders, there is a baseline folder set here
                let item = IGLDropDownItem()
                item.text = "My new list"
                item.iconImage = UIImage(named: "4")
                item.iconImage.accessibilityIdentifier = "4"

                dropdownItems.add(addObject:item)
            
            let folderName = item.text
            let folderIcon = item.iconImage.accessibilityIdentifier
            
            
            let post : [String: AnyObject] = ["FolderName" : folderName as AnyObject, "FolderIcon" : folderIcon as AnyObject ]

            let databaseRef = Database.database().reference()
            databaseRef.child((self.user?.uid)!).child("UserFolders").childByAutoId().setValue(post)
        }
        
        dropDownMenuFolder.menuText = "Choose Folder"
        dropDownMenuFolder.dropDownItems  = dropdownItems as [AnyObject]
        dropDownMenuFolder.paddingLeft = 15
        dropDownMenuFolder.frame = CGRect(x: 50, y: 0 , width: 200, height: 45)
        dropDownMenuFolder.delegate = self
        dropDownMenuFolder.type = IGLDropDownMenuType.stack
        dropDownMenuFolder.gutterY = 5
        dropDownMenuFolder.itemAnimationDelay = 0.1
        dropDownMenuFolder.reloadView()
  
     // print(dropDownMenuFolder.frame.width)
      dropDownMenuFolder.frame.origin.x = mapCustomInfoWindow.center.x-dropDownMenuFolder.frame.width/2
    //    dropDownMenuFolder.frame.origin.y = mapCustomInfoWindow.center.y
      
    }
  
    
    //This is delegate for what is selected in dropdown menu when adding new place
    func dropDownMenu(_ dropDownMenu: IGLDropDownMenu!, selectedItemAt index: Int) {
        let item:IGLDropDownItem = dropDownMenu.dropDownItems[index] as! IGLDropDownItem
        let folderItem = item.text
        self.folderItem = folderItem!
        let folderIconIndex = item.iconImage.accessibilityIdentifier
        self.folderIconIndex = folderIconIndex!
        AddNewPlaceButton.isUserInteractionEnabled = true
        AddNewPlaceButton.setTitleColor(UIColor.red, for: .normal)
    }

    /*
    //This is setting up the details infoWindow pop up
    func animatedIn() {
        
        self.view.addSubview(detailsPopUp)
        detailsPopUp.center = self.view.center
        
        detailsPopUp.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        detailsPopUp.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView?.effect = self.effect
            self.visualEffectView?.isHidden = false
            self.detailsPopUp.alpha = 1
            self.detailsPopUp.transform = CGAffineTransform.identity
        }
    }
    */
    
    //MARK: Current location permission requests
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedWhenInUse)
        {
            vwGMap.isMyLocationEnabled = true
            /*
            let circleCenter = CLLocationManager. ;
            let circ = GMSCircle(position: circleCenter!, radius: 200)
            circ.fillColor = UIColor(red: 0.0, green: 0.7, blue: 0, alpha: 0.1)
            circ.strokeColor = UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.5)
            circ.strokeWidth = 2.5;
            let CLocation = CLLocation(latitude: 51.5074, longitude: 0.1278)
            let location = newLocation?.distance(from: CLocation)
            
            circ.map = self.vwGMap
            self.view = self.vwGMap
 */
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        jim = newLocation!
        userCurrentLocation = (newLocation?.coordinate)!
        vwGMap.camera = GMSCameraPosition.camera(withTarget: newLocation!.coordinate, zoom: 7.0)
     /*
        let circleCenter = newLocation?.coordinate ;
        let circ = GMSCircle(position: circleCenter!, radius: 200)
        circ.fillColor = UIColor(red: 0.0, green: 0.7, blue: 0, alpha: 0.1)
        circ.strokeColor = UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.5)
        circ.strokeWidth = 2.5;
         let CLocation = CLLocation(latitude: 51.5074, longitude: 0.1278)
        let location = newLocation?.distance(from: CLocation)
        
        circ.map = self.vwGMap
        self.view = self.vwGMap 
 */
       // locationsInsideRadius()

 }
    /*
    func locationsInsideRadius() {
        let circleCenter = jim.coordinate
        let circ = GMSCircle(position: circleCenter, radius: 200)
        
        for p in STOREDPlaces {
            let latitude = (p["Latitude"] as? NSString)?.doubleValue
            let longitude = (p["Longitude"] as? NSString)?.doubleValue
            let place = CLLocation(latitude: latitude!, longitude: longitude!)
    let distanceInMeters = jim.distance(from: place )
        if distanceInMeters <= 200 {
            print(p[("StoredPlaceName" as? String)!])
        } else {
            print("NOT NOT NOT")
        }
        }
      
        circ.fillColor = UIColor(red: 0.0, green: 0.7, blue: 0, alpha: 0.1)
        circ.strokeColor = UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.5)
        circ.strokeWidth = 2.5;
        let CLocation = CLLocation(latitude: 51.5074, longitude: 0.1278)
        let location = jim.distance(from: CLocation)
        
        circ.map = self.vwGMap
        self.view = self.vwGMap
    }
    */
    //MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.vwGMap.isMyLocationEnabled = true }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.vwGMap.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil }
    }
    
    //MARK: GoogleMaps Autocomplete
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.marker.map = nil
        detailsPopUp.removeFromSuperview()
        self.place = place
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        self.vwGMap.camera = camera
        //it appends markers rather than removing them
      let marker = GMSMarker()
      self.marker = marker
        marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        marker.accessibilityValue = place.name
        marker.map = self.vwGMap
        marker.icon = GMSMarker.markerImage(with: UIColor.blue)
        self.dismiss(animated: true, completion: nil)
   // marker.tracksViewChanges = false
     //   let newPlaceName = place.name
        self.newPlaceName = place.name
        var newPlaceNameText:String = "\(newPlaceName)"
        self.newPlaceNameText = "\(newPlaceName)"
      //  let newPlaceAddress = place.formattedAddress
        self.newPlaceAddress = place.formattedAddress!
      //  let newPlacePlaceID = place.placeID
        self.newPlacePlaceID = place.placeID
        
        let newPlaceLatitude = place.coordinate.latitude
        var latitudeText:String = "\(newPlaceLatitude)"
        self.latitudeText = "\(newPlaceLatitude)"
        
        
        let newPlaceLongitude = place.coordinate.longitude
        var longitudeText:String = "\(newPlaceLongitude)"
        self.longitudeText = "\(newPlaceLongitude)"
        
        var telephone = place.phoneNumber
        if telephone == nil {
            self.telephone = ""
        } else {
        self.telephone = telephone!
        }
        var website =  place.website
        //this doesnt really save the website
        if website == nil {
            self.website = ""
        } else {
            var newWebsite = website!
        self.website = "\(newWebsite)"
        }
        tappedMarker = marker.position
        nameWhenAddingPlace.text = newPlaceNameText
        AddNewPlaceButton.isUserInteractionEnabled = false
        AddNewPlaceButton.setTitleColor(UIColor.gray, for: .normal)
        self.vwGMap.addSubview(mapCustomInfoWindow)
        self.vwGMap.addSubview(dropDownMenuFolder)
        mapCustomInfoWindow.layer.borderWidth = 2
        mapCustomInfoWindow.layer.borderColor = UIColor.darkGray.cgColor
            }
    
    //Initiated if autocomplete failed
    func viewController(_ viewcontroller: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)") }
    
    //Initiated if autocomplete cancelled
    func wasCancelled(_ viewController:GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)   }
    
    //This allows the search button to be clicked
    @IBAction func searchWithAddress(_ sender: AnyObject) {
        let searchWithAddress = GMSAutocompleteViewController()
        searchWithAddress.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        filter.country = "UK"
        self.locationManager.startUpdatingLocation()
        
        self.present(searchWithAddress, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
       tappedMarker = marker.position
    
        self.ratingControlRating = ratingControl.rating
      //  print("Outside tapped")
      //  print(ratingControlRating)
                   if marker.userData  == nil {
                        AddNewPlaceButton.isUserInteractionEnabled = false
                        AddNewPlaceButton.setTitleColor(UIColor.gray, for: .normal)
         //    detailsName.text = marker.accessibilityValue
                        
          //  moreDetailButton.setTitleColor(UIColor.white, for: .normal)
            //closeDetailsButton.setTitleColor(UIColor.white, for: .normal)
            //websiteLabel.textColor = UIColor.white
            //            websiteLabel.isHidden = true
         //   ratingControl.isHidden = true
         //   pictureOfPlace.isHidden = true
            mapCustomInfoWindow.center = mapView.projection.point(for: tappedMarker)
            mapCustomInfoWindow.center.y -= 150
        
            mapCustomInfoWindow.layer.borderWidth = 2
            mapCustomInfoWindow.layer.borderColor = UIColor.darkGray.cgColor
         //   self.mapCustomInfoWindow.addSubview(dropDownMenuFolder)
            
         //   self.view.addSubview(detailsPopUp)
            self.vwGMap.addSubview(mapCustomInfoWindow)
          self.vwGMap.addSubview(dropDownMenuFolder)
        } else {
         //tappedMarker = marker.position
                    
                    if (marker.userData as! markerUserData).websiteUserData == "" {
                        websiteButton.isHidden = true
                        print("there is nothing in the website")
                    } else {
                        tappedMarkerWebsite = (marker.userData as! markerUserData).websiteUserData
                        websiteButton.isHidden = false
                         print("there is definately a website")
                    }
                    
                    if (marker.userData as! markerUserData).telephoneUserData == "" {
                     telephoneButton.isHidden = true
                    } else {
                        tappedMarkerTelephone = (marker.userData as! markerUserData).websiteUserData
                        telephoneButton.isHidden = false
                    }
                    
                    
                        moreDetailButton.setTitleColor(UIColor.red, for: .normal)
                        closeDetailsButton.setTitleColor(UIColor.red, for: .normal)
                   
                        ratingControl.isHidden = false
            detailsName.text = (marker.userData as! markerUserData).nameUserData
            self.firebaseKey = (marker.userData as! markerUserData).firebaseKey
            ratingControl.firebaseKey = firebaseKey
                       //  print("inside tapped")
    if self.ratingControlRating != (marker.userData as! markerUserData).rating  {
        ratingControl.rating = (marker.userData as! markerUserData).rating
    } else {
         ratingControl.rating = self.ratingControlRating }
                    //    print((marker.userData as! markerUserData).rating)
                    //    print(ratingControlRating)
        
        updaterating = (marker.userData as! markerUserData).rating
        checkboxBool = (marker.userData as! markerUserData).checkbox
        tagsMarker = (marker.userData as! markerUserData).tags
       // websiteLabel.text = (marker.userData as! markerUserData).websiteUserData
        markerPlacePictureURL = (marker.userData as! markerUserData).placepicture
        tappedMarkerTelephone = (marker.userData as! markerUserData).telephoneUserData
                       // print(tappedMarkerTelephone)
        tappedMarkerAddress = (marker.userData as! markerUserData).addressUserData
        detailsPopUp.layer.borderWidth = 2
        detailsPopUp.layer.borderColor = UIColor.darkGray.cgColor
    
        getImage(imageName:(marker.userData as! markerUserData).firebaseKey )
          self.vwGMap.addSubview(detailsPopUp)
        }
        return false
    }
  
    func getImage(imageName: String){
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            pictureOfPlace.image = UIImage(contentsOfFile: imagePath)
            pictureOfPlace.layer.borderWidth = 1
            pictureOfPlace.layer.masksToBounds = false
            pictureOfPlace.layer.borderColor = UIColor.orange.cgColor
            pictureOfPlace.layer.cornerRadius = pictureOfPlace.frame.height/2
            pictureOfPlace.clipsToBounds = true
            pictureOfPlace.isHidden = false
            print("I have uploaded image from internal database")
        }else{
            //if there is no image added to the place then rearrange the detail view to look good without the little picture
            pictureOfPlace.isHidden = true
        }
    }

    
    //This produces the coordinate of where it tapped on the map, doesn't work on tapped markers
    /*func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
     print(String(coordinate.latitude))
     print(String(coordinate.longitude))
     }
     */
    
    //This prints out the details just by clicking on a place need to enable this
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
  
        vwGMap.animate(to: GMSCameraPosition.camera(withTarget: location, zoom: 15.0))
       self.marker.map = nil
        let marker = GMSMarker()
       
        self.marker = marker
        marker.position = location
        tappedMarker = location
        marker.map = self.vwGMap
        mapCustomInfoWindow.layer.borderWidth = 2
        mapCustomInfoWindow.layer.borderColor = UIColor.darkGray.cgColor
        self.vwGMap.addSubview(mapCustomInfoWindow)
        self.vwGMap.addSubview(dropDownMenuFolder)
        
 marker.icon = GMSMarker.markerImage(with: UIColor.blue)
self.newPlacePlaceID = placeID
        print(placeID)
        print(self.newPlacePlaceID)
        print(name)
    self.newPlaceNameText = name
        nameWhenAddingPlace.text = name
    
        lookUpPlaceID()
               }

    func lookUpPlaceID () {
  
         var Place:GMSPlace?
        self.placesClient.lookUpPlaceID(self.newPlacePlaceID, callback: { (placeID, error) -> Void in
            if let error = error {
                
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            guard let place = Place else {
                print("No place details for \(placeID)")
                
                self.newPlaceAddress = (placeID?.formattedAddress)!
                let newPlaceLongitude = (placeID?.coordinate.longitude)!
                var longitudeText:String = "\(newPlaceLongitude)"
                self.longitudeText = "\(newPlaceLongitude)"
                
                let newPlaceLatitude = (placeID?.coordinate.latitude)!
                var latitudeText:String = "\(newPlaceLatitude)"
                self.latitudeText = "\(newPlaceLatitude)"
                var telephone = placeID?.phoneNumber
                if telephone == nil {
                    self.telephone = ""
                } else {
                    self.telephone = telephone!
                }
                
                var website =  placeID?.website
                //this doesnt really save the website
                if website == nil {
                    self.website = ""
                    print("THERE IS NO WEBSITE")
                } else {
                    var newWebsite = website!
                    self.website = "\(newWebsite)"
                    print("THERE IS A WEBSITE")
                }
            
                return
            }
            
        })
    }

   
    
    //This is so that the addPlace window tacks onto place with marker
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
       detailsPopUp.center = mapView.projection.point(for: tappedMarker)
       detailsPopUp.center.y -= 150
        mapCustomInfoWindow.center = mapView.projection.point(for: tappedMarker)
        mapCustomInfoWindow.center.y -= 150
    dropDownMenuFolder.frame.origin.x = mapCustomInfoWindow.center.x-dropDownMenuFolder.frame.width/2
    dropDownMenuFolder.frame.origin.y = mapCustomInfoWindow.center.y-30
    }

    @IBOutlet weak var CancelAddNewPlace: UIButton!
    
    //When adding new place, saves place to Firebase, changes icon to selected
    @IBAction func AddNewPlaceAction(_ sender: Any) {
        
        let PlaceName: String = self.newPlaceNameText
        let PlaceAddress: String = self.newPlaceAddress
        let PlaceTelephone: String = self.telephone
        let PlaceWebsite = self.website
        let PlaceID = self.newPlacePlaceID
        let PlaceUnderFolder = self.folderItem
        let LongitudeCoordinate = self.longitudeText
        let LatitudeCoordinate = self.latitudeText
        let FolderIcon = self.folderIconIndex
        //this is not correct because it shows the whole array in one part
        var post : [String: AnyObject] = ["StoredPlaceName" : PlaceName as AnyObject, "StoredPlaceID" : PlaceID as AnyObject, "StoredPlaceAddress" : PlaceAddress as AnyObject, "StoredPlaceWebsite" : PlaceWebsite as AnyObject, "StoredPlaceTelephone" : PlaceTelephone as AnyObject,  "PlaceUnderFolder" : PlaceUnderFolder as AnyObject,"FolderIcon" : FolderIcon as AnyObject,  "Longitude" : LongitudeCoordinate as AnyObject, "Latitude" : LatitudeCoordinate as AnyObject, "Rating" : 0 as AnyObject, "Tags" : "" as AnyObject, "Checkbox" : false as AnyObject, "StoredPlacePicture": "" as AnyObject ]
        
        let databaseRef = Database.database().reference()
        databaseRef.child((self.user?.uid)!).child("StoredPlaces").childByAutoId().setValue(post)
     
        marker.icon = UIImage(named: FolderIcon )
        mapCustomInfoWindow.removeFromSuperview()
        //this drop down menu does not appear after opening the window once
        dropDownMenuFolder.removeFromSuperview()
      //  detailsPopUp.removeFromSuperview()
        let when = DispatchTime.now() + 2
    DispatchQueue.main.asyncAfter(deadline: when) {
           
    self.moreDetailButton.setTitleColor(UIColor.red, for: .normal)
    self.closeDetailsButton.setTitleColor(UIColor.red, for: .normal)
         //   print((self.MARKers.last?.userData as! markerUserData).firebaseKey)
         //   self.websiteLabel.isHidden = false
        
            self.ratingControl.isHidden = false
            self.detailsName.text = (self.MARKers.last?.userData as! markerUserData).nameUserData
            self.firebaseKey = (self.MARKers.last?.userData as! markerUserData).firebaseKey
            self.ratingControl.firebaseKey = self.firebaseKey
            print("inside tapped")
            if self.ratingControlRating != (self.MARKers.last?.userData as! markerUserData).rating  {
                self.ratingControl.rating = (self.MARKers.last?.userData as! markerUserData).rating
            } else {
                self.ratingControl.rating = self.ratingControlRating }
       
            self.updaterating = (self.MARKers.last?.userData as! markerUserData).rating
            self.checkboxBool = (self.MARKers.last?.userData as! markerUserData).checkbox
            self.tagsMarker = (self.MARKers.last?.userData as! markerUserData).tags
        //    self.websiteLabel.text = (self.MARKers.last?.userData as! markerUserData).websiteUserData
        print((self.MARKers.last?.userData as! markerUserData).websiteUserData)
            self.markerPlacePictureURL = (self.MARKers.last?.userData as! markerUserData).placepicture
            self.tappedMarkerTelephone = (self.MARKers.last?.userData as! markerUserData).telephoneUserData
           
            self.tappedMarkerAddress = (self.MARKers.last?.userData as! markerUserData).addressUserData
         
            
            self.getImage(imageName:(self.MARKers.last?.userData as! markerUserData).firebaseKey)
      
            self.detailsPopUp.layer.borderWidth = 2
            self.detailsPopUp.layer.borderColor = UIColor.darkGray.cgColor
            self.vwGMap.addSubview(self.detailsPopUp)
        }
     /*
       let beforeFirebase = STOREDPlaces.count
    
        let ref = Database.database().reference().child((user?.uid)!).child("StoredPlaces")
        
        ref.observe( .childAdded, with: { (snapshot) in
          //  STOREDPlaces.removeAll()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
               let key = snapshot.key
              //  for snap in snapshots {
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                    //    let key = snap.key
                   //     self.firebaseKey = key
                        var PLACE = (dictionary as? [String: AnyObject]!)!
                        PLACE?.updateValue(key as AnyObject, forKey: "firebaseKey")
                        STOREDPlaces.append(PLACE!)
                        self.filterPlaces()
                    }
                }
                
            }
    //    }
        )
 */
      /*
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.filterPlaces()
            print("after firebase")
            print(STOREDPlaces.count)
            self.afterfirebase = STOREDPlaces.count
           
            if beforeFirebase == self.afterfirebase {
                print("before and after are equal")
                post.updateValue("" as AnyObject, forKey: "firebaseKey")
                STOREDPlaces.append(post)
                self.filterPlaces()
            } else {
                print("before and after firebase not equal")
                
            }
   
       
        }
    */
    }

    //This is the cancel button in when a user is asked to add a new place
    @IBAction func CancelAddNewPlace(_ sender: Any) {
        mapCustomInfoWindow.removeFromSuperview()
        dropDownMenuFolder.removeFromSuperview()
        detailsPopUp.removeFromSuperview()
    }
    
    @IBAction func detailCloseAction(_ sender: Any) {
     //   self.filterSelected = "All"
       // filterPlaces()
     detailsPopUp.removeFromSuperview()
    }
    
    @IBAction func detailMoreDetailAction(_ sender: Any) {
      print("more detail button is being tapped")
    }
    func userDidEnterInformation(info: String) {
        print(info)
        tagsMarker = info
    }
    func userDidChangePhoto(info2: UIImage) {
    }
    func userDidChangeRating(info3: Int) {
       selectedPlace.updateValue(info3 as AnyObject, forKey: "Rating")
        ratingControl.rating = info3
        print(info3)
        updaterating = info3
    }
    func userDidChangeCheckbox(info4: Bool) {
        selectedPlace.updateValue(info4 as AnyObject, forKey: "Checkbox")
        checkboxBool = info4
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let controller = segue.destination as! ThirdViewController
//       controller.transitioningDelegate = self as! UIViewControllerTransitioningDelegate
//        controller.modalPresentationStyle = .custom
     //   controller.delegate = self
      //  let drinks = STOREDPlaces.map({$0["Tags"]})
    
       
        var markerDict = ["StoredPlaceName": detailsName.text, "Rating": ratingControl.rating, "firebaseKey" : firebaseKey, "Checkbox" : checkboxBool, "Tags" : tagsMarker, "StoredPlacePicture" : markerPlacePictureURL, "StoredPlaceAddress" : tappedMarkerAddress,  "StoredPlaceTelephone": tappedMarkerTelephone] as [String : Any]
        //"StoredPlaceWebsite": websiteLabel.text,
       selectedPlace = markerDict as [String : AnyObject]
    //   ratingControl.selectedPlaceDetail = markerDict as [String : AnyObject]
 
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = moreDetailButton.center
        transition.bubbleColor = moreDetailButton.backgroundColor!
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = moreDetailButton.center
        if updaterating != ratingControlRating {
            print("no match")
        } else {
            print("match")
        }
        //self.view.addSubview(detailsPopUp)
   
        transition.bubbleColor = moreDetailButton.backgroundColor!
        return transition
    }
    
    @IBAction func websiteButtonAction(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: tappedMarkerWebsite)! as URL)
    }
    
    @IBAction func telephoneButtonAction(_ sender: Any) {
      //  let phoneCallURL = URL(string: "tel://\(tappedMarkerTelephone)")
          //  UIApplication.shared.openURL(phoneCallURL!)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
    }
    
    func fetchFolder() {
        
        let ref = Database.database().reference().child((user?.uid)!).child("UserFolders")
        ref.observe( .value, with: { (snapshot) in
            var rmIndices = [Int]()
            //            if let index = self.allFilters.index(where: { $0.type == "folder" }) {
            //                self.allFilters.remove(at: index)
            //                //continue do: arrPickerData.append(...)
            //            }
            //
            var count = self.allFilters.count
            if self.allFilters.count > 0 {
                for index in 0...(self.allFilters.count-1) {
                    
                    if self.allFilters[index].type == "folder" {
                        rmIndices.append(index)
                    }
                }
                self.allFilters = self.allFilters.enumerated().flatMap {rmIndices.contains($0.0) ? nil : $0.1}
            }
            var allFolders = [FILTER]()
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let key = snap.key
                        //print(key)
                        let folder = FILTER()
                        folder.name = (dictionary[key]?["FolderName"] as? String)!
                        folder.icon = (dictionary[key]?["FolderIcon"] as? String)!
                        folder.key = key
                        folder.type = "folder"
                        // print(dictionary)
                        //folder.name = dictionary["Username"] as? String
                        print(folder.name!)
                        
                        allFolders.append(folder)
                        
                    }
                }
                self.allFilters = allFolders + self.allFilters
                // if self.folders.contains(folder) {
                // print("YES")
                //}
                DispatchQueue.main.async {
                    self.friendSlider.reloadData()
                    print("This should print at the end of completed task ")
                    
                }
            }
        }
        )
        
    }
    
    func fetchFriends() {
        let ref = Database.database().reference()
        ref.child((self.user?.uid)!).child("Friends").observe( .value, with: { (snapshot) in
            var rmIndices = [Int]()
            if self.allFilters.count > 0 {
                for index in 0...(self.allFilters.count-1) {
                    
                    if self.allFilters[index].type == "friend" {
                        rmIndices.append(index)
                    }
                }
                self.allFilters = self.allFilters.enumerated().flatMap {rmIndices.contains($0.0) ? nil : $0.1}
            }
            var friends = [FILTER]()
            allFriends.removeAll()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let friend = USER()
                        friend.snapshotKey = snap.key
                        let key = snap.key
                        friend.AuthFirebaseKey = (dictionary[key]?["Friend"] as? String)
                        friend.Username = (dictionary[key]?["FriendUsername"] as? String)
                        
                        let friendFilter = FILTER()
                        friendFilter.path = (dictionary[key]?["Friend"] as? String)
                        friendFilter.name = (dictionary[key]?["FriendUsername"] as? String)
                        friendFilter.type = "friend"
                        friends.append(friendFilter)
                        
                        //["Friend"]
                        
                        allFriends.append(friend)
                        // let friend = (dictionary[key] as? [String: AnyObject]!)!
                        print("this is the firebase all friends func\(allFriends.count)")
                        // snapKeys.append(key)
                        // friends.updateValue(key as AnyObject, forKey: "firebaseKey")
                        
                    }
                    
                    
                }
                self.allFilters = self.allFilters + friends
                DispatchQueue.main.async {
                    self.friendSlider.reloadData()
                    print("This should print at the end of completed task ")
                    
                }
                
                if allFriends.count > 0 {
                    print("this is AFTER all friends has been populated\(allFriends.count)")
                    for friend in allFriends {
                        let ref = Database.database().reference().child(friend.AuthFirebaseKey!).child("StoredPlaces")
                        ref.observe( .value, with: { (snapshot) in
                            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                // print(snapshot)
                                for snap in snapshots {
                                    if let dictionary = snapshot.value as? [String: AnyObject] {
                                        let key = snap.key
                                        
                                        friend.StoredPlacesOfUser = (dictionary[key] as? [String: AnyObject]!)!
                                        print(friend.StoredPlacesOfUser)
                                    }
                                }
                            }
                        })
                    }
                }
                
            }
        }
        )
        
    }
    

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return allFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filter = allFilters[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
      
          cell.friendProfileImageFromMap.image = UIImage(named: "funProfileIcon")
        if filter.type == "folder" {
            cell.friendProfileImageFromMap.image = UIImage(named: filter.icon!)
        } else {
            let fileManager = FileManager.default
            
            let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(filter.path!)
            print(imagePath)
            if fileManager.fileExists(atPath: imagePath){
                cell.friendProfileImageFromMap.image = UIImage(contentsOfFile: imagePath)
                print("I have uploaded image from internal database")
            }else{
                print("Panic! No Image!")
                cell.friendProfileImageFromMap.image = UIImage(named: "funProfileIcon")
            }

            
        }
  
        
     
       // cell.friendProfileImageFromMap.image = UIImage(named: "funProfileIcon")
        cell.nameForLabelMap.text = filter.name
        return cell

    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //print("THIS IS CLICKING ON THE CELL ")
        /*
        let selectedFilter = allFilters[indexPath.row]
        if selectedFilter.type == "folder" {
            let firstViewController:
                FirstViewController = self.storyboard!.instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
            firstViewController.filterSelected = selectedFilter.name!
            firstViewController.filterPlaces()
         
            //firstViewController.vwGMap.addSubview(firstViewController.detailsPopUp)
        } else {
            
        }
        */
        
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("size if cell called ")
        var size = CGSize(width: 80, height: 80)
        
        return size
    }
    
    

}

