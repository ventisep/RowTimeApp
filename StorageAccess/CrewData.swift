//
//  CrewDataGetter.swift
//  RowTime
//
//  Created by Paul Ventisei on 07/06/2016.
//  Copyright © 2016 Paul Ventisei. All rights reserved.
//

import Foundation
import Firebase


class CrewData: NSObject, UpdateableFromFirestoreListener{


    
    
    let FirestoreDb = Firestore.firestore();
    var crews: [Crew] = []
    var timeData = TimeData()
    var delegate: UpdateableFromFirestoreListener? = nil

    private var eventId: String = ""
    private var eventRef: DocumentReference?

    //private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var crewListener: ListenerRegistration?
    
    func setCrewListener(forEventId: String, eventRef: DocumentReference) {
        
        //set the eventId to the newEventId and then process an update of the model
        
        eventId = forEventId
        self.eventRef = eventRef

        // 1. read all the crews for the selected event from Firebase and set a listener.
        // 2. set this object as the delegate for TimeData service which will be called when the crews have been recieved.

        timeData.delegate = self
        refreshCrews()
        timeData.setTimeListener(forEventId: eventId, eventRef: eventRef)
    
    }
    
    func stopListening() { //function called to stop any listener before the crewData object goes out of scope
        if crewListener != nil {crewListener!.remove()}
        timeData.stopListening()
    }
    
    //PV: a private method for loading Crews and setting a listener for chages to the crews - cannot be called outside the object as it sets the listener and multip[le listeners would be started if it were called more than once
    
    private func refreshCrews() {
        crewListener = FirestoreDb.collection("Events").document(eventId).collection("Crews").order(by: "crewNumber").addSnapshotListener { snapshot, error in

            guard let snapshot = snapshot else {  //Optional assignment
                print("Error fetching Crews: \(error!)")
                return
            }
            self.delegate?.willUpdateModel() //tell the delegate that the model is about to be updated
            for data in snapshot.documents {
                let newCrew = Crew(fromServerCrew: data, eventId: self.eventId, eventRef: self.eventRef!)
                if self.crews.count == 0 { //first crew found
                    self.crews.append(newCrew)
                    
                } else { // check if we are updating or adding
                    for oldCrew in self.crews {
                        var nomatch = true
                        if oldCrew.crewId == newCrew.crewId {
                            oldCrew.updateCrewFromServer(fromServerCrew: data)
                            nomatch = false
                        }
                        if nomatch { //new crew to be added to list
                            self.crews.append(newCrew)
                        }
                    print("Firestore crew data: \(String(describing: newCrew))")
                    }
                }
            self.delegate?.didUpdateModel()
            }
        }
    }
    
    // These are the protocols as a firebaseListenerDelegate
    func willUpdateModel() {
        //tell our own delegate that the model is about to update
        delegate?.willUpdateModel()
    }
 
    func didUpdateModel() { //called when the times model is updated as this is the delegate for managing reading times
        
        self.processTimes(timeData.newTimes, crews: self.crews)
        delegate?.didUpdateModel() //tell our own delegate that the model updated

        
    }

    func processTimes(_ times: [RecordedTime], crews: [Crew]) {
        
        for time in times {
            
            // find the crewnumber that matches time.crewNumber and process the time
            
            for crew in crews where crew.crewNumber == time.crewNumber {
                crew.processTime(time)
                
            }
        }
    }
 
}

