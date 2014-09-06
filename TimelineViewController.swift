//
//  TimelineViewController.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/5/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TimelineCellProtocol {
    
    @IBOutlet weak var timelineTableView: UITableView!

    var expandedRow : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.timelineTableView.dataSource = self
        self.timelineTableView.delegate = self
        
        let timelineCellNib = UINib(nibName: "TimelineCell", bundle: nil)
        self.timelineTableView.registerNib(timelineCellNib, forCellReuseIdentifier: "TimelineCell")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath) as TimelineCell
        cell.delegate = self
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if let expandedRow = self.expandedRow {
            if (indexPath.row == expandedRow) {
                return self.view.frame.height
            }
        }
        return 362
    }
    
    func expandRow(cell:UITableViewCell) {
        println("Expand row \(cell.tag)")
        
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LeaderboardViewController") as LeaderboardViewController
//        self.presentViewController(vc, animated: true) { () -> Void in
//            // on complete
//        }
        
    
        self.expandedRow = cell.tag
        let indexPath = NSIndexPath(forRow: cell.tag, inSection: 0)
        //self.timelineTableView.reloadRowsAtIndexPaths([indexPath] as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)

//        self.timelineTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated:true)
    
    }
    
    func collapseRow(cell:UITableViewCell) {
        println("Collapse row \(cell.tag)")
        self.expandedRow = nil
        
        let indexPath = NSIndexPath(forRow: cell.tag, inSection: 0)
        self.timelineTableView.reloadRowsAtIndexPaths([indexPath] as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
    }

}
