//
//  ManagedOrder+CoreDataProperties.swift
//  CleanStore
//
//  Created by Raymond Law on 11/24/15.
//  Copyright © 2015 Raymond Law. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ManagedOrder {

    @NSManaged var date: Date?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var id: String?
    @NSManaged var lastName: String?
    @NSManaged var total: NSDecimalNumber?

}
