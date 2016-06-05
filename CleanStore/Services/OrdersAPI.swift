import Foundation

class OrdersAPI: OrdersStoreProtocol, OrdersStoreUtilityProtocol
{
  // MARK: - CRUD operations - Optional error
  
  func fetchOrders(completionHandler: (fetchedOrders: [Order], error: OrdersStoreError?) -> Void)
  {
  }
  
  func fetchOrder(id: String, completionHandler: (fetchedOrder: Order?, error: OrdersStoreError?) -> Void)
  {
  }
  
  func createOrder(orderToCreate: Order, completionHandler: (createdOrder: Order?, error: OrdersStoreError?) -> Void)
  {
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (updatedOrder: Order?, error: OrdersStoreError?) -> Void)
  {
  }
  
  func deleteOrder(id: String, completionHandler: (deletedOrder: Order?, error: OrdersStoreError?) -> Void)
  {
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: OrdersStoreFetchOrdersCompletionHandler)
  {
  }
  
  func fetchOrder(id: String, completionHandler: OrdersStoreFetchOrderCompletionHandler)
  {
  }
  
  func createOrder(orderToCreate: Order, completionHandler: OrdersStoreCreateOrderCompletionHandler)
  {
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: OrdersStoreUpdateOrderCompletionHandler)
  {
  }
  
  func deleteOrder(id: String, completionHandler: OrdersStoreDeleteOrderCompletionHandler)
  {
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: (fetchedOrders: () throws -> [Order]) -> Void)
  {
  }
  
  func fetchOrder(id: String, completionHandler: (fetchedOrder: () throws -> Order?) -> Void)
  {
  }
  
  func createOrder(orderToCreate: Order, completionHandler: (createdOrder: () throws -> Order?) -> Void)
  {
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (updatedOrder: () throws -> Order?) -> Void)
  {
  }
  
  func deleteOrder(id: String, completionHandler: (deletedOrder: () throws -> Order?) -> Void)
  {
  }
}
