//
//  EventViewController.swift
//  RowTime
//
//  Created by Paul Ventisei on 18/08/2019.
//  Copyright © 2019 Paul Ventisei. All rights reserved.
//

import UIKit
import Firebase

class EventViewController: UIViewController {

    //Mark: Properties
    
    
    @IBOutlet weak var eventID: UITextField!
    @IBOutlet weak var eventDescription: UITextField!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventDate: UIDatePicker!
    //eventImage uses an ImagePicker class to help get images from the user
    @IBOutlet weak var eventImage: UIImageView!
    var imagePicker: ImagePicker!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let user = Auth.auth().currentUser
    let FirestoreDb = Firestore.firestore();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up the ImagePicker setting this controller as the delegate
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        // Do any additional setup after loading the view.
    }

    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if saveButton == sender as? UIBarButtonItem {
            print("segue after pressing the save button")
            let eventImageFileName = "holdingtext.jpg"
            //need to create and upload file reference here
            let event = Event(eventId: eventID.text!, eventDate: eventDate.date.description, eventName: eventName.text!, eventImageName:
                eventImageFileName, eventImage: eventImage, eventDesc: eventDescription.text!)
            event?.writeToFirestore(eventId: eventID.text!, inDatabase: FirestoreDb)
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

extension EventViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.eventImage.image = image
    }
}
