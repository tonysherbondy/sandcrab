//
//  Models.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/16/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

// Groups can create workouts
struct Group {
    var name: String
    var id: String
    var location : String
    var workoutIDs : [String]
}

// Users can belong to multiple groups and perform workouts
struct User {
    var id : String
    var name : String
    var profileImgName : String
    var groupIDs : [String]
}

// Ways to score a workout
enum WorkoutScoreType {
    case Time, Rounds, Weight
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
struct Workout {
    var id : String
    var name : String
    var description: String
    // Created the workout
    var groupID: String
    var chatMessages: [ChatMessage]
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
}

let WORKOUT_STORE = [
    Workout(
        id:"SFCF.2014.09.11",
        name: "SFCF 2014.09.11",
        description: "Fran",
        groupID: "sfcf",
        chatMessages: [],
        scoreTemplate: WorkoutScoreType.Time,
        athleteResults: [
            AthleteResult(userID: "tony", score: WorkoutScore(type: .Time, value: 250)),
            AthleteResult(userID: "carl", score: WorkoutScore(type: .Time, value: 300)),
            AthleteResult(userID: "nate", score: WorkoutScore(type: .Time, value: 350)),
            AthleteResult(userID: "nick", score: WorkoutScore(type: .Time, value: 400)),
            AthleteResult(userID: "joey", score: WorkoutScore(type: .Time, value: 500))
            
        ]),
    Workout(
        id:"SFCF.2014.09.12",
        name: "SFCF 2014.09.12",
        description: "Cindy",
        groupID: "sfcf",
        chatMessages: [],
        scoreTemplate: WorkoutScoreType.Rounds,
        athleteResults: [
            AthleteResult(userID: "tony", score: WorkoutScore(type: .Rounds, value: 20)),
            AthleteResult(userID: "nate", score: WorkoutScore(type: .Rounds, value: 20)),
            AthleteResult(userID: "carl", score: WorkoutScore(type: .Rounds, value: 25)),
            AthleteResult(userID: "nick", score: WorkoutScore(type: .Rounds, value: 15)),
            AthleteResult(userID: "joey", score: WorkoutScore(type: .Rounds, value: 17))
            
        ]),
    Workout(
        id:"SFCF.2014.09.12",
        name: "SFCF 2014.09.12",
        description: "Karen",
        groupID: "sfcf",
        chatMessages: [],
        scoreTemplate: WorkoutScoreType.Time,
        athleteResults: [
            AthleteResult(userID: "tony", score: WorkoutScore(type: .Time, value: 600)),
            AthleteResult(userID: "carl", score: WorkoutScore(type: .Time, value: 500)),
            AthleteResult(userID: "nick", score: WorkoutScore(type: .Time, value: 430)),
            AthleteResult(userID: "nate", score: WorkoutScore(type: .Time, value: 300)),
            AthleteResult(userID: "joey", score: WorkoutScore(type: .Time, value: 470))
            
        ])
    
]

let workoutIDs = WORKOUT_STORE.map({ $0.id })
let GROUP_STORE = [
    "sfcf": Group(name: "San Francisco Crossfit", id: "sfcf", location: "San Francisco", workoutIDs: workoutIDs)
]

// Global database of users
let USER_STORE = [
    "nate" : User(id: "nate", name: "Nate", profileImgName: "nate", groupIDs: ["sfcf"]),
    "tony" : User(id: "tony", name: "Tony", profileImgName: "tony", groupIDs: ["sfcf"]),
    "carl" : User(id: "carl", name: "Carl", profileImgName: "carl", groupIDs: ["sfcf"]),
    "nick" : User(id: "nick", name: "Nick", profileImgName: "nick", groupIDs: ["sfcf"]),
    "joey" : User(id: "joey", name: "Joey", profileImgName: "joey", groupIDs: ["sfcf"])
]

// TODO: This should be a proper singleton
var LOGGED_IN_USER = USER_STORE["carl"]
