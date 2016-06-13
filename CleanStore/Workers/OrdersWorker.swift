import Foundation

// MARK: - Orders worker

class OrdersWorker
{
  var ordersStore: OrdersStoreProtocol
  
  init(ordersStore: OrdersStoreProtocol)
  {
    self.ordersStore = ordersStore
  }
  
  func fetchOrders(completionHandler: (orders: [Order]) -> Void)
  {
    ordersStore.fetchOrders { (orders: () throws -> [Order]) -> Void in
      do {
        let orders = try orders()
        dispatch_async(dispatch_get_main_queue()) {
          completionHandler(orders: orders)
        }
      } catch {
        dispatch_async(dispatch_get_main_queue()) {
          completionHandler(orders: [])
        }
      }
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: (order: Order?) -> Void)
  {
    ordersStore.createOrder(orderToCreate) { (order: () throws -> Order?) -> Void in
      do {
        let order = try order()
        dispatch_async(dispatch_get_main_queue()) {
          completionHandler(order: order)
        }
      } catch {
        dispatch_async(dispatch_get_main_queue()) {
          completionHandler(order: nil)
        }
      }
    }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (order: Order?) -> Void)
  {
    ordersStore.updateOrder(orderToUpdate) { (order: () throws -> Order?) in
      do {
        let order = try order()
        dispatch_async(dispatch_get_main_queue()) {
          completionHandler(order: order)
        }
      } catch {
        dispatch_async(dispatch_get_main_queue()) {
          completionHandler(order: nil)
        }
      }
    }
  }
}

// MARK: - Orders store API

protocol OrdersStoreProtocol
{
  // MARK: CRUD operations - Optional error
  
  func fetchOrders(completionHandler: (fetchedOrders: [Order], error: OrdersStoreError?) -> Void)
  func fetchOrder(id: String, completionHandler: (fetchedOrder: Order?, error: OrdersStoreError?) -> Void)
  func createOrder(orderToCreate: Order, completionHandler: (createdOrder: Order?, error: OrdersStoreError?) -> Void)
  func updateOrder(orderToUpdate: Order, completionHandler: (updatedOrder: Order?, error: OrdersStoreError?) -> Void)
  func deleteOrder(id: String, completionHandler: (deletedOrder: Order?, error: OrdersStoreError?) -> Void)
  
  // MARK: CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: OrdersStoreFetchOrdersCompletionHandler)
  func fetchOrder(id: String, completionHandler: OrdersStoreFetchOrderCompletionHandler)
  func createOrder(orderToCreate: Order, completionHandler: OrdersStoreCreateOrderCompletionHandler)
  func updateOrder(orderToUpdate: Order, completionHandler: OrdersStoreUpdateOrderCompletionHandler)
  func deleteOrder(id: String, completionHandler: OrdersStoreDeleteOrderCompletionHandler)
  
  // MARK: CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: (fetchedOrders: () throws -> [Order]) -> Void)
  func fetchOrder(id: String, completionHandler: (fetchedOrder: () throws -> Order?) -> Void)
  func createOrder(orderToCreate: Order, completionHandler: (createdOrder: () throws -> Order?) -> Void)
  func updateOrder(orderToUpdate: Order, completionHandler: (updatedOrder: () throws -> Order?) -> Void)
  func deleteOrder(id: String, completionHandler: (deletedOrder: () throws -> Order?) -> Void)
}

protocol OrdersStoreUtilityProtocol {}

extension OrdersStoreUtilityProtocol
{
  func generateOrderID(inout order: Order)
  {
    guard order.id == nil else { return }
    order.id = "\(rand())"
  }
  
  func calculateOrderTotal(inout order: Order)
  {
    guard order.total == NSDecimalNumber.notANumber() else { return }
    order.total = NSDecimalNumber.one()
  }
}

// MARK: - Orders store CRUD operation results

typealias OrdersStoreFetchOrdersCompletionHandler = (result: OrdersStoreResult<[Order]>) -> Void
typealias OrdersStoreFetchOrderCompletionHandler = (result: OrdersStoreResult<Order>) -> Void
typealias OrdersStoreCreateOrderCompletionHandler = (result: OrdersStoreResult<Order>) -> Void
typealias OrdersStoreUpdateOrderCompletionHandler = (result: OrdersStoreResult<Order>) -> Void
typealias OrdersStoreDeleteOrderCompletionHandler = (result: OrdersStoreResult<Order>) -> Void

enum OrdersStoreResult<U>
{
  case Success(result: U)
  case Failure(error: OrdersStoreError)
}

// MARK: - Orders store CRUD operation errors

enum OrdersStoreError: Equatable, ErrorType
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
