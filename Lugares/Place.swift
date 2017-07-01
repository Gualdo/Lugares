//
//  Place.swift
//  Lugares
//
//  Created by Eduardo De La Cruz on 24/4/17.
//  Copyright © 2017 Eduardo De La Cruz. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Place : NSManagedObject
{
    @NSManaged var name : String
    @NSManaged var type : String
    @NSManaged var location : String
    @NSManaged var image : NSData?
    @NSManaged var rating : String?
    @NSManaged var telephone : String?
    @NSManaged var website : String?
}
