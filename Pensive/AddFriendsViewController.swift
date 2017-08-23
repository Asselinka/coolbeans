//
//  AddFriendsViewController.swift
//  Pensive
//
//  Created by Assel Kashkenbayeva on 13/08/2017.
//  Copyright © 2017 Assel Kashkenbayeva. All rights reserved.
//
/*
import UIKit
import Firebase
 var allUsers = [USER]()
var snapKeys = [String]()

class AddFriendsViewController: UIViewController
UITableViewDelegate, UITableViewDataSource {
/*
    @IBOutlet var addFriendsTableView: UITableView!
  //  var allUsers = [USER]()
    var friends = [String]()
     let user = Auth.auth().currentUser
    override func viewDidLoad() {
        super.viewDidLoad()

        addFriendsTableView.delegate = self
        addFriendsTableView.dataSource = self
    //    fetchUser()
        fetchFriends()
    }
/*
    func fetchUser() {
        let ref = Database.database().reference()
        ref.observe( .childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                 let User = USER()
            User.AuthFirebaseKey = snapshot.key
                print(User.AuthFirebaseKey)
                 User.Username = dictionary["Username"]?["Username"] as? String
                 User.ProfilePicURL = dictionary["ProfilePicURL"]?["ProfilePicURL"] as? String
                /*
                if (dictionary["Friends"] != nil) {
                User.Friends = (dictionary["Friends"] as? [String:AnyObject])!
                    print(User.Friends)
                }
 */
                 allUsers.append(User)
                   self.saveImage(imageName: User.AuthFirebaseKey!, URL: User.ProfilePicURL)
                DispatchQueue.main.async {
                    self.addFriendsTableView.reloadData()
                }
            }
        }
        )}
*/
    func saveImage(imageName: String, URL: String){
    
    if let profileImageURL = URL {
        let url = URL(string: profileImageURL)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                print("THIS IS GOING TO BE A PIC")
                cell.friendProfileImage.image = UIImage(data: data!)
            }
        }).resume()
    }
    print("The save image function is being called")
    //create an instance of the FileManager
    let fileManager = FileManager.default
    //get the image path
    let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
    
    //get the image we took with camera
    let image = addPicture.image!
    //get the PNG data for this image
    let data = UIImagePNGRepresentation(image)
    //store it in the document directory
    fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
}

    func fetchFriends() {
        let ref = Database.database().reference()
       
        ref.child((self.user?.uid)!).child("Friends").observe( .value, with: { (snapshot) in
            self.friends.removeAll()

            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let key = snap.key
                        let friend = (dictionary[key] as? [String: AnyObject]!)!["Friend"]
                        self.friends.append(friend! as! String)
                       snapKeys.append(key)
            
                    }
                }
            }
        }
    )
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
                 print(self.friends)
            }
        print(friends)
    }
           /*
                if (dictionary["Friends"] != nil) {
                    allUsers.Friends = (dictionary["Friends"] as? [String:AnyObject])!
                    print(allUsers.Friends)
                }
*/
         

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func imageWithImage(image:UIImage,scaledToSize newSize:CGSize)->UIImage{
        
        UIGraphicsBeginImageContext( newSize )
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.alwaysTemplate)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let User = allUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendsCell", for: indexPath) as! AddFriendsTableViewCell
        cell.friendProfileImage.image = UIImage(named: "ProfileIcon")
       
        cell.friendUserName.text = User.AuthFirebaseKey
        print("THIS IS COMING FROM CELL")
        print(cell.friendUserName.text)
        print(indexPath.row)
        if self.friends.contains(User.AuthFirebaseKey!) {
            cell.checkBoxToFollow.on = true
        }
        else {
            cell.checkBoxToFollow.on = false
        }
        
       print(cell.checkBoxToFollow.on)

        /*
         let user = users[indexPath.row]
         cell.textLabel?.text = user.Username
         cell .detailTextLabel?.text = user.Email
         cell.imageView?.image = imageWithImage(image: UIImage(named: "a")!, scaledToSize: CGSize(width: 40, height: 40))
         if let profileImageURL = user.ProfilePicURL {
         let url = URL(string: profileImageURL)
         URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
         
         if error != nil {
         print(error!)
         return
         }
         
         DispatchQueue.main.async {
         print("THIS IS GOING TO BE A PIC")
         cell.imageView?.image = UIImage(data: data!)
         }
         }).resume()
         }
         
         cell.imageView?.sizeToFit()
         cell.imageView?.layer.borderWidth = 1
         cell.imageView?.layer.masksToBounds = false
         cell.imageView?.layer.borderColor = UIColor.orange.cgColor
         cell.imageView?.layer.cornerRadius = 70
         cell.imageView?.clipsToBounds = true
         cell.imageView?.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
         */
      //  cell.friendProfileImage.image = imageWithImage(image: UIImage(named: "MapIcon")!, scaledToSize: CGSize(width: 40, height: 40))
        
        if let profileImageURL = User.ProfilePicURL {
            let url = URL(string: profileImageURL)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    print("THIS IS GOING TO BE A PIC")
                    cell.friendProfileImage.image = UIImage(data: data!)
                }
            }).resume()
        }
        /*
        cell.friendProfileImage.sizeToFit()
        cell.friendProfileImage.layer.borderWidth = 1
        cell.friendProfileImage.layer.masksToBounds = false
        cell.friendProfileImage.layer.borderColor = UIColor.orange.cgColor
        cell.friendProfileImage.layer.cornerRadius = 70
        cell.friendProfileImage.clipsToBounds = true
        cell.friendProfileImage.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
*/
       
        cell.checkBoxToFollow.tag = indexPath.row
        
       cell.checkBoxToFollow.addTarget(self, action: "didTap:", for: UIControlEvents.touchUpInside)
        print(indexPath.row)
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print(indexPath.row)
    
        /*
         // Segue to the second view controller
         
         let myVC = storyboard?.instantiateViewController(withIdentifier: "ConnectMapViewController") as! ConnectMapViewViewController
         myVC.selectedUser = users[indexPath.row]
         // self.performSegue(withIdentifier: "connectMapView", sender: self)
         navigationController?.pushViewController(myVC, animated: true)
         */
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
*/
}
*/
