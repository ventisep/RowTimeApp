//
//  CrewDataGetter.swift
//  RowTime
//
//  Created by Paul Ventisei on 07/06/2016.
//  Copyright © 2016 Paul Ventisei. All rights reserved.
//

import Foundation
import Firebase


class CrewData: NSObject {
    
    let FirestoreDb = Firestore.firestore();
    var crews: [Crew] = []
    var delegate: UpdateableFromFirestoreListener? = nil

    private var eventId: String = ""
    private var eventRef: DocumentReference?
    private var lastTimestamp: Date = Date(timeIntervalSince1970: 0)//first time set to old date to get everything

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var crewListener: ListenerRegistration?
    private var timeListener: ListenerRegistration?

    
    
    func setEventListener(newEventId: String, eventRef: DocumentReference) {
        
        //set the eventId to the newEventId and then process an update of the model
        
        eventId = newEventId
        self.eventRef = eventRef

        // read all the crews for the selected event from Firebase and set a listener
        
        refreshCrews()
        refreshTimes()
    
    }
    
    func stopListening() { //function called to stop any listener before the crewData object goes out of scope
        if crewListener != nil {crewListener!.remove()}
        if timeListener != nil {timeListener!.remove()}
        
    }
    
    //PV: a method for loading Crews and setting a listener for chages to the crews
    
    func refreshCrews() {
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
 
    //PV: a method for loading Times and setting a listener for changes to the times
    // however this may not be needed as I could create a function that updates the crews and the crews listener would pick up the change in the start or end time which is really all we need
    
    func refreshTimes() {
        // now we have the crews we can get the times
        delegate?.willUpdateModel()
        
        timeListener = FirestoreDb.collection("Times").whereField("eventId", isEqualTo: eventId).order(by: "time").addSnapshotListener { snapshot, error in
            self.delegate?.willUpdateModel() //tell the delegate that the model is about to be updated
            var newItems: [RecordedTime] = []
            guard let snapshot = snapshot else {  //Optional assignment
                print("Error fetching Times: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                let timesnapshot = RecordedTime(fromServerRecordedTime: diff.document)
                if (diff.type == .added) {
                    newItems.append(timesnapshot)
                    print("time added data: \(timesnapshot))")
                }
                if (diff.type == .modified) { // this happens when the time comes back from the server after being written to the cache - there is nothing to do here but would be a good place to update a recording status of the time
                    print("time came back from the server: \(String(describing: timesnapshot))")
                }
                if (diff.type == .removed) { // this never happens
                    print("time removed data diff: \(String(describing: timesnapshot))")
                }
            }
            self.processTimes(newItems, crews: self.crews)
            self.delegate?.didUpdateModel()
        }
    }

    func processTimes(_ times: [RecordedTime], crews: [Crew]) {
        
        for time in times {
            
            // find the crewnumber that matches time.crewNumber and process the time
            
            for crew in crews where crew.crewNumber == time.crewNumber {
                crew.processTime(time)
                lastTimestamp = time.time
                
            }
        }
    }
 
}

