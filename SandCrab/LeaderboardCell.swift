//
//  LeaderboardCell.swift
//  SandCrab
//
//  Created by Anthony Sherbondy on 9/1/14.
//  Copyright (c) 2014 Sutro Labs. All rights reserved.
//

import UIKit

class LeaderboardCell: UITableViewCell {

    @IBOutlet weak var buddyLabel: UILabel!
    @IBOutlet weak var buddyProfileImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
