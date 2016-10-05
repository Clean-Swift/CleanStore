import Foundation

// MARK: - Orders worker

class OrdersWorker
{
  var ordersStore: OrdersStoreProtocol
  
  init(ordersStore: OrdersStoreProtocol)
  {
    self.ordersStore = ordersStore
  }
  
  func fetchOrders(_ completionHandler: @escaping (_ orders: [Order]) -> Void)
  {
    ordersStore.fetchOrders { (orders: () throws -> [Order]) -> Void in
      do {
        let orders = try orders()
        completionHandler(orders)
      } catch {
        completionHandler([])
      }
    }
  }
}

// MARK: - Orders store API

protocol OrdersStoreProtocol
{
  // MARK: CRUD operations - Optional error
  
  func fetchOrders(_ completionHandler: @escaping (_ orders: [Order], _ error: OrdersStoreError?) -> Void)
  func fetchOrder(_ id: String, completionHandler: @escaping (_ order: Order?, _ error: OrdersStoreError?) -> Void)
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  func deleteOrder(_ id: String, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  
  // MARK: CRUD operations - Generic enum result type
  
  func fetchOrders(_ completionHandler: @escaping OrdersStoreFetchOrdersCompletionHandler)
  func fetchOrder(_ id: String, completionHandler: @escaping OrdersStoreFetchOrderCompletionHandler)
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping OrdersStoreCreateOrderCompletionHandler)
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping OrdersStoreUpdateOrderCompletionHandler)
  func deleteOrder(_ id: String, completionHandler: @escaping OrdersStoreDeleteOrderCompletionHandler)
  
  // MARK: CRUD operations - Inner closure
  
  func fetchOrders(_ completionHandler: @escaping (_ orders: () throws -> [Order]) -> Void)
  func fetchOrder(_ id: String, completionHandler: @escaping (_ order: () throws -> Order?) -> Void)
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  func deleteOrder(_ id: String, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
}

// MARK: - Orders store CRUD operation results

typealias OrdersStoreFetchOrdersCompletionHandler = (_ result: OrdersStoreResult<[Order]>) -> Void
typealias OrdersStoreFetchOrderCompletionHandler = (_ result: OrdersStoreResult<Order>) -> Void
typealias OrdersStoreCreateOrderCompletionHandler = (_ result: OrdersStoreResult<Void>) -> Void
typealias OrdersStoreUpdateOrderCompletionHandler = (_ result: OrdersStoreResult<Void>) -> Void
typealias OrdersStoreDeleteOrderCompletionHandler = (_ result: OrdersStoreResult<Void>) -> Void

enum OrdersStoreResult<U>
{
  case success(result: U)
  case failure(error: OrdersStoreError)
}

// MARK: - Orders store CRUD operation errors

enum OrdersStoreError: Equatable, Error
{
  case cannotFetch(String)
  case cannotCreate(String)
  case cannotUpdate(String)
  case cannotDelete(String)
}

func ==(lhs: OrdersStoreError, rhs: OrdersStoreError) -> Bool
{
  switch (lhs, rhs) {
  case (.cannotFetch(let a), .cannotFetch(let b)) where a == b: return true
  case (.cannotCreate(let a), .cannotCreate(let b)) where a == b: return true
  case (.cannotUpdate(let a), .cannotUpdate(let b)) where a == b: return true
  case (.cannotDelete(let a), .cannotDelete(let b)) where a == b: return true
  default: return false
  }
}
