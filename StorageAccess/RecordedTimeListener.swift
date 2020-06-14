//
//  CrewDataGetter.swift
//  RowTime
//
//  Created by Paul Ventisei on 07/06/2016.
//  Copyright © 2016 Paul Ventisei. All rights reserved.
//

import Foundation
import Firebase


class RecordedTimeListener: NSObject {
    
    let FirestoreDb = Firestore.firestore();
    var times: [RecordedTime] = []
    var newTimes: [RecordedTime] = []
    var delegate: UpdateableFromFirestoreListener? = nil

    private var eventId: String = ""
    private var lastTimestamp: Date = Date(timeIntervalSince1970: 0)//first time set to old date to get everything

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var timeListener: ListenerRegistration?

    
    
    func setTimeListener(forEventId: String) {
        
        //set the eventId to the newEventId and then process an update of the model
        
        eventId = forEventId

        // read all the times for the selected event from Firebase and set a listener
        newTimes = [] // clear down the new times
        refreshTimes()
    
    }
    
    func stopListening() { //function called to stop any listener before the crewData object goes out of scope
        if timeListener != nil {timeListener!.remove()}
        
    }
    

     //PV: a method for loading Times and setting a listener for changes to the times
    
    private func refreshTimes() {
        // now we have the crews we can get the times
        delegate?.willUpdateModel()
        timeListener = FirestoreDb.collection("Events").document(eventId).collection("Times").order(by: "time").addSnapshotListener { snapshot, error in

            self.delegate?.willUpdateModel() //tell the delegate that the model is about to be updated
            self.newTimes = [] //clear old times
            guard let snapshot = snapshot else {  //Optional assignment
                print("Error fetching Times: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                let timesnapshot = RecordedTime(fromServerRecordedTime: diff.document)
                if (diff.type == .added) {
                    self.newTimes.append(timesnapshot)
                    print("time added data: \(timesnapshot))")
                    self.lastTimestamp = timesnapshot.time
                }
                if (diff.type == .modified) { // this happens when the time comes back from the server after being written to the cache - there is nothing to do here but would be a good place to update a recording status of the time
                    print("time came back from the server: \(String(describing: timesnapshot))")
                }
                if (diff.type == .removed) { // this happens when there is an error writing the time to the database. set the ObsType to 1
                    timesnapshot.obsType = 1
                    self.newTimes.append(timesnapshot)
                    print("time removed data diff: \(String(describing: timesnapshot))")
                }
            }
            self.delegate?.didUpdateModel()
        }
    }
 
}

