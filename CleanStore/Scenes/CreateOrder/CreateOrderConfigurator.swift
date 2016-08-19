//
//  CreateOrderConfigurator.swift
//  CleanStore
//
//  Created by Raymond Law on 8/22/15.
//  Copyright (c) 2015 Raymond Law. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit

// MARK: Connect View, Interactor, and Presenter

extension CreateOrderViewController: CreateOrderPresenterOutput
{
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
  {
    router.passDataToNextScene(segue)
  }
}

extension CreateOrderInteractor: CreateOrderViewControllerOutput
{
}

extension CreateOrderPresenter: CreateOrderInteractorOutput
{
}

class CreateOrderConfigurator
{
  // MARK: Object lifecycle
  
  class let sharedInstance = CreateOrderConfigurator()
  
  // MARK: Configuration
  
  func configure(viewController: CreateOrderViewController)
  {
    let router = CreateOrderRouter()
    router.viewController = viewController
    
    let presenter = CreateOrderPresenter()
    presenter.output = viewController
    
    let interactor = CreateOrderInteractor()
    interactor.output = presenter
    
    viewController.output = interactor
    viewController.router = router
  }
}
