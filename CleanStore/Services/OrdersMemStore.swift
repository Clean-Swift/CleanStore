import Foundation

class OrdersMemStore: OrdersStoreProtocol
{
  // MARK: - Data
  
  var orders = [
  Order(id: "abc123", date: Date(), email: "amy.apple@clean-swift.com", firstName: "Amy", lastName: "Apple", total: NSDecimalNumber(string: "1.23")),
  Order(id: "def456", date: Date(), email: "bob.battery@clean-swift.com", firstName: "Bob", lastName: "Battery", total: NSDecimalNumber(string: "4.56"))
  ]
  
  // MARK: - CRUD operations - Optional error
  
  func fetchOrders(_ completionHandler: @escaping (_ orders: [Order], _ error: OrdersStoreError?) -> Void)
  {
    completionHandler(orders, nil)
  }
  
  func fetchOrder(_ id: String, completionHandler: @escaping (_ order: Order?, _ error: OrdersStoreError?) -> Void)
  {
    let order = orders.filter { (order: Order) -> Bool in
      return order.id == id
    }.first
    if let _ = order {
      completionHandler(order, nil)
    } else {
      completionHandler(nil, OrdersStoreError.cannotFetch("Cannot fetch order with id \(id)"))
    }
  }
  
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  {
    orders.append(orderToCreate)
    completionHandler(nil)
  }
  
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  {
    for var order in orders {
      if order.id == orderToUpdate.id {
        order = orderToUpdate
        completionHandler(nil)
        return
      }
    }
    completionHandler(OrdersStoreError.cannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update"))
  }
  
  func deleteOrder(_ id: String, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  {
    let index = orders.index { (order: Order) -> Bool in
      return order.id == id
    }
    if let index = index {
      orders.remove(at: index)
      completionHandler(nil)
      return
    }
    completionHandler(OrdersStoreError.cannotDelete("Cannot fetch order with id \(id) to delete"))
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(_ completionHandler: @escaping OrdersStoreFetchOrdersCompletionHandler)
  {
    completionHandler(OrdersStoreResult.success(result: orders))
  }
  
  func fetchOrder(_ id: String, completionHandler: @escaping OrdersStoreFetchOrderCompletionHandler)
  {
    let order = orders.filter { (order: Order) -> Bool in
      return order.id == id
      }.first
    if let order = order {
      completionHandler(OrdersStoreResult.success(result: order))
    } else {
      completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotFetch("Cannot fetch order with id \(id)")))
    }
  }
  
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping OrdersStoreCreateOrderCompletionHandler)
  {
    orders.append(orderToCreate)
    completionHandler(OrdersStoreResult.success(result: ()))
  }
  
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping OrdersStoreUpdateOrderCompletionHandler)
  {
    for var order in orders {
      if order.id == orderToUpdate.id {
        order = orderToUpdate
        completionHandler(OrdersStoreResult.success(result: ()))
        return
      }
    }
    completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotUpdate("Cannot update order with id \(orderToUpdate.id) to update")))
  }
  
  func deleteOrder(_ id: String, completionHandler: @escaping OrdersStoreDeleteOrderCompletionHandler)
  {
    let index = orders.index { (order: Order) -> Bool in
      return order.id == id
    }
    if let index = index {
      orders.remove(at: index)
      completionHandler(OrdersStoreResult.success(result: ()))
      return
    }
    completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotDelete("Cannot delete order with id \(id) to delete")))
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(_ completionHandler: @escaping (_ orders: () throws -> [Order]) -> Void)
  {
    completionHandler { return self.orders }
  }
  
  func fetchOrder(_ id: String, completionHandler: @escaping (_ order: () throws -> Order?) -> Void)
  {
    let index = orders.index { (order: Order) -> Bool in
      return order.id == id
    }
    if let index = index {
      completionHandler { return self.orders[index] }
    } else {
      completionHandler { throw OrdersStoreError.cannotFetch("Cannot fetch order with id \(id)") }
    }
  }
  
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  {
    orders.append(orderToCreate)
    completionHandler { return }
  }
  
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  {
    let index = orders.index { (order: Order) -> Bool in
      return order.id == orderToUpdate.id
    }
    if let index = index {
      orders[index] = orderToUpdate
      completionHandler { return }
    } else {
      completionHandler { throw OrdersStoreError.cannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update") }
    }
  }
  
  func deleteOrder(_ id: String, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  {
    let index = orders.index { (order: Order) -> Bool in
      return order.id == id
    }
    if let index = index {
      orders.remove(at: index)
      completionHandler { return }
    } else {
      completionHandler { throw OrdersStoreError.cannotDelete("Cannot fetch order with id \(id) to delete") }
    }
  }
}
