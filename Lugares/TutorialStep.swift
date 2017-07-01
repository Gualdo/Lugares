//
//  TutorialStep.swift
//  Lugares
//
//  Created by Eduardo De La Cruz on 8/6/17.
//  Copyright © 2017 Eduardo De La Cruz. All rights reserved.
//

import Foundation
import UIKit

class TutorialStep : NSObject
{
    // MARK: - Global Variables
    
    var index = 0
    var heading = ""
    var content = ""
    var image : UIImage!
    
    // MARK: - Init
    
    init(index : Int, heading : String, content : String, image : UIImage)
    {
        self.index = index
        self.heading = heading
        self.content = content
        self.image = image
    }
}
