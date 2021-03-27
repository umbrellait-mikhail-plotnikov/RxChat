//
//  FirebaseService.swift
//  FireBaseTest
//
//  Created by Mikhail Plotnikov on 27.03.2021.
//

import Foundation
import Firebase

final class FirebaseService {
    static var shared = FirebaseService()
    
    let dataBaseRef = Database.database().reference()
    let messagePath: DatabaseReference!
    let onlineUsersPath: DatabaseReference!
    let logPath: DatabaseReference!
    
    private init() {
        messagePath = dataBaseRef.child("messages")
        onlineUsersPath = dataBaseRef.child("onlineUsers")
        logPath = dataBaseRef.child("logs")
    }
    
    
}
