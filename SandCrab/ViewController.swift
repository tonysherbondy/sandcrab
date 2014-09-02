//
//  ViewController.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/1/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    enum WorkoutResultState {
        case Timeline
        case Leaderboard
        case Chat
    }
    var workoutResultState : WorkoutResultState = .Timeline
    
    let leaderboardOffsetX : CGFloat = 100
    var timelineUIState : [String: CGRect] = ["resultBlobView": CGRectMake(0, 0, 0, 0)]
    
                            
    @IBOutlet weak var workoutResultView: UIView!
    @IBOutlet weak var leaderboardView: UIView!
    @IBOutlet weak var resultBlobView: UIView!
    @IBOutlet weak var chatView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chatView.delegate = self
        self.chatView.dataSource = self
        
        let chatCellNib = UINib(nibName: "ChatCell", bundle: nil)
        self.chatView.registerNib(chatCellNib, forCellReuseIdentifier: "ChatCell")
        
        timelineUIState["resultBlobView"] = self.resultBlobView.frame
        timelineUIState["workoutResultView"] = self.workoutResultView.frame
        timelineUIState["chatView"] = self.chatView.frame
        timelineUIState["leaderboardView"] = self.leaderboardView.frame
        
    }

    @IBAction func onSwipeRight(sender: UISwipeGestureRecognizer) {
        
        // When we swipe right let's go to leaderboard state
        switch self.workoutResultState {
        case .Timeline :
            self.workoutResultState = .Leaderboard
            UIView.animateWithDuration(
                1, animations: { () -> Void in
                    self.workoutResultView.frame = CGRectMake(0, 0, 320, self.view.frame.height)
                    
                    self.resultBlobView.center.x += self.leaderboardOffsetX
                    self.chatView.center.x += self.leaderboardOffsetX + 200
                    
                    self.leaderboardView.frame = CGRectMake(0, 0, 200, self.view.frame.height)
                    
            })
        case .Chat:
            // Go back to timeline state
            self.transitionToTimelineState()
        default:
           println("don't know this state")
        }
    }
    
    func transitionToTimelineState() {
        self.workoutResultState = .Timeline

        UIView.animateWithDuration(1, animations: { () -> Void in
            self.workoutResultView.frame = self.timelineUIState["workoutResultView"]!
            self.resultBlobView.frame = self.timelineUIState["resultBlobView"]!
            self.chatView.frame = self.timelineUIState["chatView"]!
            self.leaderboardView.frame = self.timelineUIState["leaderboardView"]!
            
        })
    }
    
    @IBAction func onSwipeLeft(sender: UISwipeGestureRecognizer) {
        
        switch self.workoutResultState {
        case .Timeline:
            self.workoutResultState = .Chat
            UIView.animateWithDuration(
                1, animations: { () -> Void in
                    self.workoutResultView.frame = CGRectMake(0, 0, 320, self.view.frame.height)
                    
                    self.resultBlobView.center.x -= self.leaderboardOffsetX
                    self.chatView.frame = CGRectMake(100, 0, 220, self.view.frame.height)
                    
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
        let cell : ChatCell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as ChatCell
        cell.chatLabel.text = "Great PR dude!!"
        return cell
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 200
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 100
    }
    
 }

