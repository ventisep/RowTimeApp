//
//  RowingClub.swift
//  RowTime
//
//  Created by Paul Ventisei on 05/05/2016.
//  Copyright © 2016 Paul Ventisei. All rights reserved.
//  change to force a copy to the version control system

import UIKit
import Firebase


class Crew {
    
    // MARK: Properties
    
    var eventRef: DocumentReference?
    var eventId: String = ""
    var crewId: DocumentReference?
    var division: Int?
    var crewScheduledTime: Date?
    var crewNumber: Int = 0
    var crewName: String = ""
    var picFile: String? = ""
    var category: String = ""
    var rowerCount: Int
    var cox: String?
    var rowers: [String]?
    var endTimeLocal: Date?
    var startTimeLocal: Date?
    var stageTimes: Dictionary<String, Any>?
    var inProgress: Bool?  {if startTimeLocal != nil && endTimeLocal == nil {return true} else {return false}
    } //calculated value
    var elapsedTime: String { return self.calcElapsedTime()}//calculated value
    var recordedTimes: [RecordedTime]? // added from Times
    var error: String? // used to return errors
    
    init(eventRef: DocumentReference?,
         eventId: String,
         crewId: DocumentReference?,
         crewNumber: Int,
         division: Int?,
         crewScheduledTime: Date?,
         crewName: String,
         picFile: String?,
         category: String,
         rowerCount: Int,
         cox: String?,
         rowers: [String]?,
         endTimeLocal: Date?,
         startTimeLocal: Date?,
         stageTimes: Dictionary<String, Any>?,
         inProgress: Bool?,
         recordedTimes: [RecordedTime]?) {
    
        // Initialize stored properties.
        self.eventId=eventId
        self.crewNumber=crewNumber
        self.division=division
        self.crewScheduledTime=crewScheduledTime
        self.crewName=crewName
        self.picFile=picFile
        self.category=category
        self.rowerCount=rowerCount
        self.cox=cox
        self.rowers=rowers
        self.endTimeLocal=endTimeLocal
        self.startTimeLocal=startTimeLocal
        self.stageTimes=stageTimes
        self.recordedTimes=recordedTimes
        self.error=nil
    }
    
    //Initializer for creating a crew from the Dictionary that somes back from Firestore
    
    init(fromServerCrew docSnapshot: DocumentSnapshot, eventId: String, eventRef: DocumentReference) {
        self.error = nil
        let value = docSnapshot.data() //is a Dictionary String
        // Conversion from string based dictionary follows pattern:
        // for optional values: self.testA = dictionary["testA"] as? String
        // for required values set a default: self.testC = dictionary["testC"] as? String ?? "default"
        self.eventRef=eventRef
        self.eventId=eventId
        self.crewId=docSnapshot.reference
        self.crewNumber = value["crewNumber"] as? Int ?? 0
        self.division = value["division"] as? Int
        self.crewScheduledTime=value["crewScheduledTime"] as? Date
        self.crewName=value["crewName"] as? String ?? "Name Error"
        self.picFile=value["picFile"] as? String
        self.category=value["category"] as? String ?? "error"
        self.rowerCount=value["rowerCount"] as? Int ?? 0
        self.cox=value["cox"] as? String
        self.rowers=value["rowers"] as? [String]
        self.endTimeLocal=value["endTimeLocal"] as? Date
        self.startTimeLocal=value["startTimeLocal"] as? Date
        self.stageTimes=value["stageTimes"] as? Dictionary
        self.recordedTimes=value["recordedTimes"] as? [RecordedTime]
    }
    
    
    // Methods for crew
    
