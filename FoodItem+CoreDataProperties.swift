//
//  FoodItem+CoreDataProperties.swift
//  FeedThePiggy
//
//  Created by Ya Kao on 10/1/16.
//  Copyright © 2016 Betsy Kao. All rights reserved.
//

import Foundation
import CoreData


extension FoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItem> {
        return NSFetchRequest<FoodItem>(entityName: "FoodItem");
    }

    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var currentTotal: Double
    @NSManaged public var creationdate: NSDate?
    @NSManaged public var enddate: NSDate?
    @NSManaged public var goal: Double
    @NSManaged public var goalSet: Bool
    @NSManaged public var enddateSet: Bool

}
