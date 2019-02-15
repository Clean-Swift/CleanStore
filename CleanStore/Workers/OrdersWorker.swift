//
//  OrdersWorker.swift
//  CleanStore
//
//  Created by Raymond Law on 2/12/19.
//  Copyright © 2019 Clean Swift LLC. All rights reserved.
//

import Foundation

class OrdersWorker
{
  var ordersStore: OrdersStoreProtocol
  
  init(ordersStore: OrdersStoreProtocol)
  {
    self.ordersStore = ordersStore
  }
  
  func fetchOrders(completionHandler: @escaping ([Order]) -> Void)
  {
    ordersStore.fetchOrders { (orders: () throws -> [Order]) -> Void in
      do {
        let orders = try orders()
        DispatchQueue.main.async {
          completionHandler(orders)
        }
      } catch {
        DispatchQueue.main.async {
          completionHandler([])
        }
      }
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: @escaping (Order?) -> Void)
  {
    ordersStore.createOrder(orderToCreate: orderToCreate) { (order: () throws -> Order?) -> Void in
      do {
        let order = try order()
        DispatchQueue.main.async {
          completionHandler(order)
        }
      } catch {
        DispatchQueue.main.async {
          completionHandler(nil)
        }
      }
    }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping (Order?) -> Void)
  {
    ordersStore.updateOrder(orderToUpdate: orderToUpdate) { (order: () throws -> Order?) in
      do {
        let order = try order()
        DispatchQueue.main.async {
          completionHandler(order)
        }
      } catch {
        DispatchQueue.main.async {
          completionHandler(nil)
        }
      }
    }
  }
}

// MARK: - Orders store API

protocol OrdersStoreProtocol
{
  // MARK: CRUD operations - Optional error
  
  func fetchOrders(completionHandler: @escaping ([Order], OrdersStoreError?) -> Void)
  func fetchOrder(id: String, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  func createOrder(orderToCreate: Order, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  func deleteOrder(id: String, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  
  // MARK: CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: @escaping OrdersStoreFetchOrdersCompletionHandler)
  func fetchOrder(id: String, completionHandler: @escaping OrdersStoreFetchOrderCompletionHandler)
  func createOrder(orderToCreate: Order, completionHandler: @escaping OrdersStoreCreateOrderCompletionHandler)
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping OrdersStoreUpdateOrderCompletionHandler)
  func deleteOrder(id: String, completionHandler: @escaping OrdersStoreDeleteOrderCompletionHandler)
  
  // MARK: CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: @escaping (() throws -> [Order]) -> Void)
  func fetchOrder(id: String, completionHandler: @escaping (() throws -> Order?) -> Void)
  func createOrder(orderToCreate: Order, completionHandler: @escaping (() throws -> Order?) -> Void)
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping (() throws -> Order?) -> Void)
  func deleteOrder(id: String, completionHandler: @escaping (() throws -> Order?) -> Void)
}

protocol OrdersStoreUtilityProtocol {}

extension OrdersStoreUtilityProtocol
{
  func generateOrderID(order: inout Order)
  {
    guard order.id == nil else { return }
    order.id = "\(arc4random())"
  }
  
  func calculateOrderTotal(order: inout Order)
  {
    guard order.total == NSDecimalNumber.notANumber else { return }
    order.total = NSDecimalNumber.one
  }
}

// MARK: - Orders store CRUD operation results

typealias OrdersStoreFetchOrdersCompletionHandler = (OrdersStoreResult<[Order]>) -> Void
typealias OrdersStoreFetchOrderCompletionHandler = (OrdersStoreResult<Order>) -> Void
typealias OrdersStoreCreateOrderCompletionHandler = (OrdersStoreResult<Order>) -> Void
typealias OrdersStoreUpdateOrderCompletionHandler = (OrdersStoreResult<Order>) -> Void
typealias OrdersStoreDeleteOrderCompletionHandler = (OrdersStoreResult<Order>) -> Void

enum OrdersStoreResult<U>
{
  case Success(result: U)
  case Failure(error: OrdersStoreError)
}

// MARK: - Orders store CRUD operation errors

enum OrdersStoreError: Equatable, Error
{
  case CannotFetch(String)
  case CannotCreate(String)
  case CannotUpdate(String)
  case CannotDelete(String)
}

func ==(lhs: OrdersStoreError, rhs: OrdersStoreError) -> Bool
{
  switch (lhs, rhs) {
  case (.CannotFetch(let a), .CannotFetch(let b)) where a == b: return true
  case (.CannotCreate(let a), .CannotCreate(let b)) where a == b: return true
  case (.CannotUpdate(let a), .CannotUpdate(let b)) where a == b: return true
  case (.CannotDelete(let a), .CannotDelete(let b)) where a == b: return true
  default: return false
  }
}
