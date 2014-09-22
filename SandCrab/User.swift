//
//  User.swift
//  SandCrab
//
//  Created by Nicolas Halper on 9/22/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

// Users can belong to multiple groups and perform workouts
class User {
    var id = ""
    var username : String = ""
    var fullName : String = ""
    var profileImgName : String = ""
    var groupIDs : [String]?
    
    init() {}
    
    init(dictionary : [String : AnyObject]) {
        id = dictionary["id"] as NSString
        username = dictionary["username"] as NSString
        fullName = dictionary["fullName"] as NSString
        profileImgName = dictionary["profileImgUrl"] as NSString
        if let groups = dictionary["groupIDs"] as? NSArray {
            groupIDs = groups as? [String]
        }
        println("user = \(self.fullName), \(groupIDs?)")
    }
    
    private struct Singleton {
        static var instance : User? = nil
    }
    
    class var loggedInUser : User? {
        get {
        
            if let user = Singleton.instance {
                println("We have a currentUser: \(user.username)")
            } else if let outData = NSUserDefaults.standardUserDefaults().dataForKey("User:loggedInUser") {
        
                if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(outData) as [String:AnyObject]? {
                    let user = User(dictionary:dict)
                    self.loggedInUser = user
                    println("found user \(user.username) from persistent data")
        
                } else {
                    println("bad persistent data found...")
                }
            } else {
                println("no persistent session data found")
            }
            return Singleton.instance
        }
        set {
            if (Singleton.instance != nil) && (newValue == nil) {
                // post logout notification when we set it to nil and it wasn't nil before
                println("Posting logout notification!")
                NSNotificationCenter.defaultCenter().postNotificationName("UserDidLogoutNotification", object: nil)
            }
            Singleton.instance = newValue
            
            if let user = newValue {
                let saveDict : [String : AnyObject] = [
                    "id":user.username,
                    "username":user.username,
                    "fullName":user.fullName,
                    "profileImgUrl":user.profileImgName
                ]
                let data = NSKeyedArchiver.archivedDataWithRootObject(saveDict)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: "User:loggedInUser")
                
            } else {
                // delete user session when setting to logged out...
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "User:loggedInUser")
            }

        }
    }
    
    class var allUsers : [String : User] {
    return [
        "tony" : User(dictionary: ["id" : "tony-id", "username" : "tony", "fullName": "Tony Sherbondy", "profileImgUrl" : "tony"]),
        "nick" : User(dictionary: ["id" : "nick-id", "username" : "nick", "fullName": "Nick Halper", "profileImgUrl" : "nick"]),
        "joey" : User(dictionary: ["id" : "joey-id", "username" : "joey", "fullName": "Joey Hiller", "profileImgUrl" : "joey"])
        ]
    }
    
    
    class func saveFirebaseUser() {
        var userRef = FIREBASE_USERS_REF.childByAutoId()
        var user = ["username" : "tony", "fullName": "Tony Sherbondy", "profileImgUrl" : "tony"]
        
        userRef.setValue(user)
        
        let userGroupsRef = userRef.childByAppendingPath("groupIDs")
        userGroupsRef.setValue(["sfcf","flagship"])
        
        user["id"] = userRef.name
        println("saved user \(user)")
    }
    
    class func observeUsers() {
        FIREBASE_USERS_REF.observeEventType(.Value, withBlock: { snapshot in
            println("users data: \(snapshot.value)")
            for data in snapshot.children.allObjects {
                if let snap = data as? FDataSnapshot {
                    if var userDict = snap.value as? [String : AnyObject] {
                        userDict["id"] = snap.name
                        let user = User(dictionary: userDict)
                    }
                }
            }
        })
    }
}

