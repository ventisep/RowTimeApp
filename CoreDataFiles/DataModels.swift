//
//  RowingClub.swift
//  RowTime
//
//  Created by Paul Ventisei on 05/05/2016.
//  Copyright © 2016 Paul Ventisei. All rights reserved.
//  change to force a copy to the version control system

import UIKit

extension CDCrew {
    
    convenience init(fromServerCrew GLTRCrew: GTLRObservedtimes_RowTimePackageCrew, event: CDEvent) {
        self.init()
        self.event=event
        self.crewNumber=GLTRCrew.crewNumber!
        if GLTRCrew.division != nil {
            self.division=GLTRCrew.division!
        }
        self.crewName=GLTRCrew.crewName!
        self.picFile=GLTRCrew.picFile
        self.category=GLTRCrew.category!
        self.rowerCount=GLTRCrew.rowerCount!
        self.cox=GLTRCrew.cox!
        self.elapsedTime=nil
        
    }
}

class Crew: NSObject, NSCoding  {
    
    // MARK: Properties
    
    var eventId: String = ""
    var division: Int? = 0
    var crewScheduledTime: String? = ""
    var crewNumber: Int = 0
    var crewName: String = ""
    var picFile: String? = ""
    var category: String = ""
    var rowerCount: Int?
    var cox: Bool?
    var rowerIds: [String]?
    var endTimeLocal: Date?
    var startTimeLocal: Date?
    var stages: NSArray?
    var stage: Int?
    var inProgress: Bool?
    var elapsedTime: String
    var recordedTimes: [RecordedTime]?
    
    init(eventId: String,
          crewNumber: Int,
         division: Int?,
         crewScheduledTime: String,
         crewName: String,
         picFile: String?,
         category: String,
         rowerCount: Int?,
         cox: Bool?,
         rowerIds: [String]?,
         endTimeLocal: Date?,
         startTimeLocal: Date?,
         stages: [Stage]?,
         stage: Int?,
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
        self.rowerIds=rowerIds
        self.endTimeLocal=endTimeLocal
        self.startTimeLocal=startTimeLocal
        self.stages=stages as NSArray?
        self.stage=stage
        self.inProgress=inProgress
        self.elapsedTime=elapsedTime
        self.recordedTimes=recordedTimes
    }
    
    //Initializer for creating a crew from the GLTGTLObservedtimesRowTimePackageCrew which is optional so need to unwrap the properties
    
    init(fromServerCrew GLTRCrew: GTLRObservedtimes_RowTimePackageCrew, eventId: String) {
        
        self.eventId=eventId
        self.crewNumber=Int(truncating: GLTRCrew.crewNumber!)
        if GLTRCrew.division != nil {
            self.division=Int(truncating: GLTRCrew.division!)
        }
        self.crewName=GLTRCrew.crewName!
        self.picFile=GLTRCrew.picFile
        self.category=GLTRCrew.category!
        self.rowerCount=Int(truncating: GLTRCrew.rowerCount!)
        self.cox=Bool(truncating: GLTRCrew.cox!)
        self.stages=GLTRCrew.stages! as NSArray
        self.elapsedTime="Time TBD"
        self.recordedTimes=[RecordedTime]()

    }
    
    required init(coder aDecoder: NSCoder) {
        self.eventId=aDecoder.decodeObject(forKey: "eventId") as! String
        self.crewNumber=aDecoder.decodeObject(forKey: "crewNumber") as! Int
        self.division=aDecoder.decodeObject(forKey: "division") as? Int
        self.crewScheduledTime=aDecoder.decodeObject(forKey: "crewScheduledTime") as? String
        self.crewName=aDecoder.decodeObject(forKey: "crewName") as! String
        self.picFile=aDecoder.decodeObject(forKey: "picFile") as? String
        self.category=aDecoder.decodeObject(forKey: "category") as! String
        self.rowerCount=aDecoder.decodeObject(forKey: "rowerCount") as? Int
        self.cox=aDecoder.decodeObject(forKey: "cox") as? Bool
        self.rowerIds=aDecoder.decodeObject(forKey: "eventId") as? [String]
        self.endTimeLocal=aDecoder.decodeObject(forKey: "endTimeLocal") as? Date
        self.startTimeLocal=aDecoder.decodeObject(forKey: "startTimeLocal") as? Date
        self.stages=aDecoder.decodeObject(forKey: "stages") as? NSArray
        self.stage=aDecoder.decodeObject(forKey: "stage") as? Int
        self.inProgress=aDecoder.decodeObject(forKey: "eventId") as? Bool
        self.elapsedTime=aDecoder.decodeObject(forKey: "elapsedTime") as! String
        self.recordedTimes=aDecoder.decodeObject(forKey: "recordedTimes") as? [RecordedTime]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(eventId, forKey: "eventId")
        aCoder.encode(crewNumber, forKey: "crewNumber")
        aCoder.encode(division, forKey: "division")
        aCoder.encode(crewName, forKey: "crewName")
        aCoder.encode(picFile, forKey: "picFile")
        aCoder.encode(category, forKey: "category")
        aCoder.encode(cox, forKey: "cox")
        aCoder.encode(rowerIds, forKey: "rowerIds")
        aCoder.encode(endTimeLocal, forKey: "endTimeLocal")
        aCoder.encode(startTimeLocal, forKey: "startTimeLocal")
        aCoder.encode(stages, forKey: "stages")
        aCoder.encode(stage, forKey: "stage")
        aCoder.encode(inProgress, forKey: "inProgress")
        aCoder.encode(elapsedTime, forKey: "elapsedTime")
        aCoder.encode(recordedTimes, forKey: "recordedTimes")
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
    
    func updateStartTime (_ time: GTLRDateTime, type: Int) {
        
        //type can be 0 = add, 1 = delete, 2 = has been invalidated so ignore

        if type == 0 { //add time
            self.startTimeLocal  = time.date
            self.inProgress = true
        } else if type == 1 {  //delete time
            self.inProgress = false
            self.startTimeLocal = nil
        }
    }


        
    func updateStopTime (_ time: GTLRDateTime, type: Int){
        
        //type can be 0 = add, 1 = delete, 2 = has been invalidated so ignore
        
        if type == 0 { //add time
            
            self.endTimeLocal  = time.date
            self.inProgress = false
        } else if type == 1{ //delete time
        self.endTimeLocal = nil
        self.inProgress = true
        }
    }
    
    func processTime(_ time: GTLRObservedtimes_RowTimePackageObservedTime){

        if time.stage == 0 { //start time
            self.updateStartTime(time.time!, type: Int(truncating: time.obsType!))
        }
        else if time.stage == 1 {
            //end time
            self.updateStopTime(time.time!, type: Int(truncating: time.obsType!))
        }
        
        let recTime = RecordedTime(fromServerTime: time)
        
        self.recordedTimes?.append(recTime!)
        self.calcElapsedTime()
    }
    
}

class Stage: NSObject, NSCoding {
    var label: String
    var stageIndex: Int
    
