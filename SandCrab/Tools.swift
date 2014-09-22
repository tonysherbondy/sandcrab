//
//  Tools.swift
//  SandCrab
//
//  Created by Nicolas Halper on 9/22/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

class Tools {
    
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}
