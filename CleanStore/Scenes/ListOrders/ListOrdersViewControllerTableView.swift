//
//  ListOrdersViewControllerTableView.swift
//  CleanStore
//
//  Created by Mati on 22/1/16.
//  Copyright © 2016 Raymond Law. All rights reserved.
//

import UIKit

extension ListOrdersViewController {
  
  // MARK: Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayedOrders.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("OrderTableViewCell")
    if cell == nil {
      cell = UITableViewCell(style: .Value1, reuseIdentifier: "OrderTableViewCell")
    }
    let displayedOrder = displayedOrders[indexPath.row]
    cell?.textLabel?.text = displayedOrder.date
    cell?.detailTextLabel?.text = displayedOrder.total
    return cell!
  }
}