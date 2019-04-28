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
    
    var eventId: String = ""
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
    var inProgress: Bool?
    var elapsedTime: String
    var recordedTimes: [RecordedTime]?
    var error: String?
    
    init(eventId: String,
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
         elapsedTime: String,
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
        self.inProgress=inProgress
        self.elapsedTime=elapsedTime
        self.recordedTimes=recordedTimes
        self.error=nil
    }
    
    //Initializer for creating a crew from the Dictionary that somes back from Firestore
    
    init(fromServerCrew docSnapshot: DocumentSnapshot, eventId: String) {
        self.error = nil
        let value = docSnapshot.data() //is a Dictionary String
        // Conversion from string based dictionary follows pattern:
        // for optional values: self.testA = dictionary["testA"] as? String
        // for required values set a default: self.testC = dictionary["testC"] as? String ?? "default"
        self.eventId=eventId
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
        self.inProgress=value["inProgress"] as? Bool
        self.elapsedTime=value["crewNumber"] as? String ?? "Time TBD"
        self.recordedTimes=value["recordedTimes"] as? [RecordedTime]
    }
    
    
    // Methods for crew
    
  func calcElapsedTime () {
        
        // TODO: This ignores milleseconds now.  have to add back in by adding to the NS dates I create
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "mm:ss.S"
        
        if self.startTimeLocal == nil {
            //The Crew have not yet started
            
            self.elapsedTime = "Not Started"
            
        } else if self.endTimeLocal == nil {
            //The crew started but not finished show difference since start time to now
            
            let elapsedNSTimeInterval=startTimeLocal!.timeIntervalSinceNow
            self.elapsedTime = DateComponentsFormatter().string(from: elapsedNSTimeInterval)!
            
        } else if self.endTimeLocal != nil{
            //crew is finished calculate time between start and end time
            
            let elapsedNSTimeInterval=self.endTimeLocal!.timeIntervalSince(self.startTimeLocal!)
            self.elapsedTime = timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: elapsedNSTimeInterval))
            
        }
    }
    
    func updateStartTime (_ time: Date, type: Int) {
        
        //type can be 0 = add, 1 = delete, 2 = has been invalidated so ignore

        if type == 0 { //add time
            self.startTimeLocal  = time
            self.inProgress = true
        } else if type == 1 {  //delete time
            self.inProgress = false
            self.startTimeLocal = nil
        }
    }


        
    func updateStopTime (_ time: Date, type: Int){
        
        //type can be 0 = add, 1 = delete, 2 = has been invalidated so ignore
        
        if type == 0 { //add time
            
            self.endTimeLocal  = time
            self.inProgress = false
        } else if type == 1{ //delete time
        self.endTimeLocal = nil
        self.inProgress = true
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

        self.recordedTimes?.append(time)
        self.calcElapsedTime()
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
    var eventId: String = ""
    var eventDate: String = ""
    var eventName: String = ""
    var eventImage: UIImage?
    var eventDesc: String = ""
    
    init?(eventId: String, eventDate: String, eventName: String, eventImage: UIImage?, eventDesc: String){
        self.eventId=eventId
        self.eventDate=eventDate
        self.eventName=eventName
        self.eventImage=eventImage!
        self.eventDesc=eventDesc

    }
    
     
    init(fromServerEvent docSnapshot: DocumentSnapshot){
        let value = docSnapshot.data() //is a Dictionary String
        // Conversion from string based dictionary follows pattern:
        // for optional values: self.testA = dictionary["testA"] as? String
        // for required values set a default: self.testC = dictionary["testC"] as? String ?? "default"
        self.eventId=docSnapshot.documentID
        self.eventDate=value["eventDate"] as? String ?? ""
        self.eventName=value["eventName"] as? String ?? ""
        self.eventDesc=value["eventDesc"] as? String ?? ""
    }
    
}

class RecordedTime: NSObject  {
    var crewNumber: Int? = 0
    var eventId: String = ""
    var obsType: Int = 0
    var stage: Int = 0
    var time: Date = Date(timeIntervalSince1970: 0)
    var timeId: String = ""
    var timestamp: String? = ""

    init?(crewNumber: Int?, eventId: String, obsType: Int, stage: Int, time: Date, timeId: String, timestamp: String?) {
    self.crewNumber=crewNumber
    self.eventId=eventId
    self.obsType=obsType
    self.stage=stage
    self.time=time
    self.timeId=timeId
    self.timestamp=timestamp
    }
    
    init(fromServerRecordedTime docSnapshot: DocumentSnapshot){
        let value = docSnapshot.data() //is a Dictionary String
        // Conversion from string based dictionary follows pattern:
        // for optional values: self.testA = dictionary["testA"] as? String
        // for required values set a default: self.testC = dictionary["testC"] as? String ?? "default"
        self.crewNumber=value["crewNumber"] as? Int ?? 0
        self.eventId=(value["eventId"] as? String)!
        self.obsType=value["obsType"] as? Int ?? 0
        self.stage=value["stage"] as? Int ?? 0
        self.time=(value["time"] as? Date)!
        self.timeId=value["timeId"] as? String ?? ""
        self.timestamp=value["timestamp"] as? String
    }
}
    
