//
//  RecordedTime.swift
//  RowTime
//
//  Created by Paul Ventisei on 16/06/2019.
//  Copyright © 2019 Paul Ventisei. All rights reserved.
//

import Foundation
import Firebase

class RecordedTime: NSObject  {
    
    var crewId: DocumentReference?
    var crewNumber: Int? = 0
    var eventId: String = ""
    var obsType: Int = 0
    var stage: Int = 0
    var time: Date = Date(timeIntervalSince1970: 0)
    var timestamp: String? = ""
    
    init?(crewNumber: Int?, eventId: String, obsType: Int, stage: Int, time: Date, timeId: String) {
        self.crewNumber=crewNumber
        self.eventId=eventId
        self.obsType=obsType
        self.stage=stage
        self.time=time
    }
    
    init(fromServerRecordedTime docSnapshot: DocumentSnapshot){
        let value = docSnapshot.data() //is a Dictionary String
        // Conversion from string based dictionary follows pattern:
        // for optional values: self.testA = dictionary["testA"] as? String
        // for required values set a default: self.testC = dictionary["testC"] as? String ?? "default"
        self.crewId = value["crewId"] as? DocumentReference
        self.crewNumber=value["crewNumber"] as? Int ?? 0
        self.eventId=(value["eventId"] as? String)!
        self.obsType=value["obsType"] as? Int ?? 0
        self.stage=value["stage"] as? Int ?? 0
        self.time=(value["time"] as? Date)!
        self.timestamp=value["timestamp"] as? String
    }
    
    func addTime(toCrew: Crew, inDatabase: Firestore) {
        // Add a new document in collection "Times"
        inDatabase.collection("Events").document(toCrew.eventId).collection("Times").addDocument(data: ["crewId":toCrew.crewId as Any,
                                                          "crewNumber":self.crewNumber as Any,
                                                          "eventId":self.eventId,
                                                          "obsType":self.obsType,
                                                          "stage":self.stage,
                                                          "time":self.time,
                                                          "timestamp":FieldValue.serverTimestamp()]) { err in
                                                            if let err = err {
                                                                print("Error writing time document: \(err)")
                                                            } else {
                                                                print("Time document successfully written!")
                                                            }
        }
    }
}
