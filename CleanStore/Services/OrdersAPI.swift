import Foundation

class OrdersAPI: OrdersStoreProtocol
{
  // MARK: - CRUD operations - Optional error
  
  func fetchOrders(_ completionHandler: @escaping (_ orders: [Order], _ error: OrdersStoreError?) -> Void)
  {
  }
  
  func fetchOrder(_ id: String, completionHandler: @escaping (_ order: Order?, _ error: OrdersStoreError?) -> Void)
  {
  }
  
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  {
  }
  
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  {
  }
  
  func deleteOrder(_ id: String, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  {
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(_ completionHandler: @escaping OrdersStoreFetchOrdersCompletionHandler)
  {
  }
  
  func fetchOrder(_ id: String, completionHandler: @escaping OrdersStoreFetchOrderCompletionHandler)
  {
  }
  
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping OrdersStoreCreateOrderCompletionHandler)
  {
  }
  
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping OrdersStoreUpdateOrderCompletionHandler)
  {
  }
  
  func deleteOrder(_ id: String, completionHandler: @escaping OrdersStoreDeleteOrderCompletionHandler)
  {
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(_ completionHandler: @escaping (_ orders: () throws -> [Order]) -> Void)
  {
  }
  
  func fetchOrder(_ id: String, completionHandler: @escaping (_ order: () throws -> Order?) -> Void)
  {
  }
  
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  {
  }
  
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  {
  }
  
  func deleteOrder(_ id: String, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  {
  }
}
