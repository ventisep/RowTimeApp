//
//  EventData.swift
//  RowTime
//
//  This object provides gets a the list of events and sets up a listener for changes to the Firestore database and chaches that hold the data.
//
//  It uses the protocol and delegate design approach to provide communication on update events to the delegate
//
//  Created by Paul Ventisei on 06/06/2016.
//  Copyright © 2016 Paul Ventisei. All rights reserved.

import Foundation
import Firebase


protocol UpdateableFromFirestoreListener {
    func didUpdateModel()
    func willUpdateModel()
}

class EventData: NSObject {
    
    var events = [Event]()
    let FirestoreDb = Firestore.firestore();
    var delegate : UpdateableFromFirestoreListener? = nil
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var eventListener: ListenerRegistration?

    func stopListening() { //function called to stop any listener before the eventData object goes out of scope
        if eventListener != nil {eventListener!.remove()}
        
    }
    func loadEvents() {
        //PV: a method for loading Events from FireStore for the Events Collection
        // and add a listener to the firestore database
        FirestoreDb.collection("Events").order(by: "eventDate").addSnapshotListener { snapshot, error in
            self.delegate?.willUpdateModel() //tell the delegate that the model is about to be updated
            var newItems: [Event] = []
                guard let snapshot = snapshot else {  //Optional assignment
                    print("Error fetching Events: \(error!)")
                    self.delegate?.didUpdateModel()
                    return
                }
                for data in snapshot.documents {
                    let event = Event(fromServerEvent: data)
                    newItems.append(event)
                    print("Firestore data: \(String(describing: event))")
                }
                self.events = newItems
                self.delegate?.didUpdateModel()
        }
        
    }
    
}
