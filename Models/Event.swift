//
//  File.swift
//  RowTime
//
//  Created by Paul Ventisei on 16/06/2019.
//  Copyright © 2019 Paul Ventisei. All rights reserved.
//

import Foundation
import Firebase

//MARK: Event Model
// The Event class is a representation of a rowing event.

class Event: NSObject {
    var eventRef: DocumentReference?
    var eventId: String = "" //used to identify the event in the database as well as the identifier the user needs to connect to the event for watching, time recording or race controlling it has to be unique
    var eventDate: String = ""
    var eventName: String = ""
    var eventImage: String = ""
    var eventDesc: String = ""
    var eventStages: [Stage] = []
    var timeRecorders: [String] = []
    
    init?(eventId: String, eventDate: String, eventName: String, eventImage: String, eventDesc: String, eventStages: [Stage], timeRecorders: [String]){
        self.eventId=eventId
        self.eventDate=eventDate
        self.eventName=eventName
        self.eventImage=eventImage
        self.eventDesc=eventDesc
        self.eventStages=eventStages
        self.timeRecorders=timeRecorders
        
    }
    
    
    init(fromServerEvent docSnapshot: DocumentSnapshot){
        let value = docSnapshot.data() //is a Dictionary String
        // Conversion from string based dictionary follows pattern:
        // for optional values: self.testA = dictionary["testA"] as? String
        // for required values set a default: self.testC = dictionary["testC"] as? String ?? "default"
        self.eventRef=docSnapshot.reference
        self.eventId=docSnapshot.documentID
        self.eventDate=value["eventDate"] as? String ?? ""
        self.eventName=value["eventName"] as? String ?? ""
        self.eventImage=value["eventImage"] as? String ?? ""
        self.eventDesc=value["eventDesc"] as? String ?? ""
        self.eventStages = value["eventStages"] as? [Stage] ?? [] //default is that there is a start and finish line
        self.timeRecorders=value["timeRecorders"] as? [String] ?? ["none"]
    }
    
}

struct Stage {
    var label: String
    var stageIndex: Int
    
    init?(label: String, stageIndex: Int){
        self.label=label
        self.stageIndex=stageIndex
    }
}
