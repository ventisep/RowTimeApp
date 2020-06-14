//
//  Files.swift
//  FirebaseStorageCache
//
//  Created by Ant on 20/02/2017.
//  Copyright © 2017 Apptitude. All rights reserved.
//

import Foundation
import FirebaseStorage

class Files {
    // this class is used to save and retrieve files from FirebaseStorage which is needed to hold images and webPage references.  It creates a reference that can be used to save the items.  Note the names used for images and web references do need to be unique
    
    private static let storageRef = Storage.storage().reference()
    
    static func imageReference(imageName: String) -> StorageReference {
        return storageRef.child("images").child(imageName)
    }
    
    static func pageReference(pageName: String) -> StorageReference {
        return storageRef.child("pages").child(pageName)
    }
    
}
