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
    let workouts = WORKOUT_STORE
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let timelineCellNib = UINib(nibName: "TimelineCell", bundle: nil)
        self.collectionView.registerNib(timelineCellNib, forCellWithReuseIdentifier: "TimelineCell")
        
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()

    }
    
    // MARK: - UICollectionViewDataSource
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TimelineCell", forIndexPath: indexPath) as TimelineCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        cell.setWorkout(workouts[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return workouts.count
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
