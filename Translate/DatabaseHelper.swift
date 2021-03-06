//
//  DatabaseHelper.swift
//  Translate
//
//  Created by Bryan Ye on 13/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol FetchData: class {
    func dataReceived(contacts: [Contact])
}

class DatabaseHelper {
    private static let _instance = DatabaseHelper()
    
    weak var delegate: FetchData?
    
    private init () {
        
    }
    
    static var Instance: DatabaseHelper {
        return _instance
    }
    
    var databaseRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var contactsRef: FIRDatabaseReference {
        return databaseRef.child(Constants.CONTACTS)
    }
    
    var messagesRef: FIRDatabaseReference {
        return databaseRef.child(Constants.MESSAGES)
    }
    
    var mediaMessagesRef: FIRDatabaseReference {
        return databaseRef.child(Constants.MEDIA_MESSAGES)
    }
    
    var storageRef: FIRStorageReference {
        return FIRStorage.storage().reference(forURL: Constants.STORAGE_REFERENCE_URL)
    }
    
    var imageStorageRef: FIRStorageReference {
        return storageRef.child(Constants.IMAGE_STORAGE)
    }
    
    var videoStorageRef: FIRStorageReference {
        return storageRef.child(Constants.VIDEO_STORAGE)
    }
    
    func saveUser(withID: String, email: String, password: String) {
        let data: [String: Any] = [Constants.EMAIL: email, Constants.PASSWORD: password]
        
        contactsRef.child(withID).setValue(data)
    }
    
    func getContacts() {
        contactsRef.observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
            var contacts = [Contact]()

            if let contactsInDatabase = snapshot.value as? NSDictionary {
                for (key, value) in contactsInDatabase {
                    if let contactData = value as? NSDictionary {
                        if let email = contactData[Constants.EMAIL] as? String {
                            let id = key as! String
                            let newContact = Contact(id: id, name: email)
                            contacts.append(newContact)
                        }
                    }
                }
            }
            self.delegate?.dataReceived(contacts: contacts)
        }
    }
}