    init?(label: String, stageIndex: Int){
        self.label=label
        self.stageIndex=stageIndex
    }
    
    required init(coder aDecoder: NSCoder) {
        self.label=aDecoder.decodeObject(forKey: "label") as! String
        self.stageIndex=aDecoder.decodeObject(forKey: "stageIndex") as! Int

    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(label, forKey: "label")
        aCoder.encode(stageIndex, forKey: "stageIndex")
    }
}

//MARK: Event Models
extension CDEvent {
    
    convenience init(fromServerCrew GLTREvent: GTLRObservedtimes_RowTimePackageEvent) {
        
        self.init()
        self.eventId=GLTREvent.eventId
        self.eventDate=GLTREvent.eventDate
        self.eventName=GLTREvent.eventName
        self.eventDesc=GLTREvent.eventDesc
        
    }
}
class Event: NSObject, NSCoding {
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
    
     
    init(fromServerEvent GLTEvent: GTLRObservedtimes_RowTimePackageEvent){
        self.eventId=GLTEvent.eventId!
        self.eventDate=GLTEvent.eventDate!
        self.eventName=GLTEvent.eventName!
        self.eventDesc=GLTEvent.eventDesc!
    }
    
    init(fromCoreData event: CDEvent){
        self.eventId=event.eventId!
        self.eventDate=event.eventDate!
        self.eventName=event.eventName!
        self.eventDesc=event.eventDesc!
    }
 
    
    required init(coder aDecoder: NSCoder) {
        self.eventId=aDecoder.decodeObject(forKey: "eventId") as! String
        self.eventDate=aDecoder.decodeObject(forKey: "eventDate") as! String
        self.eventName=aDecoder.decodeObject(forKey: "eventName") as! String
        self.eventDesc=aDecoder.decodeObject(forKey: "eventDesc") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(eventId, forKey: "eventId")
        aCoder.encode(eventDate, forKey: "eventDate")
        aCoder.encode(eventName, forKey: "eventName")
        aCoder.encode(eventDesc, forKey: "eventDesc")
    }
    
}

class RecordedTime: NSObject, NSCoding  {
    var crewNumber: Int? = 0
    var eventId: String = ""
    var obsType: Int = 0
    var stage: Int = 0
    var time: Date
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
    
    init?(fromServerTime: GTLRObservedtimes_RowTimePackageObservedTime){
        self.crewNumber?=Int(truncating: fromServerTime.crew!)
        self.eventId=fromServerTime.eventId!
        self.obsType=Int(truncating: fromServerTime.obsType!)
        self.stage=Int(truncating: fromServerTime.stage!)
        self.time=(fromServerTime.time?.date)!
        self.timeId=fromServerTime.timeId!
        self.timestamp=String((fromServerTime.timestamp?.stringValue)!)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.crewNumber=aDecoder.decodeObject(forKey: "crewNumber") as? Int
        self.eventId=aDecoder.decodeObject(forKey: "eventId") as! String
        self.obsType=aDecoder.decodeObject(forKey: "obsType") as! Int
        self.stage=aDecoder.decodeObject(forKey: "stage") as! Int
        self.time=aDecoder.decodeObject(forKey: "time") as! Date
        self.timeId=aDecoder.decodeObject(forKey: "timeId") as! String
        self.timestamp=aDecoder.decodeObject(forKey: "timestamp") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(crewNumber, forKey: "crewNumber")
        aCoder.encode(eventId, forKey: "eventId")
        aCoder.encode(obsType, forKey: "obsType")
        aCoder.encode(stage, forKey: "stage")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(timeId, forKey: "timeId")
        aCoder.encode(timestamp, forKey: "timestamp")
    }
}
    
