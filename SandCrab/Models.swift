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
//let FIREBASE_REF =  Firebase(url: "https://amber-inferno-424.firebaseio.com/")
let FIREBASE_REF =  Firebase(url: "https://boiling-fire-1252.firebaseio.com/")
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
                println("We have a currentUser: \(user)")
            } else {
                println("Current user is nil...TODO:attempt load from persistent storage")
            }
            return Singleton.instance
        }
        set {
            println("Set currentUser to \(newValue)")
            Singleton.instance = newValue
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

// Ways to score a workout
enum WorkoutScoreType : Int {
    case Time = 0, Rounds = 1, Weight = 2
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

let kAllWorkoutNotificationUpdate = "NSNotificationCenterAllWorkoutUpdates"

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
            let friendsResults = athleteResults.filter({ $0.userID != User.loggedInUser!.id })
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
    
    
    class func saveFirebaseWorkout(workout: [String : AnyObject]) {
        var workoutRef = FIREBASE_WORKOUT_REF.childByAutoId()
        var mutableWorkout = workout
        workoutRef.setValue(mutableWorkout)
        mutableWorkout["id"] = workoutRef.name
        println("saved workout!")
    }
    
    class func observeAllWorkouts() {
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
            println("Workout posting notification kWorkoutNotificationUpdate")
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName(kAllWorkoutNotificationUpdate, object: nil, userInfo: nil)
            
        })
    }

    
    
}


class WorkoutList {
    var list : [Workout] = []
    
    func observeUpdates(onUpdates:() -> Void) {
        FIREBASE_WORKOUT_REF.observeEventType(.Value, withBlock: { snapshot in
            println("workouts data: \(snapshot.value)")
            var newList : [Workout] = []
            for data in snapshot.children.allObjects {
                if let snap = data as? FDataSnapshot {
                    if var workoutDict = snap.value as? [String : AnyObject] {
                        workoutDict["id"] = snap.name
                        let workout = Workout(dictionary: workoutDict)
                        
                        println("workout retrieved: \(workout)")
                        newList.append(workout)
                    }
                }
            }
            /*
            // note: we could do a posts notification route rather than a callback
            // but the idea here is that this method itself would be listening for global changes
            // on workouts, and only posting a callback if it's own user list has changed for
            // whatever filters we choose to apply
            println("Workout posting notification kWorkoutNotificationUpdate")
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName(kWorkoutNotificationUpdate, object: nil, userInfo: nil)
            */
            // now a quick hack to reverse the list so the newest workouts appear on top...
            self.list = reverse(newList)
            onUpdates()
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
