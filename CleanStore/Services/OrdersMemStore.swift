import Foundation

class OrdersMemStore: OrdersStoreProtocol
{
  // MARK: - Data
  
  var orders = [
  Order(id: "abc123", date: NSDate(), email: "amy.apple@clean-swift.com", firstName: "Amy", lastName: "Apple", total: NSDecimalNumber(string: "1.23")),
  Order(id: "def456", date: NSDate(), email: "bob.battery@clean-swift.com", firstName: "Bob", lastName: "Battery", total: NSDecimalNumber(string: "4.56"))
  ]
  
  // MARK: - CRUD operations - Optional error
  
  func fetchOrders(completionHandler: (orders: [Order], error: OrdersStoreError?) -> Void)
  {
    completionHandler(orders: orders, error: nil)
  }
  
  func fetchOrder(id: String, completionHandler: (order: Order?, error: OrdersStoreError?) -> Void)
  {
    let order = orders.filter { (order: Order) -> Bool in
      return order.id == id
    }.first
    if let _ = order {
      completionHandler(order: order, error: nil)
    } else {
      completionHandler(order: nil, error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)"))
    }
  }
  
  func createOrder(order: Order, completionHandler: (error: OrdersStoreError?) -> Void)
  {
    orders.append(order)
    completionHandler(error: nil)
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (error: OrdersStoreError?) -> Void)
  {
    for var order in orders {
      if order.id == orderToUpdate.id {
        order = orderToUpdate
        completionHandler(error: nil)
        return
      }
    }
    completionHandler(error: OrdersStoreError.CannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update"))
  }
  
  func deleteOrder(id: String, completionHandler: (error: OrdersStoreError?) -> Void)
  {
    let index = orders.indexOf { (order: Order) -> Bool in
      return order.id == id
    }
    if let index = index {
      orders.removeAtIndex(index)
      completionHandler(error: nil)
      return
    }
    completionHandler(error: OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete"))
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: OrdersStoreFetchOrdersCompletionHandler)
  {
    completionHandler(result: OrdersStoreResult.Success(result: orders))
  }
  
  func fetchOrder(id: String, completionHandler: OrdersStoreFetchOrderCompletionHandler)
  {
    let order = orders.filter { (order: Order) -> Bool in
      return order.id == id
      }.first
    if let order = order {
      completionHandler(result: OrdersStoreResult.Success(result: order))
    } else {
      completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)")))
    }
  }
  
  func createOrder(order: Order, completionHandler: OrdersStoreCreateOrderCompletionHandler)
  {
    orders.append(order)
    completionHandler(result: OrdersStoreResult.Success(result: ()))
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: OrdersStoreUpdateOrderCompletionHandler)
  {
    for var order in orders {
      if order.id == orderToUpdate.id {
        order = orderToUpdate
        completionHandler(result: OrdersStoreResult.Success(result: ()))
        return
      }
    }
    completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotUpdate("Cannot update order with id \(orderToUpdate.id) to update")))
  }
  
  func deleteOrder(id: String, completionHandler: OrdersStoreDeleteOrderCompletionHandler)
  {
    let index = orders.indexOf { (order: Order) -> Bool in
      return order.id == id
    }
    if let index = index {
      orders.removeAtIndex(index)
      completionHandler(result: OrdersStoreResult.Success(result: ()))
      return
    }
    completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotDelete("Cannot delete order with id \(id) to delete")))
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: (orders: () throws -> [Order]) -> Void)
  {
    completionHandler { return self.orders }
  }
  
  func fetchOrder(id: String, completionHandler: (order: () throws -> Order?) -> Void)
  {
    let index = orders.indexOf { (order: Order) -> Bool in
      return order.id == id
    }
    if let index = index {
      completionHandler { return self.orders[index] }
    } else {
      completionHandler { throw OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)") }
    }
  }
  
  func createOrder(order: Order, completionHandler: (done: () throws -> Void) -> Void)
  {
    orders.append(order)
    completionHandler { return }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (done: () throws -> Void) -> Void)
  {
    let index = orders.indexOf { (order: Order) -> Bool in
      return order.id == orderToUpdate.id
    }
    if let index = index {
      orders[index] = orderToUpdate
      completionHandler { return }
    } else {
      completionHandler { throw OrdersStoreError.CannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update") }
    }
  }
  
  func deleteOrder(id: String, completionHandler: (done: () throws -> Void) -> Void)
  {
    let index = orders.indexOf { (order: Order) -> Bool in
      return order.id == id
    }
    if let index = index {
      orders.removeAtIndex(index)
      completionHandler { return }
    } else {
      completionHandler { throw OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete") }
    }
  }
}
