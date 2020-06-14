//
//  TestCrewListener.swift
//  RowTime
//
//  Created by Paul Ventisei on 09/06/2020.
//  Copyright © 2020 Paul Ventisei. All rights reserved.
//

import Foundation
import Firebase
import Combine


@available(iOS 13.0, *)
class CrewListener: NSObject, ObservableObject, UpdateableFromFirestoreListener{

    let FirestoreDb = Firestore.firestore();
        
    @Published var crewlist: [Crew] = []
    
    var delegate: UpdateableFromFirestoreListener?
    var timeData = RecordedTimeListener()

    private var eventId: String = ""
    private var eventRef: DocumentReference?

    //private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var crewListener: ListenerRegistration?
    
    override init() {
        super.init()
    }
    
    init(crews: [Crew]) {
        crewlist = crews
    }
    
    func setCrewListener(forEventId: String) {
        
        //set the eventId to the newEventId and then process an update of the model
        if crewListener == nil {
            eventId = forEventId

            // 1. read all the crews for the selected event from Firebase and set a listener.
            // 2. set this object as the delegate for TimeData service which will be called when the crews have been recieved.

            timeData.delegate = self
            refreshCrews()
            timeData.setTimeListener(forEventId: eventId)
        }
    
    }
    
    func stopListening() { //function called to stop any listener before the crewData object goes out of scope
        if crewListener != nil {crewListener!.remove()}
        timeData.stopListening()
    }
    
    //PV: a private method for loading Crews and setting a listener for changes to the crews - cannot be called outside the object as it sets the listener and multiple listeners would be started if it were called more than once
    
    private func refreshCrews() {
        crewListener = FirestoreDb.collection("Events").document(eventId).collection("Crews").order(by: "crewNumber").addSnapshotListener { snapshot, error in

            guard let snapshot = snapshot else {  //Optional assignment
                print("Error fetching Crews: \(error!)")
                return
            }
            for data in snapshot.documentChanges {
                    if (data.type == .added) {
                        let newCrew = Crew(fromServerCrew: data.document, eventId: self.eventId)
                        self.crewlist.insert(newCrew, at: Int(data.newIndex))
                        print("Firestore crew data added: \(String(describing: newCrew))")
                    }
                    if (data.type == .modified) {
                        // find the entry in the crewlist that has the old index and replace it
                        // with this new crew data.
                        // then move the index location if it is different
                    self.crewlist[Int(data.oldIndex)].updateCrewFromServer(fromServerCrew: data.document)
                        if data.oldIndex != data.newIndex {
                            let updatedCrew = self.crewlist.remove(at: Int(data.oldIndex))
                            self.crewlist.insert(updatedCrew, at: Int(data.newIndex))
                            
                        }

                        print("Firestore crew data updated: \( self.crewlist[Int(data.oldIndex)])")

                    }
                    if (data.type == .removed) {
                        self.crewlist.remove(at: Int(data.oldIndex))
                    //todo

                    }

                }
            self.objectWillChange.send()
            self.delegate?.didUpdateModel()
            }
        }

    
    // These are the protocols as a firebaseListenerDelegate
    func willUpdateModel() {
        //tell our own delegate that the model is about to update
        self.objectWillChange.send()
    }
 
    func didUpdateModel() { //called when the times model is updated as this is the delegate for managing reading times
        
        self.processTimes(timeData.newTimes, crews: self.crewlist)
        self.objectWillChange.send()

        
    }

    func processTimes(_ times: [RecordedTime], crews: [Crew]) {
        
        for time in times {
            
            // find the crewnumber that matches time.crewRef and process the time
            
            for crew in crews where crew.crewRef == time.crewRef {
                crew.processTime(time)
                
            }
        }
    }
    

 
}

