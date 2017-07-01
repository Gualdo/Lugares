//
//  PlaceDetailViewCell.swift
//  MisRecetas
//
//  Created by Eduardo D De La Cruz Marr on 22/2/17.
//  Copyright © 2017 Eduardo D De La Cruz Marrero. All rights reserved.
//

import UIKit

class PlaceDetailViewCell: UITableViewCell
{
    //MARK: - Global Variables
    
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    //MARK: - Predefined methods
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
