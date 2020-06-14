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

class Event: NSObject, Identifiable {
    var id = UUID()
    var eventRef: DocumentReference?
    var eventId: String = "" //used to identify the event in the database as well as the identifier the user needs to connect to the event for watching, time recording or race controlling it has to be unique
    var eventDate: String = ""
    var eventName: String = ""
    var eventImageName: String = ""
    var eventImage: UIImageView?
    var eventDesc: String = ""
    var eventStages: [Stage] = []
    var timeRecorders: [String] = []
    
    //Mark: Initializers
    
    init?(eventId: String, eventDate: String, eventName: String, eventImageName: String, eventImage: UIImageView?, eventDesc: String){
        self.eventId=eventId
        self.eventDate=eventDate
        self.eventName=eventName
        self.eventImageName=eventImageName
        self.eventImage=eventImage
        self.eventDesc=eventDesc
        self.eventStages=[Stage(label: "Start", stageIndex: 0), Stage(label: "Finish", stageIndex: 1)]
        self.timeRecorders=["none"]
        
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
        self.eventImageName=value["eventImage"] as? String ?? {value["eventImageName"] as? String ?? ""}()
        self.eventDesc=value["eventDesc"] as? String ?? ""
        self.eventStages = value["eventStages"] as? [Stage] ?? [Stage(label: "Start", stageIndex: 0), Stage(label: "Finish", stageIndex: 1)] //default is that there is a start and finish line
        self.timeRecorders=value["timeRecorders"] as? [String] ?? ["none"]
    }
    
    // Method to Write to the Database
    
    func writeToFirestore(inDatabase: Firestore) {
        // write (TODO: or update) the current Event to the Firestore Database
        inDatabase.collection("Events").addDocument(data: [
            "eventId":self.eventId as Any,
            "eventDate":self.eventDate as Any,
            "eventName":self.eventName as Any,
            "eventImageName":self.eventImageName as Any,
            "eventDesc":self.eventDesc as Any,
    //        "eventStages":self.eventStages,
            "timestamp":FieldValue.serverTimestamp()]) { err in
                if let err = err {
                    print("Error writing event document: \(err)")
                } else {
                    print("Event document successfully written!")
                    let ref=Files.imageReference(imageName: self.eventImageName)
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    ref.putData((self.eventImage?.image?.jpegData(compressionQuality: 1))!, metadata: metadata)
                }
        }
    }

    struct Stage {
        var label: String
        var stageIndex: Int

    }
}
