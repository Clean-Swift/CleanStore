//
//  ManagedOrder+CoreDataProperties.swift
//  CleanStore
//
//  Created by Raymond Law on 5/13/16.
//  Copyright © 2016 Raymond Law. All rights reserved.
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
    @NSManaged var phone: String?
    @NSManaged var total: NSDecimalNumber?
    @NSManaged var billingAddressStreet1: String?
    @NSManaged var billingAddressStreet2: String?
    @NSManaged var billingAddressCity: String?
    @NSManaged var billingAddressState: String?
    @NSManaged var billingAddressZIP: String?
    @NSManaged var shipmentAddressStreet2: String?
    @NSManaged var shipmentAddressStreet1: String?
    @NSManaged var shipmentAddressState: String?
    @NSManaged var shipmentAddressCity: String?
    @NSManaged var shipmentAddressZIP: String?
    @NSManaged var paymentMethodExpirationDate: Date?
    @NSManaged var paymentMethodCVV: String?
    @NSManaged var paymentMethodCreditCardNumber: String?
    @NSManaged var shipmentMethodSpeed: NSNumber?

}
