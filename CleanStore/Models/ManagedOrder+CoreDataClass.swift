//
//  ManagedOrder+CoreDataClass.swift
//  CleanStore
//
//  Created by Raymond Law on 2/13/19.
//  Copyright © 2019 Clean Swift LLC. All rights reserved.
//
//

import Foundation
import CoreData

public class ManagedOrder: NSManagedObject
{
  func toOrder() -> Order
  {
    let billingAddress = Address(street1: billingAddressStreet1!, street2: billingAddressStreet2!, city: billingAddressCity!, state: billingAddressState!, zip: billingAddressZIP!)
    let shipmentAddress = Address(street1: shipmentAddressStreet1!, street2: shipmentAddressStreet2!, city: shipmentAddressCity!, state: shipmentAddressState!, zip: shipmentAddressZIP!)
    let paymentMethod = PaymentMethod(creditCardNumber: paymentMethodCreditCardNumber!, expirationDate: paymentMethodExpirationDate!, cvv: paymentMethodCVV!)
    let shipmentMethod = ShipmentMethod(speed: .Standard)
    
    return Order(firstName: firstName!, lastName: lastName!, phone: phone!, email: email!, billingAddress: billingAddress, paymentMethod: paymentMethod, shipmentAddress: shipmentAddress, shipmentMethod: shipmentMethod, id: id, date: date!, total: total!)
  }
  
  func fromOrder(order: Order)
  {
    firstName = order.firstName
    lastName = order.lastName
    phone = order.phone
    email = order.email
    
    billingAddressStreet1 = order.billingAddress.street1
    billingAddressStreet2 = order.billingAddress.street2
    billingAddressCity = order.billingAddress.city
    billingAddressState = order.billingAddress.state
    billingAddressZIP = order.billingAddress.zip
    
    paymentMethodCreditCardNumber = order.paymentMethod.creditCardNumber
    paymentMethodExpirationDate = order.paymentMethod.expirationDate
    paymentMethodCVV = order.paymentMethod.cvv
    
    shipmentAddressStreet1 = order.shipmentAddress.street1
    shipmentAddressStreet2 = order.shipmentAddress.street2
    shipmentAddressCity = order.shipmentAddress.city
    shipmentAddressState = order.shipmentAddress.state
    shipmentAddressZIP = order.shipmentAddress.zip
    
    shipmentMethodSpeed = NSNumber(integerLiteral: order.shipmentMethod.speed.rawValue)
    
    id = order.id
    date = order.date
    total = order.total
  }
}
