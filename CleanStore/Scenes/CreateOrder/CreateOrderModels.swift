//
//  CreateOrderModels.swift
//  CleanStore
//
//  Created by Raymond Law on 8/22/15.
//  Copyright (c) 2015 Raymond Law. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit

struct CreateOrder
{
  struct FormatExpirationDate
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
}
