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
    
    enum Status {
        case empty, noLocalData, updatingCrewsFromRemoteServer, usingLocalData, usingRemoteData
    }
    let FirestoreDb = Firestore.firestore();
    var status: Status = .empty
    var crews: [Crew] = []
    var delegate: UpdateableFromModel? = nil

    private var eventId: String = ""
    private var lastTimestamp: Date = Date(timeIntervalSince1970: 0)//first time set to old date to get everything

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    
    func setEvent(newEventId: String) {
        
        //set the eventId to the newEventId and then process an update of the model
        
        eventId = newEventId
        
        // read all the crews for the selected event from Firebase
        
        refreshCrews()
    
    }
    
    //PV: a method for loading Crews and setting a listener for chages to the crews
    
    func refreshCrews() {
        FirestoreDb.collection("Events").document(eventId).collection("Crews").order(by: "crewNumber").addSnapshotListener { snapshot, error in
            self.delegate?.willUpdateModel() //tell the delegate that the model is about to be updated
            self.status = .updatingCrewsFromRemoteServer
            var newItems: [Crew] = []
            guard let snapshot = snapshot else {  //Optional assignment
                print("Error fetching Crews: \(error!)")
                return
            }
            for data in snapshot.documents {
                let crew = Crew(fromServerCrew: data, eventId: self.eventId)
                newItems.append(crew)
                // print("Firestore data: \(String(describing: event))")
            }
            self.crews = newItems
            self.status = .usingRemoteData
            self.delegate?.didUpdateModel()
        }

    }
 
    //PV: a method for loading Times and setting a listener for changes to the times
    // however this may not be needed as I could create a function that updates the crews and the crews listener would pick up the change in the start or end time which is really all we need
    
    func refreshTimes() {
        // now we have the crews we can get the times
        delegate?.willUpdateModel()
        
        FirestoreDb.collection("Times").whereField("eventId", isEqualTo: eventId)
            .whereField("time", isGreaterThan: lastTimestamp).order(by: "time").addSnapshotListener { snapshot, error in
            self.delegate?.willUpdateModel() //tell the delegate that the model is about to be updated
            self.status = .updatingCrewsFromRemoteServer
            var newItems: [RecordedTime] = []
            guard let snapshot = snapshot else {  //Optional assignment
                print("Error fetching Crews: \(error!)")
                return
            }
            for data in snapshot.documents {
                let timesnapshot = RecordedTime(fromServerRecordedTime: data)
                newItems.append(timesnapshot)
                // print("Firestore data: \(String(describing: event))")
            }
            self.processTimes(newItems, crews: self.crews)
            self.status = .usingRemoteData
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

