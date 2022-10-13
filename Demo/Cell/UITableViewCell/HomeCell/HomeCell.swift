//
//  HomeCell.swift
//  Demo
//
//  Created by JJ on 07/10/22.
//

import UIKit

class HomeCell: UITableViewCell {
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var lblGymName: UILabel!
    @IBOutlet weak var imgGymLogo: UIImageView!
    @IBOutlet weak var lblGymAddress: UILabel!
    @IBOutlet weak var lblGymDistance: UILabel!
    @IBOutlet weak var btnGymAccess: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewMain.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
