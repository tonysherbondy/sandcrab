//
//  TimelineCell.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/5/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

protocol TimelineCellProtocol {
    func expandRow(cell:UITableViewCell)
    func collapseRow(cell:UITableViewCell)
}

class TimelineCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var workoutResultView: UIView!
    @IBOutlet weak var resultBlobView: UIView!
    @IBOutlet weak var leaderboardView: UITableView!
    @IBOutlet weak var chatView: UITableView!
    
    var delegate : TimelineCellProtocol?
    
    enum WorkoutResultState {
        case Timeline
        case Leaderboard
        case Chat
    }
    var workoutResultState : WorkoutResultState = .Timeline
    
    let leaderboardOffsetX : CGFloat = 100
    var timelineUIState : [String: CGRect] = ["resultBlobView": CGRectMake(0, 0, 0, 0)]
    
    let buddies : [[String: AnyObject]] = [
        ["name": "Carl", "result":180],
        ["name": "Nate", "result":300],
        ["name": "Joey", "result":600],
        ["name": "Nick", "result":630]
    ]
    let myInfo: [String: AnyObject] = ["name": "Anthony", "result":220]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
                    self.workoutResultView.frame = CGRectMake(0, 0, 320, self.frame.height)
                    
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
                    self.workoutResultView.frame = CGRectMake(0, 0, 320, self.frame.height)
                    
                    self.resultBlobView.center.x -= self.leaderboardOffsetX
                    self.chatView.frame = CGRectMake(100, 0, 220, self.frame.height)
                    
                    self.leaderboardView.center.x -= 200
                    
            })
            
        case .Leaderboard:
            // Go back to timeline state
            self.transitionToTimelineState()
        default:
            println("don't recognize this state")
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if tableView == self.leaderboardView {
            let cell : LeaderboardCell = tableView.dequeueReusableCellWithIdentifier("LeaderboardCell", forIndexPath: indexPath) as LeaderboardCell
            cell.buddyLabel.text = self.buddies[indexPath.row]["name"]! as String
            return cell
        } else {
            let cell : ChatCell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as ChatCell
            cell.chatLabel.text = "Great PR dude!!"
            return cell
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.leaderboardView {
            return self.buddies.count
        } else {
            return 20
        }
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if tableView == self.leaderboardView {
            return 50
        } else {
            return 100
        }
    }

}
