//
//  CreateOrderInteractor.swift
//  CleanStore
//
//  Created by Raymond Law on 8/22/15.
//  Copyright (c) 2015 Raymond Law. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit

protocol CreateOrderInteractorInput
{
  var shippingMethods: [String] { get }
  func formatExpirationDate(_ request: CreateOrder.FormatExpirationDate.Request)
}

protocol CreateOrderInteractorOutput
{
  func presentExpirationDate(_ response: CreateOrder.FormatExpirationDate.Response)
}

class CreateOrderInteractor: CreateOrderInteractorInput
{
  var output: CreateOrderInteractorOutput!
  var worker: CreateOrderWorker!
  var shippingMethods = [
    "Standard Shipping",
    "Two-Day Shipping",
    "One-Day Shipping"
  ]
  
  // MARK: Expiration date
  
  func formatExpirationDate(_ request: CreateOrder.FormatExpirationDate.Request)
  {
    let response = CreateOrder.FormatExpirationDate.Response(date: request.date)
    output.presentExpirationDate(response)
  }
}
