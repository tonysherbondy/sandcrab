//
//  TimelineViewController.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/5/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, TimelineCellProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var expandedRow : Int?
    let workouts : WorkoutList = WorkoutList()
    
    @IBAction func onCloseButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func onAddWorkoutButton(sender: UIButton) {
        var workout : [String : AnyObject] = [
            "name" : "SFCF 12.09.2014",
            "description" : "Fran",
            "groupID" : "sfcf",
            "scoreTemplate" : WorkoutScoreType.Time.toRaw()
        ]
        Workout.saveFirebaseWorkout(workout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.workouts.observeUpdates({
            println("workouts updated")
            self.collectionView.reloadData()
        })
        
        self.addListeners()
       
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let timelineCellNib = UINib(nibName: "TimelineCell", bundle: nil)
        self.collectionView.registerNib(timelineCellNib, forCellWithReuseIdentifier: "TimelineCell")
        
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()

    }
    
    func addListeners() {
    NSNotificationCenter.defaultCenter().addObserverForName("UserDidLogoutNotification", object: nil, queue: nil) { _ in
            // this should pop back to login screen
            println("user logout notification")
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func removeListeners() {
        // TODO: cleanup any listeners here...
    }
    
    
    
    // MARK: - UICollectionViewDataSource
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TimelineCell", forIndexPath: indexPath) as TimelineCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        cell.setWorkout(workouts.list[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("workouts count \(workouts.list.count)")
        return workouts.list.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
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
