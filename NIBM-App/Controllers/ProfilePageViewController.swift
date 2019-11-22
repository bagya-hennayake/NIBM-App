//
//  ProfilePageViewController.swift
//  NIBM-App
//
//  Created by Bagya Hennayake on 11/11/19.
//  Copyright © 2019 Bagya Hennayake. All rights reserved.
//

import UIKit
import  FirebaseStorage
import FirebaseDatabase
import  SwiftyJSON
import Kingfisher

class ProfilePageViewController: UIViewController {
     var imagePicker: ImagePicker!
   
    @IBOutlet weak var Profile_img: UIImageView!
    
    @IBOutlet weak var FisrtName_txt: UITextField!
    @IBOutlet weak var LastName_txt: UITextField!
    @IBOutlet weak var DoB_dateP: UIDatePicker!
    @IBOutlet weak var IndexId_txt: UITextField!
    @IBOutlet weak var PhoneNum_txt: UITextField!
    @IBAction func datePickerChanged(sender: UIDatePicker) {

    }
    @IBAction func Add_img(_ sender: UIButton) {
     self.imagePicker.present(from: sender)
    }
    

        
    @IBAction func Update_btn(_ sender: Any) {
    
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
     
        
        
        guard let FName = FisrtName_txt.text, !FName.isEmpty else {
            alert.dismiss(animated: false, completion: nil)
            showAlert(message: "First Name cannot be empty")
            return
        }
        
        guard let LName = LastName_txt.text, !LName.isEmpty else {
            alert.dismiss(animated: false, completion: nil)
            showAlert(message: "Last Name cannot be empty")
            return
        }
        
        guard let PhoneNumber = PhoneNum_txt.text, !PhoneNumber.isEmpty else {
            alert.dismiss(animated: false, completion: nil)
            showAlert(message: "Number cannot be empty")
            return
        }
        guard let IndexID = IndexId_txt.text, !IndexID.isEmpty else {
                   alert.dismiss(animated: false, completion: nil)
                   showAlert(message: "Number cannot be empty")
                   return
               }
      func getFormattedDate(DoB_dateP: Date, format: String) -> String {
                let dateformat = DateFormatter()
                dateformat.dateFormat = format
                return dateformat.string(from: DoB_dateP)
        }

        let formatingDate = getFormattedDate(DoB_dateP: Date(), format: "dd-MMM-yyyy")
                print(formatingDate)
        
        
        let loggedUserUid = UserDefaults.standard.string(forKey: "UserUID")
        let loggedUserEmail = UserDefaults.standard.string(forKey: "LoggedUser")
        
        guard let image = Profile_img.image,
            let imgData = image.jpegData(compressionQuality: 1.0) else {
                alert.dismiss(animated: false, completion: nil)
                showAlert(message: "An Image must be selected")
                return
        }
        
        let imageName = UUID().uuidString
        
        let reference = Storage.storage().reference().child("profileImages").child(imageName)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        
        
        reference.putData(imgData, metadata: metaData) { (meta, err) in
            if let err = err {
                alert.dismiss(animated: false, completion: nil)
                self.showAlert(message: "Error uploading image: \(err.localizedDescription)")
                return
            }
            
            reference.downloadURL { (url, err) in
                if let err = err {
                    alert.dismiss(animated: false, completion: nil)
                    self.showAlert(message: "Error fetching url: \(err.localizedDescription)")
                    return
                }
                
                guard let url = url else {
                    alert.dismiss(animated: false, completion: nil)
                    self.showAlert(message: "Error getting url")
                    return
                }
                
                let imgUrl = url.absoluteString
                
              
                let dbChildName = UUID().uuidString
                
                
                let dbRef = Database.database().reference().child("profiles").child(loggedUserUid!)
                
                
                let data = [
                    "First_Name" : FName,
                    "Last_Name" : LName,
                    "profileImageUrl" : imgUrl,
                    //"userAvatarImageUrl" : self.avatarImageUrl
                    "DOB" : formatingDate,
                    "Index_ID":IndexID,
                    "Phone_Number" : PhoneNumber,
                    "Email" : loggedUserEmail
                    
                    ] as [String : Any]
                
                dbRef.setValue(data, withCompletionBlock: { ( err , dbRef) in
                    if let err = err {
                        self.showAlert(message: "Error uploading data: \(err.localizedDescription)")
                        return
                    }
                    alert.dismiss(animated: false, completion: nil)
                    self.showAlert(message: "Successfully Updated")
                    
                })
                
            }
            
        }}
    
    

   

    
    
    override func viewDidLoad() {
        
       
              super.viewDidLoad()
        self.Profile_img.layer.cornerRadius = self.Profile_img.bounds.height / 2
        self.Profile_img.clipsToBounds = true
        
   
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
       
        
        let loggedUserUid = UserDefaults.standard.string(forKey: "UserUID")
        let ref = Database.database().reference().child("profiles").child(loggedUserUid!)
        ref.observe(.value, with: { snapshot in
            
            let dict = snapshot.value as? [String: AnyObject]
            let json = JSON(dict as Any)
            
            let imageURL = URL(string: json["profileImageUrl"].stringValue)
            self.Profile_img.kf.setImage(with: imageURL)
            
            self.FisrtName_txt.text = json["First_Name"].stringValue
            self.LastName_txt.text = json["Last_Name"].stringValue
            self.IndexId_txt.text = json["Index_ID"].stringValue
           // self.DoB_dateP. = json["DOB"].date
            self.PhoneNum_txt.text = json["Phone_Number"].stringValue
            
            
        })
        // Do any additional setup after loading the view.
    }
    func showAlert(message:String)
    {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
  
}

            extension ProfilePageViewController: ImagePickerDelegate {
                
                func didSelect(image: UIImage?) {
                    self.Profile_img.image = image
                }
}


