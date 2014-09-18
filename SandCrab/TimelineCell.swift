//
//  TimelineCell.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/5/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

protocol TimelineCellProtocol {
    func expandRow(cell:UICollectionViewCell)
    func collapseRow(cell:UICollectionViewCell)
}

class TimelineCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var workoutResultView: UIView!
    @IBOutlet weak var resultBlobView: UIView!
    @IBOutlet weak var leaderboardView: UITableView!
    @IBOutlet weak var chatView: UITableView!
    @IBOutlet weak var workoutNameLabel: UILabel!
    
    var friendsResults : [AthleteResult]?
    var workout : Workout?
    
    func setWorkout(workout: Workout) {
        self.workout = workout
        workoutNameLabel.text = workout.name
        friendsResults = workout.sortedFriendsResults
    }
    
    var delegate : TimelineCellProtocol?
    
    enum WorkoutResultState {
        case Timeline
        case Leaderboard
        case Chat
    }
    var workoutResultState : WorkoutResultState = .Timeline
    
    let leaderboardOffsetX : CGFloat = 100
    var timelineUIState : [String: CGRect] = ["resultBlobView": CGRectMake(0, 0, 0, 0)]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.chatView.delegate = self
        self.chatView.dataSource = self
        
        self.leaderboardView.delegate = self
        self.leaderboardView.dataSource = self
        
        let chatCellNib = UINib(nibName: "ChatCell", bundle: nil)
        self.chatView.registerNib(chatCellNib, forCellReuseIdentifier: "ChatCell")
        let leaderboardCellNib = UINib(nibName: "LeaderboardCell", bundle: nil)
        self.leaderboardView.registerNib(leaderboardCellNib, forCellReuseIdentifier: "LeaderboardCell")
        
        
        timelineUIState["resultBlobView"] = self.resultBlobView.frame
        timelineUIState["workoutResultView"] = self.workoutResultView.frame
        timelineUIState["chatView"] = self.chatView.frame
        timelineUIState["leaderboardView"] = self.leaderboardView.frame
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "onSwipeRight:")
        self.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "onSwipeLeft:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
        
    }
    
    func transitionToTimelineState() {
        self.workoutResultState = .Timeline
        
        self.delegate?.collapseRow(self)
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.workoutResultView.frame = self.timelineUIState["workoutResultView"]!
            self.resultBlobView.frame = self.timelineUIState["resultBlobView"]!
            self.chatView.frame = self.timelineUIState["chatView"]!
            self.leaderboardView.frame = self.timelineUIState["leaderboardView"]!
            
        })
    }
    
    func onSwipeRight(sender: UISwipeGestureRecognizer) {
        // When we swipe right let's go to leaderboard state
        switch self.workoutResultState {
        case .Timeline :
            self.workoutResultState = .Leaderboard
            self.delegate?.expandRow(self)
            
            UIView.animateWithDuration(
                1, animations: { () -> Void in
                    self.workoutResultView.frame = CGRectMake(0, 0, 320, UIScreen.mainScreen().bounds.height)
                    
                    self.resultBlobView.center.x += self.leaderboardOffsetX
                    self.chatView.center.x += self.leaderboardOffsetX + 200
                    
                    self.leaderboardView.frame = CGRectMake(0, 0, 200, UIScreen.mainScreen().bounds.height)
                    
            })
        case .Chat:
            // Go back to timeline state
            self.transitionToTimelineState()
        default:
            println("don't know this state")
        }

    }
    
    func onSwipeLeft(sender: UISwipeGestureRecognizer) {
        
        switch self.workoutResultState {
        case .Timeline:
            self.workoutResultState = .Chat
            self.delegate?.expandRow(self)
            
            UIView.animateWithDuration(
                1, animations: { () -> Void in
                    self.workoutResultView.frame = CGRectMake(0, 0, 320, UIScreen.mainScreen().bounds.height)
                    
                    self.resultBlobView.center.x -= self.leaderboardOffsetX
                    self.chatView.frame = CGRectMake(100, 0, 220, UIScreen.mainScreen().bounds.height)
                    
                    self.leaderboardView.center.x -= 200
                    
            })
            
        case .Leaderboard:
            // Go back to timeline state
            self.transitionToTimelineState()
        default:
            println("don't recognize this state")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.leaderboardView {
            let cell : LeaderboardCell = tableView.dequeueReusableCellWithIdentifier("LeaderboardCell", forIndexPath: indexPath) as LeaderboardCell
            
            if let result = (friendsResults?[indexPath.row]) {
                if let user = USER_STORE[result.userID] {
                    cell.buddyLabel.text = "\(user.fullName) - \(result.score.scoreDescription())"
                    cell.buddyProfileImageView.image = UIImage(named: user.profileImgName)

                }
            }
            
            return cell
        } else {
            let cell : ChatCell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as ChatCell
            cell.chatLabel.text = "Great PR dude!!"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.leaderboardView {
            if let count = friendsResults?.count {
                return count
            }
            return 0
        } else {
            return 20
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.leaderboardView {
            return 50
        } else {
            return 100
        }
    }

}
