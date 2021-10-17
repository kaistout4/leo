//
//  RoomCell.swift
//  Leo
//
//  Created by Kai Stout on 9/29/21.
//

import UIKit

class RoomCell: UITableViewCell {
    
    
    @IBOutlet weak var roomTitle: UILabel!
    
    @IBOutlet weak var questionCount: UILabel!
    
    var roomID: String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
