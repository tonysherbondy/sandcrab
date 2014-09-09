//
//  TimelineViewController.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/5/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

// This should really be WorkoutResult and it should point to a user with ID
struct User {
    var id : String
    var name : String
    var profileImgName : String
}

// Global database of users
let USER_STORE = [
    "tony" : User(id: "tony", name: "Tony", profileImgName: "tony"),
    "carl" : User(id: "carl", name: "Carl", profileImgName: "carl"),
    "nick" : User(id: "nick", name: "Nick", profileImgName: "nick"),
    "joey" : User(id: "joey", name: "Joey", profileImgName: "joey")
]

// Imagine these workouts will eventually be subclassed because we have different types
struct WorkoutResult {
    var userID : String
    var result : Int
}

// Need a user store so that we can look up user based on ID

struct Workout {
    var name : String
    var myResult: WorkoutResult
    var friendsResults : [WorkoutResult]
    // Sort by workout, each workout result will need a type specifying how to sort it
    var sortedFriendsResults : [WorkoutResult] {
        get {
            return friendsResults
        }
    }
}

struct ChatMessage {
    var content : String
    var author : User
}

class TimelineViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, TimelineCellProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var expandedRow : Int?
    
    // Here are all the workouts that we know about:
    // - We've already associated the user with the workout
    // - The user result as well as name of workout
    // - buddies for user on workout also listed
    
    let workouts = [
        Workout(name: "Fran",
            myResult: WorkoutResult(userID: "tony", result: 250),
            friendsResults: [
                WorkoutResult(userID: "carl", result: 300),
                WorkoutResult(userID: "nick", result: 400),
                WorkoutResult(userID: "joey", result: 500)
            ]),
        Workout(name: "Cindy",
            myResult: WorkoutResult(userID: "tony", result: 20),
            friendsResults: [
                WorkoutResult(userID: "joey", result: 17),
                WorkoutResult(userID: "nick", result: 15),
                WorkoutResult(userID: "carl", result: 25)
            ]),
        Workout(name: "Karen",
            myResult: WorkoutResult(userID: "tony", result: 600),
            friendsResults: [
                WorkoutResult(userID: "carl", result: 500),
                WorkoutResult(userID: "nick", result: 430),
                WorkoutResult(userID: "joey", result: 470)
            ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let timelineCellNib = UINib(nibName: "TimelineCell", bundle: nil)
        self.collectionView.registerNib(timelineCellNib, forCellWithReuseIdentifier: "TimelineCell")
        
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()

    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TimelineCell", forIndexPath: indexPath) as TimelineCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        cell.setWorkout(workouts[indexPath.row])
        
        return cell
    }
    

    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        if let expandedRow = self.expandedRow {
            if (indexPath.row == expandedRow) {
                return CGSize(width:320,height:self.view.frame.height)
            }
        }
        return CGSize(width:320,height:362)
    }
    
    func expandRow(cell:UICollectionViewCell) {
        println("Expand row \(cell.tag)")
        self.expandedRow = cell.tag
        
        self.collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: true) { (_) -> Void in
            println("finished expanding flow layout")
        }
        let indexPath = NSIndexPath(forRow: cell.tag, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
    
    }
    
    func collapseRow(cell:UICollectionViewCell) {
        println("Collapse row \(cell.tag)")
        self.expandedRow = nil
        
        self.collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: true) { (_) -> Void in
            println("finished collapsing flow layout")
        }
    }

}
