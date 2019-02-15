//
//  ManagedOrder+CoreDataProperties.swift
//  CleanStore
//
//  Created by Raymond Law on 2/13/19.
//  Copyright © 2019 Clean Swift LLC. All rights reserved.
//
//

import Foundation
import CoreData

extension ManagedOrder
{
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedOrder>
    {
        return NSFetchRequest<ManagedOrder>(entityName: "ManagedOrder")
    }

    @NSManaged public var billingAddressCity: String?
    @NSManaged public var billingAddressState: String?
    @NSManaged public var billingAddressStreet1: String?
    @NSManaged public var billingAddressStreet2: String?
    @NSManaged public var billingAddressZIP: String?
    @NSManaged public var date: Date?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: String?
    @NSManaged public var lastName: String?
    @NSManaged public var paymentMethodCreditCardNumber: String?
    @NSManaged public var paymentMethodCVV: String?
    @NSManaged public var paymentMethodExpirationDate: Date?
    @NSManaged public var phone: String?
    @NSManaged public var shipmentAddressCity: String?
    @NSManaged public var shipmentAddressState: String?
    @NSManaged public var shipmentAddressStreet1: String?
    @NSManaged public var shipmentAddressStreet2: String?
    @NSManaged public var shipmentAddressZIP: String?
    @NSManaged public var shipmentMethodSpeed: NSNumber?
    @NSManaged public var total: NSDecimalNumber?
}
