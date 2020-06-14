//
//  File.swift
//  RowTime
//
//  Created by Paul Ventisei on 16/06/2019.
//  Copyright © 2019 Paul Ventisei. All rights reserved.
//

import Foundation
import Firebase


class Crew: Identifiable, Hashable {
        
    // MARK: Properties
    
    var id = UUID()
    var eventRef: DocumentReference?
    var eventId: String = ""
    var crewRef: DocumentReference?
    var index: UInt?
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
    }
    
    //MARK: Initializers for creating a crew from the Dictionary that comes back from Firestore
    
    init(fromServerCrew docSnapshot: DocumentSnapshot, eventId: String, eventRef: DocumentReference) {
        let value = docSnapshot.data() //is a Dictionary String
        // Conversion from string based dictionary follows pattern:
        // for optional values: self.testA = dictionary["testA"] as? String
        // for required values set a default: self.testC = dictionary["testC"] as? String ?? "default"
        self.eventRef=eventRef
        self.eventId=eventId
        self.crewRef=docSnapshot.reference
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
    
    init(fromServerCrew docSnapshot: DocumentSnapshot, eventId: String) {
        let value = docSnapshot.data() //is a Dictionary String
        // Conversion from string based dictionary follows pattern:
        // for optional values: self.testA = dictionary["testA"] as? String
        // for required values set a default: self.testC = dictionary["testC"] as? String ?? "default"
        self.eventId=eventId
        self.crewRef=docSnapshot.reference
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
    
    
    // MARK: Public Methods for crew
    // Make Equatable
    static func == (lhs: Crew, rhs: Crew) -> Bool{
           return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    //make Hashable
    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self).hashValue)
    }

    // `hashValue` is deprecated starting Swift 4.2, but if you use
    // earlier versions, then just override `hashValue`.
    //
    // public var hashValue: Int {
    //    return ObjectIdentifier(self).hashValue
    // }

    
    // update the crew object from new information recieved from the server.  Not initialising - updating
    func updateCrewFromServer (fromServerCrew docSnapshot: DocumentSnapshot) {
        let value = docSnapshot.data() //is a Dictionary String
        // Conversion from string based dictionary follows pattern:
        // for optional values: self.testA = dictionary["testA"] as? String
        // for required values set a default: self.testC = dictionary["testC"] as? String ?? "default"

        self.crewNumber = value["crewNumber"] as? Int ?? 0
        self.division = value["division"] as? Int
        self.crewScheduledTime=value["crewScheduledTime"] as? Date
        self.crewName=value["crewName"] as? String ?? "Name Error"
        self.picFile=value["picFile"] as? String
        self.category=value["category"] as? String ?? "error"
        self.rowerCount=value["rowerCount"] as? Int ?? 0
        self.cox=value["cox"] as? String
        self.rowers=value["rower1"] as? [String]
        //don't update the start and end time as these are updated when the recorded times are processed and already contain the results of the processing of these times
        //self.endTimeLocal=value["endTimeLocal"] as? Date
        //self.startTimeLocal=value["startTimeLocal"] as? Date
        self.stageTimes=value["stageTimes"] as? Dictionary
        // do not update the Times as this is a crew data update only
    }
    
    func writeToFirestore(inDatabase: Firestore) {
        // Add a new document in collection "Crews"
        inDatabase.collection("Events").document(self.eventId).collection("Crews").addDocument(data:
            ["crewNumber":self.crewNumber as Any,
             "division":self.division as Any,
             "crewScheduledTime":self.crewScheduledTime as Any,
             "crewName":self.crewName,
             "picFile":self.picFile as Any,
             "category":self.category,
             "rowerCount":self.rowerCount,
             "rower1":self.rowers as Any,
             "cox": self.cox as Any,
             "stageTimes": self.stageTimes as Any,
             "timestamp":FieldValue.serverTimestamp()]) { err in if let err = err {
                    print("Error writing crew document: \(err)") } else
             {
                    print("Crew document successfully written!")
             }
        }
    }
    
    func addTime(FirestoreDb: Firestore, time: Date, stage: Int) {
        
        let recordedTime1 = RecordedTime(crewNumber: Int(self.crewNumber), eventId: self.eventId,  obsType: 0, stage: stage, time: time, timeId: "RC1")
        
        recordedTime1!.writeToFirestore(toCrew: self, inDatabase: FirestoreDb)

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
    
    //MARK: Private Methods
    private func calcElapsedTime () -> String {
        
        // TODO: This ignores milleseconds now.  have to add back in by adding to the NS dates I create
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "mm:ss.S"
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 0) //need this to ensure if operating in timezones that are 30m off GMT the calculations still work
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
            returnString = timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: elapsedNSTimeInterval))
        }
        return returnString
    }
    
    private func updateStartTime (_ time: Date, type: Int) {
        //type can be 0 = add, 1 = delete, 2 = has been invalidated so ignore
        
        if type == 0 { //add time
            self.startTimeLocal  = time
            self.endTimeLocal = nil // take out any previous end time
        } else if type == 1 {  //delete time
            self.startTimeLocal = nil
        }
    }
    
    private func updateStopTime (_ time: Date, type: Int){
        //type can be 0 = add, 1 = delete, 2 = has been invalidated so ignore
        
        if type == 0 { //add time
            self.endTimeLocal  = time
        } else if type == 1{ //delete time
            self.endTimeLocal = nil
        }
    }

    
}