    func updateCrewFromServer (fromServerCrew docSnapshot: DocumentSnapshot) {
        self.error = nil
        let value = docSnapshot.data() //is a Dictionary String
        // Conversion from string based dictionary follows pattern:
        // for optional values: self.testA = dictionary["testA"] as? String
        // for required values set a default: self.testC = dictionary["testC"] as? String ?? "default"
        if self.crewId != docSnapshot.reference {self.error = "Crew reference on server record not the same as the crew object it is updating";
            return
        }
        self.crewNumber = value["crewNumber"] as? Int ?? 0
        self.division = value["division"] as? Int
        self.crewScheduledTime=value["crewScheduledTime"] as? Date
        self.crewName=value["crewName"] as? String ?? "Name Error"
        self.picFile=value["picFile"] as? String
        self.category=value["category"] as? String ?? "error"
        self.rowerCount=value["rowerCount"] as? Int ?? 0
        self.cox=value["cox"] as? String
        self.rowers=value["rower1"] as? [String]
        self.endTimeLocal=value["endTimeLocal"] as? Date
        self.startTimeLocal=value["startTimeLocal"] as? Date
        self.stageTimes=value["stageTimes"] as? Dictionary
        // do not update the Times as this is a crew data updat only
    }
    
    func calcElapsedTime () -> String {
        
        // TODO: This ignores milleseconds now.  have to add back in by adding to the NS dates I create
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "mm:ss.S"
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        var returnString = ""
        
        if self.startTimeLocal == nil {
            //The Crew have not yet started
            
            returnString = "Not Started"
            
        } else if self.endTimeLocal == nil {
            //The crew started but not finished show difference since start time to now
            
            let elapsedNSTimeInterval = -1*startTimeLocal!.timeIntervalSinceNow
            returnString = DateComponentsFormatter().string(from: elapsedNSTimeInterval)!
            
        } else if self.endTimeLocal != nil{
            //crew is finished calculate time between start and end time
            
            let elapsedNSTimeInterval=self.endTimeLocal!.timeIntervalSince(self.startTimeLocal!)
            returnString = timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: elapsedNSTimeInterval)) //MARK: TODO: this is wrong in India where we run 30mins off GMT need to replace with my own function to calculate the displat time (as I did in javascript)
            
        }
        return returnString
    }
    
    func updateStartTime (_ time: Date, type: Int) {
        //type can be 0 = add, 1 = delete, 2 = has been invalidated so ignore

        if type == 0 { //add time
            self.startTimeLocal  = time
            self.endTimeLocal = nil // take out any previous end time
        } else if type == 1 {  //delete time
            self.startTimeLocal = nil
        }
    }

    func updateStopTime (_ time: Date, type: Int){
        //type can be 0 = add, 1 = delete, 2 = has been invalidated so ignore
        
        if type == 0 { //add time
            self.endTimeLocal  = time
        } else if type == 1{ //delete time
            self.endTimeLocal = nil
        }
    }
    
    func processTime(_ time: RecordedTime){

        if time.stage == 0 { //start time
            self.updateStartTime(time.time, type: time.obsType)
        }
        else if time.stage == 1 {
            //end time
            self.updateStopTime(time.time, type: time.obsType)
        }

        if self.recordedTimes?.insert(time, at: 0) == nil { //if the first item to be added to the optional array
            self.recordedTimes = [time]
        }
    }
    
}

class Stage: NSObject {
    var label: String
    var stageIndex: Int
    
    init?(label: String, stageIndex: Int){
        self.label=label
        self.stageIndex=stageIndex
    }
}

//MARK: Event Models

class Event: NSObject {
    var eventRef: DocumentReference?
    var eventId: String = ""
    var eventDate: String = ""
    var eventName: String = ""
    var eventImage: String = ""
    var eventDesc: String = ""
    var timeRecorders: [String] = []
    
    init?(eventId: String, eventDate: String, eventName: String, eventImage: String, eventDesc: String, timeRecorders: [String]){
        self.eventId=eventId
        self.eventDate=eventDate
        self.eventName=eventName
        self.eventImage=eventImage
        self.eventDesc=eventDesc
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
        self.timeRecorders=value["timeRecorders"] as? [String] ?? ["none"]
    }
    
}

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
        inDatabase.collection("Times").addDocument(data: ["crewId":toCrew.crewId as Any,
                                                          "crewNumber":self.crewNumber as Any,
                                                          "eventId":self.eventId,
                                                          "obsType":self.obsType,
                                                          "stage":self.stage,
                                                          "time":self.time,
                                                          "timestamp":FieldValue.serverTimestamp()]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
    
