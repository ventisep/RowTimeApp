//
//  StartViewController.swift
//  RowTime
//
//  Created by Paul Ventisei on 06/08/2019.
//  Copyright © 2019 Paul Ventisei. All rights reserved.
//

import UIKit
import Firebase

@available(iOS 13.0, *)
class StartViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var eventCode: UITextField!
    @IBOutlet weak var searchResults: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func eventEntered(_ sender: UITextField) {
        //check that the event code exists
        let searchEvent = eventCode.text
        //nowsearch for the eventCode and if exists then allow the seque.  If not there report an error and stop the segue
        
        
        let FirestoreDb = Firestore.firestore();
        FirestoreDb.collection("Events").whereField("eventId", isEqualTo: searchEvent!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Document not able to be retrieved: \(err)")
                self.searchResults.text = "Error Accessing the Database"
                
            } else {
                if querySnapshot!.documents.count > 0 {
                    for document in querySnapshot!.documents {
                        let dataDescription: [String] = document.data().map(String.init(describing:))
                        print("Document data: \(dataDescription)")
                        let event = Event(fromServerEvent: document)
                        self.performSegue(withIdentifier: "noLoginToNavigation", sender: event)
                    }
                } else {
                    self.searchResults.text = "No Event with that Code"
                }
            }
        }

    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noLoginToNavigation" {
            // pass the selected event code to the view controller
            if let destinationVC = segue.destination as? UINavigationController {
                let rootVC = destinationVC.children[0] as! CrewTableViewController
                rootVC.event = sender as? Event
            }
        }
    }
    
    @IBAction func unwindToStartView(_ unwindSegue: UIStoryboardSegue) {
        unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

}
