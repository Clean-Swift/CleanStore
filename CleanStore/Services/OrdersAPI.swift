import Foundation

class OrdersAPI: OrdersStoreProtocol, OrdersStoreUtilityProtocol
{
  // MARK: - CRUD operations - Optional error
  
  func fetchOrders(completionHandler: @escaping ([Order], OrdersStoreError?) -> Void)
  {
  }
  
  func fetchOrder(id: String, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
  }
  
  func createOrder(orderToCreate: Order, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
  }
  
  func deleteOrder(id: String, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: @escaping OrdersStoreFetchOrdersCompletionHandler)
  {
  }
  
  func fetchOrder(id: String, completionHandler: @escaping OrdersStoreFetchOrderCompletionHandler)
  {
  }
  
  func createOrder(orderToCreate: Order, completionHandler: @escaping OrdersStoreCreateOrderCompletionHandler)
  {
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping OrdersStoreUpdateOrderCompletionHandler)
  {
  }
  
  func deleteOrder(id: String, completionHandler: @escaping OrdersStoreDeleteOrderCompletionHandler)
  {
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: @escaping (() throws -> [Order]) -> Void)
  {
  }
  
  func fetchOrder(id: String, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
  }
  
  func createOrder(orderToCreate: Order, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
  }
  
  func deleteOrder(id: String, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
  }
}
