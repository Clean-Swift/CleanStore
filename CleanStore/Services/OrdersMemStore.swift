//
//  OrdersMemStore.swift
//  CleanStore
//
//  Created by Raymond Law on 2/12/19.
//  Copyright © 2019 Clean Swift LLC. All rights reserved.
//

import Foundation

class OrdersMemStore: OrdersStoreProtocol, OrdersStoreUtilityProtocol
{
  // MARK: - Data
  
  static var billingAddress = Address(street1: "1 Infinite Loop", street2: "", city: "Cupertino", state: "CA", zip: "95014")
  static var shipmentAddress = Address(street1: "One Microsoft Way", street2: "", city: "Redmond", state: "WA", zip: "98052-7329")
  static var paymentMethod = PaymentMethod(creditCardNumber: "1234-123456-1234", expirationDate: Date(), cvv: "999")
  static var shipmentMethod = ShipmentMethod(speed: .OneDay)
  
  static var orders = [
    Order(firstName: "Amy", lastName: "Apple", phone: "111-111-1111", email: "amy.apple@clean-swift.com", billingAddress: billingAddress, paymentMethod: paymentMethod, shipmentAddress: shipmentAddress, shipmentMethod: shipmentMethod, id: "abc123", date: Date(), total: NSDecimalNumber(string: "1.23")),
    Order(firstName: "Bob", lastName: "Battery", phone: "222-222-2222", email: "bob.battery@clean-swift.com", billingAddress: billingAddress, paymentMethod: paymentMethod, shipmentAddress: shipmentAddress, shipmentMethod: shipmentMethod, id: "def456", date: Date(), total: NSDecimalNumber(string: "4.56"))
  ]
  
  // MARK: - CRUD operations - Optional error
  
  func fetchOrders(completionHandler: @escaping ([Order], OrdersStoreError?) -> Void)
  {
    completionHandler(type(of: self).orders, nil)
  }
  
  func fetchOrder(id: String, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
    if let index = indexOfOrderWithID(id: id) {
      let order = type(of: self).orders[index]
      completionHandler(order, nil)
    } else {
      completionHandler(nil, OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)"))
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
    var order = orderToCreate
    generateOrderID(order: &order)
    calculateOrderTotal(order: &order)
    type(of: self).orders.append(order)
    completionHandler(order, nil)
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
    if let index = indexOfOrderWithID(id: orderToUpdate.id) {
      type(of: self).orders[index] = orderToUpdate
      let order = type(of: self).orders[index]
      completionHandler(order, nil)
    } else {
      completionHandler(nil, OrdersStoreError.CannotUpdate("Cannot fetch order with id \(String(describing: orderToUpdate.id)) to update"))
    }
  }
  
  func deleteOrder(id: String, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
    if let index = indexOfOrderWithID(id: id) {
      let order = type(of: self).orders.remove(at: index)
      completionHandler(order, nil)
      return
    }
    completionHandler(nil, OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete"))
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: @escaping OrdersStoreFetchOrdersCompletionHandler)
  {
    completionHandler(OrdersStoreResult.Success(result: type(of: self).orders))
  }
  
  func fetchOrder(id: String, completionHandler: @escaping OrdersStoreFetchOrderCompletionHandler)
  {
    let order = type(of: self).orders.filter { (order: Order) -> Bool in
      return order.id == id
      }.first
    if let order = order {
      completionHandler(OrdersStoreResult.Success(result: order))
    } else {
      completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)")))
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: @escaping OrdersStoreCreateOrderCompletionHandler)
  {
    var order = orderToCreate
    generateOrderID(order: &order)
    calculateOrderTotal(order: &order)
    type(of: self).orders.append(order)
    completionHandler(OrdersStoreResult.Success(result: order))
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping OrdersStoreUpdateOrderCompletionHandler)
  {
    if let index = indexOfOrderWithID(id: orderToUpdate.id) {
      type(of: self).orders[index] = orderToUpdate
      let order = type(of: self).orders[index]
      completionHandler(OrdersStoreResult.Success(result: order))
    } else {
      completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotUpdate("Cannot update order with id \(String(describing: orderToUpdate.id)) to update")))
    }
  }
  
  func deleteOrder(id: String, completionHandler: @escaping OrdersStoreDeleteOrderCompletionHandler)
  {
    if let index = indexOfOrderWithID(id: id) {
      let order = type(of: self).orders.remove(at: index)
      completionHandler(OrdersStoreResult.Success(result: order))
      return
    }
    completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotDelete("Cannot delete order with id \(id) to delete")))
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: @escaping (() throws -> [Order]) -> Void)
  {
    completionHandler { return type(of: self).orders }
  }
  
  func fetchOrder(id: String, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
    if let index = indexOfOrderWithID(id: id) {
      completionHandler { return type(of: self).orders[index] }
    } else {
      completionHandler { throw OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)") }
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
    var order = orderToCreate
    generateOrderID(order: &order)
    calculateOrderTotal(order: &order)
    type(of: self).orders.append(order)
    completionHandler { return order }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
    if let index = indexOfOrderWithID(id: orderToUpdate.id) {
      type(of: self).orders[index] = orderToUpdate
      let order = type(of: self).orders[index]
      completionHandler { return order }
    } else {
      completionHandler { throw OrdersStoreError.CannotUpdate("Cannot fetch order with id \(String(describing: orderToUpdate.id)) to update") }
    }
  }
  
  func deleteOrder(id: String, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
    if let index = indexOfOrderWithID(id: id) {
      let order = type(of: self).orders.remove(at: index)
      completionHandler { return order }
    } else {
      completionHandler { throw OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete") }
    }
  }

  // MARK: - Convenience methods
  
  private func indexOfOrderWithID(id: String?) -> Int?
  {
    return type(of: self).orders.firstIndex { return $0.id == id }
  }
}
