//
//  CreateWorkoutViewController.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/18/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

class CreateWorkoutViewController: UIViewController {

    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var scoreType: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scoreType.selectedSegmentIndex = WorkoutScoreType.Time.toRaw()
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSubmitButton(sender: AnyObject) {
        let workout : [String : AnyObject] = [
            "name" : nameField.text,
            "description" : descriptionField.text,
            "groupID" : "sfcf",
            "scoreTemplate" : scoreType.selectedSegmentIndex
        ]
        Workout.saveFirebaseWorkout(workout)
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
