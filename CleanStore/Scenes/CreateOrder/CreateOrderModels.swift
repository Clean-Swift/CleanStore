//
//  CreateOrderModels.swift
//  CleanStore
//
//  Created by Raymond Law on 8/22/15.
//  Copyright (c) 2015 Raymond Law. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum CreateOrder
{
  typealias OrderFormFields =
  (
    // MARK: Contact info
    firstName: String,
    lastName: String,
    phone: String,
    email: String,
    
    // MARK: Payment info
    billingAddressStreet1: String,
    billingAddressStreet2: String,
    billingAddressCity: String,
    billingAddressState: String,
    billingAddressZIP: String,
    
    paymentMethodCreditCardNumber: String,
    paymentMethodCVV: String,
    paymentMethodExpirationDate: Date,
    paymentMethodExpirationDateString: String,
    
    // MARK: Shipping info
    shipmentAddressStreet1: String,
    shipmentAddressStreet2: String,
    shipmentAddressCity: String,
    shipmentAddressState: String,
    shipmentAddressZIP: String,
    
    shipmentMethodSpeed: Int,
    shipmentMethodSpeedString: String,
    
    // MARK: Misc
    id: String?,
    date: Date,
    total: NSDecimalNumber
  )
  
  // MARK: Use cases
  
  enum FormatExpirationDate
  {
    struct Request
    {
      var date: Date
    }
    struct Response
    {
      var date: Date
    }
    struct ViewModel
    {
      var date: String
    }
  }
  
  enum EditOrder
  {
    struct Request
    {
    }
    struct Response
    {
      var order: Order
    }
    struct ViewModel
    {
      var orderFormFields: OrderFormFields
    }
  }
  
  enum CreateOrder
  {
    struct Request
    {
      var orderFormFields: OrderFormFields
    }
    struct Response
    {
      var order: Order?
    }
    struct ViewModel
    {
      var order: Order?
    }
  }
  
  enum UpdateOrder
  {
    struct Request
    {
      var orderFormFields: OrderFormFields
    }
    struct Response
    {
      var order: Order?
    }
    struct ViewModel
    {
      var order: Order?
    }
  }
}
