//
//  DetailAmentiesCell.swift
//  Demo
//
//  Created by JJ on 07/10/22.
//

import UIKit

class DetailAmentiesCell: UITableViewCell {
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgAmenitites: UIImageView!
    @IBOutlet weak var lblAmenties: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewMain.layer.cornerRadius = viewMain.frame.size.height / 2.0
        viewMain.layer.borderWidth = 1.0
        viewMain.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
