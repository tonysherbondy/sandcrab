//
//  Models.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/16/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

// Let's play with firebase

// Create a reference to a Firebase location
let FIREBASE_REF =  Firebase(url: "https://amber-inferno-424.firebaseio.com/")
let FIREBASE_USERS_REF = FIREBASE_REF.childByAppendingPath("users")
let FIREBASE_WORKOUT_REF = FIREBASE_REF.childByAppendingPath("workouts")

// Groups can create workouts
struct Group {
    var name: String
    var id: String
    var location : String
    var workoutIDs : [String]
}

// Users can belong to multiple groups and perform workouts
class User {
    var id : String
    var username : String
    var fullName : String
    var profileImgName : String
    var groupIDs : [String]?
    
    init(dictionary : [String : AnyObject]) {
        id = dictionary["id"] as NSString
        username = dictionary["username"] as NSString
        fullName = dictionary["fullName"] as NSString
        profileImgName = dictionary["profileImgUrl"] as NSString
        if let groups = dictionary["groupIDs"] as? NSArray {
            groupIDs = groups as? [String]
        }
        println("user = \(self.fullName), \(groupIDs!)")
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

// Ways to score a workout
enum WorkoutScoreType : Int {
    case Time = 1, Rounds = 2, Weight = 3
}

// Workout score is a type and value
struct WorkoutScore {
    var type : WorkoutScoreType
    var value : Int?
    func scoreDescription() -> String {
        var valueString = ""
        if let value = self.value {
            valueString = "\(value) "
        }
        switch type {
        case .Rounds:
            return valueString + "rounds"
        case .Time:
            return valueString + "seconds"
        case .Weight:
            return valueString + "lbs"
        default:
            println("Unkown workout score type!!")
        }
    }
}

// Result athlete got on a workout, can sort results
struct AthleteResult {
    var userID : String
    var score : WorkoutScore
    
    func comparator() -> (s1 : AthleteResult, s2 : AthleteResult) -> Bool {
        return { (s1, s2) -> Bool in
            switch s1.score.type {
            case .Rounds, .Weight:
                return s1.score.value > s2.score.value
            case .Time:
                return s1.score.value < s2.score.value
            }
            
        }
    }
}

// Message from a user on a workout, workout owns the messages
struct ChatMessage {
    var content : String
    var userID : String
}

// Workout to perform
class Workout {
    var id : String
    var name : String
    var description: String
    // Created the workout
    var groupID: String
    // Score template tells us how to score workout and is setup when we create workout
    var scoreTemplate : WorkoutScoreType
    // Results for each athlete
    var athleteResults : [AthleteResult]
    
    // Sort by workout, each workout result will need a type specifying how to sort it
    var sortedAthleteResults : [AthleteResult] {
        get {
            if athleteResults.count == 0 {
                return athleteResults
            }
            return athleteResults.sorted(athleteResults[0].comparator())
        }
    }
    
    // Removes the logged in user from the list
    var sortedFriendsResults : [AthleteResult] {
        get {
            let friendsResults = athleteResults.filter({ $0.userID != LOGGED_IN_USER?.id })
            if friendsResults.count == 0 {
                return friendsResults
            }
            return friendsResults.sorted(friendsResults[0].comparator())
        }
    }
    
    init(dictionary : [String : AnyObject]) {
        id = dictionary["id"] as NSString
        name = dictionary["name"] as NSString
        description = dictionary["description"] as NSString
        groupID = dictionary["groupID"] as NSString
        
        let scoreTemplateValue = dictionary["scoreTemplate"] as NSNumber
        scoreTemplate = WorkoutScoreType.fromRaw(scoreTemplateValue)!
        
        athleteResults = []
    }
    
    
    class func saveFirebaseWorkout() {
        var workoutRef = FIREBASE_WORKOUT_REF.childByAutoId()
        var workout : [String : AnyObject] = [
                "name": "SFCF 2014.09.11",
                "description": "Fran",
                "groupID": "sfcf",
                "scoreTemplate": WorkoutScoreType.Time.toRaw()
            ]

        
        workoutRef.setValue(workout)
        
        workout["id"] = workoutRef.name
        
        println("saved workout \(workout)")
    }
    
    class func observeWorkouts() {
        FIREBASE_WORKOUT_REF.observeEventType(.Value, withBlock: { snapshot in
            println("workouts data: \(snapshot.value)")
            for data in snapshot.children.allObjects {
                if let snap = data as? FDataSnapshot {
                    if var workoutDict = snap.value as? [String : AnyObject] {
                        workoutDict["id"] = snap.name
                        let workout = Workout(dictionary: workoutDict)
                        
                        println("workout retrieved: \(workout)")
                    }
                }
            }
        })
    }

    
    
}

//let WORKOUT_STORE = [
//    Workout(
//        id:"SFCF.2014.09.11",
//        name: "SFCF 2014.09.11",
//        description: "Fran",
//        groupID: "sfcf",
//        scoreTemplate: WorkoutScoreType.Time,
//        athleteResults: [
//            AthleteResult(userID: "tony", score: WorkoutScore(type: .Time, value: 250)),
//            AthleteResult(userID: "carl", score: WorkoutScore(type: .Time, value: 300)),
//            AthleteResult(userID: "nate", score: WorkoutScore(type: .Time, value: 350)),
//            AthleteResult(userID: "nick", score: WorkoutScore(type: .Time, value: 400)),
//            AthleteResult(userID: "joey", score: WorkoutScore(type: .Time, value: 500))
//            
//        ]),
//    Workout(
//        id:"SFCF.2014.09.12",
//        name: "SFCF 2014.09.12",
//        description: "Cindy",
//        groupID: "sfcf",
//        scoreTemplate: WorkoutScoreType.Rounds,
//        athleteResults: [
//            AthleteResult(userID: "tony", score: WorkoutScore(type: .Rounds, value: 20)),
//            AthleteResult(userID: "nate", score: WorkoutScore(type: .Rounds, value: 20)),
//            AthleteResult(userID: "carl", score: WorkoutScore(type: .Rounds, value: 25)),
//            AthleteResult(userID: "nick", score: WorkoutScore(type: .Rounds, value: 15)),
//            AthleteResult(userID: "joey", score: WorkoutScore(type: .Rounds, value: 17))
//            
//        ]),
//    Workout(
//        id:"SFCF.2014.09.12",
//        name: "SFCF 2014.09.12",
//        description: "Karen",
//        groupID: "sfcf",
//        scoreTemplate: WorkoutScoreType.Time,
//        athleteResults: [
//            AthleteResult(userID: "tony", score: WorkoutScore(type: .Time, value: 600)),
//            AthleteResult(userID: "carl", score: WorkoutScore(type: .Time, value: 500)),
//            AthleteResult(userID: "nick", score: WorkoutScore(type: .Time, value: 430)),
//            AthleteResult(userID: "nate", score: WorkoutScore(type: .Time, value: 300)),
//            AthleteResult(userID: "joey", score: WorkoutScore(type: .Time, value: 470))
//            
//        ])
//    
//]
//
//let workoutIDs = WORKOUT_STORE.map({ $0.id })
let GROUP_STORE = [
    "sfcf": Group(name: "San Francisco Crossfit", id: "sfcf", location: "San Francisco", workoutIDs: [])
]

// Global database of users
//let USER_STORE = [
//    "nate" : User(id: "nate", name: "Nate", profileImgName: "nate", groupIDs: ["sfcf"]),
//    "tony" : User(id: "tony", name: "Tony", profileImgName: "tony", groupIDs: ["sfcf"]),
//    "carl" : User(id: "carl", name: "Carl", profileImgName: "carl", groupIDs: ["sfcf"]),
//    "nick" : User(id: "nick", name: "Nick", profileImgName: "nick", groupIDs: ["sfcf"]),
//    "joey" : User(id: "joey", name: "Joey", profileImgName: "joey", groupIDs: ["sfcf"])
//]
let USER_STORE = [String : User]()

// TODO: This should be a proper singleton
var LOGGED_IN_USER = USER_STORE["carl"]

//func getFirebaseUsers() {
//    // Get a reference to our posts
//    var usersRef = FIREBASE_USERS_REF
//    
//    // Attach a closure to read the data at our posts reference
//    usersRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
//        for child in snapshot.children.allObjects {
//            if let snap = child as? FDataSnapshot {
//                let id = snap.value["id"] as String
//                let name = snap.value["name"] as String
//                let imageUrl = snap.value["profileImgName"] as String
//                println("id: \(id)")
//                println("name: \(name)")
//                println("imageUrl: \(imageUrl)")
//            }
//        }
//        }, withCancelBlock: { error in
//            println(error.description)
//    })
//}

