import Foundation

class OrdersAPI: OrdersStoreProtocol {
  // MARK: - CRUD operations - Optional error
  
  func fetchOrders(completionHandler: (orders: [Order], error: OrdersStoreError?) -> Void) {
  }
  
  func fetchOrder(id: String, completionHandler: (order: Order?, error: OrdersStoreError?) -> Void) {
  }
  
  func createOrder(orderToCreate: Order, completionHandler: (error: OrdersStoreError?) -> Void) {
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (error: OrdersStoreError?) -> Void) {
  }
  
  func deleteOrder(id: String, completionHandler: (error: OrdersStoreError?) -> Void) {
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: OrdersStoreFetchOrdersCompletionHandler) {
  }
  
  func fetchOrder(id: String, completionHandler: OrdersStoreFetchOrderCompletionHandler) {
  }
  
  func createOrder(orderToCreate: Order, completionHandler: OrdersStoreCreateOrderCompletionHandler) {
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: OrdersStoreUpdateOrderCompletionHandler) {
  }
  
  func deleteOrder(id: String, completionHandler: OrdersStoreDeleteOrderCompletionHandler) {
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: (orders: () throws -> [Order]) -> Void) {
  }
  
  func fetchOrder(id: String, completionHandler: (order: () throws -> Order?) -> Void) {
  }
  
  func createOrder(orderToCreate: Order, completionHandler: (done: () throws -> Void) -> Void) {
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (done: () throws -> Void) -> Void) {
  }
  
  func deleteOrder(id: String, completionHandler: (done: () throws -> Void) -> Void) {
  }
}
