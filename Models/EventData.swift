//
//  EventData.swift
//  RowTime
//
//  This object provides a list of events either from the call to the server or 
//  from a previously saved list.  Note this also loads the data into the tableview object
//  of the viewcontroller passed to the loadEvents method. 
//
//  TODO: Update to use CoreData instead of the UserData subsystem
//
//  Created by Paul Ventisei on 06/06/2016.
//  Copyright © 2016 Paul Ventisei. All rights reserved.
// - forcing a change

import Foundation
import Firebase


protocol UpdateableFromModel {
    func didUpdateModel()
    func willUpdateModel()
}

class EventData: NSObject {
    
    var events = [Event]()
    var status: Status? = nil
    enum Status {
        case empty, noLocalData, updatingEventsFromRemoteServer, usingLocalData, usingRemoteData
    }
    let FirestoreDb = Firestore.firestore();
    var delegate : UpdateableFromModel? = nil
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func loadEvents() {
        //PV: a method for loading Events from FireStore for the Events Collection
        // add a listener to the firestore database
        FirestoreDb.collection("Events").order(by: "eventDate").addSnapshotListener { snapshot, error in
            self.delegate?.willUpdateModel() //tell the delegate that the model is about to be updated
            self.status = .updatingEventsFromRemoteServer
            var newItems: [Event] = []
                guard let snapshot = snapshot else {  //Optional assignment
                    print("Error fetching Events: \(error!)")
                    return
                }
                for data in snapshot.documents {
                    let event = Event(fromServerEvent: data)
                    newItems.append(event)
                    // print("Firestore data: \(String(describing: event))")
                }
                self.events = newItems
                self.status = .usingRemoteData
                self.delegate?.didUpdateModel()
        }
        
    }
    
}
