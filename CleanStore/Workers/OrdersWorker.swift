import Foundation

// MARK: - Orders worker

class OrdersWorker {
  var ordersStore: OrdersStoreProtocol
  
  init(ordersStore: OrdersStoreProtocol) {
    self.ordersStore = ordersStore
  }
  
  func fetchOrders(completionHandler: (orders: [Order]) -> Void) {
    ordersStore.fetchOrders { (orders: () throws -> [Order]) -> Void in
      do {
        let orders = try orders()
        completionHandler(orders: orders)
      } catch {
        completionHandler(orders: [])
      }
    }
  }
}

// MARK: - Orders store API

protocol OrdersStoreProtocol {
  // MARK: CRUD operations - Optional error
  
  func fetchOrders(completionHandler: (orders: [Order], error: OrdersStoreError?) -> Void)
  func fetchOrder(id: String, completionHandler: (order: Order?, error: OrdersStoreError?) -> Void)
  func createOrder(orderToCreate: Order, completionHandler: (error: OrdersStoreError?) -> Void)
  func updateOrder(orderToUpdate: Order, completionHandler: (error: OrdersStoreError?) -> Void)
  func deleteOrder(id: String, completionHandler: (error: OrdersStoreError?) -> Void)
  
  // MARK: CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: OrdersStoreFetchOrdersCompletionHandler)
  func fetchOrder(id: String, completionHandler: OrdersStoreFetchOrderCompletionHandler)
  func createOrder(orderToCreate: Order, completionHandler: OrdersStoreCreateOrderCompletionHandler)
  func updateOrder(orderToUpdate: Order, completionHandler: OrdersStoreUpdateOrderCompletionHandler)
  func deleteOrder(id: String, completionHandler: OrdersStoreDeleteOrderCompletionHandler)
  
  // MARK: CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: (orders: () throws -> [Order]) -> Void)
  func fetchOrder(id: String, completionHandler: (order: () throws -> Order?) -> Void)
  func createOrder(orderToCreate: Order, completionHandler: (done: () throws -> Void) -> Void)
  func updateOrder(orderToUpdate: Order, completionHandler: (done: () throws -> Void) -> Void)
  func deleteOrder(id: String, completionHandler: (done: () throws -> Void) -> Void)
}

// MARK: - Orders store CRUD operation results

typealias OrdersStoreFetchOrdersCompletionHandler = (result: OrdersStoreResult<[Order]>) -> Void
typealias OrdersStoreFetchOrderCompletionHandler = (result: OrdersStoreResult<Order>) -> Void
typealias OrdersStoreCreateOrderCompletionHandler = (result: OrdersStoreResult<Void>) -> Void
typealias OrdersStoreUpdateOrderCompletionHandler = (result: OrdersStoreResult<Void>) -> Void
typealias OrdersStoreDeleteOrderCompletionHandler = (result: OrdersStoreResult<Void>) -> Void

enum OrdersStoreResult<U> {
  case Success(result: U)
  case Failure(error: OrdersStoreError)
}

// MARK: - Orders store CRUD operation errors

enum OrdersStoreError: Equatable, ErrorType {
  case CannotFetch(String)
  case CannotCreate(String)
  case CannotUpdate(String)
  case CannotDelete(String)
}

func ==(lhs: OrdersStoreError, rhs: OrdersStoreError) -> Bool {
  switch (lhs, rhs) {
  case (.CannotFetch(let a), .CannotFetch(let b)) where a == b: return true
  case (.CannotCreate(let a), .CannotCreate(let b)) where a == b: return true
  case (.CannotUpdate(let a), .CannotUpdate(let b)) where a == b: return true
  case (.CannotDelete(let a), .CannotDelete(let b)) where a == b: return true
  default: return false
  }
}
