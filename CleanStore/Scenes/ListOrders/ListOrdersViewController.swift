//
//  ListOrdersViewController.swift
//  CleanStore
//
//  Created by Raymond Law on 10/31/15.
//  Copyright (c) 2015 Raymond Law. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit

protocol ListOrdersViewControllerInput {
  func displayFetchedOrders(viewModel: ListOrders_FetchOrders_ViewModel)
}

protocol ListOrdersViewControllerOutput {
  func fetchOrders(request: ListOrders_FetchOrders_Request)
}

class ListOrdersViewController: UITableViewController, ListOrdersViewControllerInput {
  var output: ListOrdersViewControllerOutput!
  var router: ListOrdersRouter!
  var displayedOrders: [ListOrders_FetchOrders_ViewModel.DisplayedOrder] = []
  
  // MARK: Object lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    ListOrdersConfigurator.sharedInstance.configure(self)
  }
  
  // MARK: View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchOrdersOnLoad()
  }
  
  // MARK: Event handling
  
  func fetchOrdersOnLoad() {
    let request = ListOrders_FetchOrders_Request()
    output.fetchOrders(request)
  }
  
  // MARK: Display logic
  
  func displayFetchedOrders(viewModel: ListOrders_FetchOrders_ViewModel) {
    displayedOrders = viewModel.displayedOrders
    tableView.reloadData()
  }
}
