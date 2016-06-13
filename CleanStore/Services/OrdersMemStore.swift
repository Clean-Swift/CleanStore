import Foundation

class OrdersMemStore: OrdersStoreProtocol, OrdersStoreUtilityProtocol
{
  // MARK: - Data
  
  static var billingAddress = Address(street1: "1 Infinite Loop", street2: "", city: "Cupertino", state: "CA", zip: "95014")
  static var shipmentAddress = Address(street1: "One Microsoft Way", street2: "", city: "Redmond", state: "WA", zip: "98052-7329")
  static var paymentMethod = PaymentMethod(creditCardNumber: "1234-123456-1234", expirationDate: NSDate(), cvv: "999")
  static var shipmentMethod = ShipmentMethod(speed: .OneDay)
  
  static var orders = [
    Order(firstName: "Amy", lastName: "Apple", phone: "111-111-1111", email: "amy.apple@clean-swift.com", billingAddress: billingAddress, paymentMethod: paymentMethod, shipmentAddress: shipmentAddress, shipmentMethod: shipmentMethod, id: "abc123", date: NSDate(), total: NSDecimalNumber(string: "1.23")),
    Order(firstName: "Bob", lastName: "Battery", phone: "222-222-2222", email: "bob.battery@clean-swift.com", billingAddress: billingAddress, paymentMethod: paymentMethod, shipmentAddress: shipmentAddress, shipmentMethod: shipmentMethod, id: "def456", date: NSDate(), total: NSDecimalNumber(string: "4.56"))
  ]
  
  // MARK: - CRUD operations - Optional error
  
  func fetchOrders(completionHandler: (fetchedOrders: [Order], error: OrdersStoreError?) -> Void)
  {
    completionHandler(fetchedOrders: self.dynamicType.orders, error: nil)
  }
  
  func fetchOrder(id: String, completionHandler: (fetchedOrder: Order?, error: OrdersStoreError?) -> Void)
  {
    if let index = indexOfOrderWithID(id) {
      let order = self.dynamicType.orders[index]
      completionHandler(fetchedOrder: order, error: nil)
    } else {
      completionHandler(fetchedOrder: nil, error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)"))
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: (createdOrder: Order?, error: OrdersStoreError?) -> Void)
  {
    var order = orderToCreate
    generateOrderID(&order)
    calculateOrderTotal(&order)
    self.dynamicType.orders.append(order)
    completionHandler(createdOrder: order, error: nil)
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (updatedOrder: Order?, error: OrdersStoreError?) -> Void)
  {
    if let index = indexOfOrderWithID(orderToUpdate.id) {
      self.dynamicType.orders[index] = orderToUpdate
      let order = self.dynamicType.orders[index]
      completionHandler(updatedOrder: order, error: nil)
    } else {
      completionHandler(updatedOrder: nil, error: OrdersStoreError.CannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update"))
    }
  }
  
  func deleteOrder(id: String, completionHandler: (deletedOrder: Order?, error: OrdersStoreError?) -> Void)
  {
    if let index = indexOfOrderWithID(id) {
      let order = self.dynamicType.orders.removeAtIndex(index)
      completionHandler(deletedOrder: order, error: nil)
      return
    }
    completionHandler(deletedOrder: nil, error: OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete"))
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: OrdersStoreFetchOrdersCompletionHandler)
  {
    completionHandler(result: OrdersStoreResult.Success(result: self.dynamicType.orders))
  }
  
  func fetchOrder(id: String, completionHandler: OrdersStoreFetchOrderCompletionHandler)
  {
    let order = self.dynamicType.orders.filter { (order: Order) -> Bool in
      return order.id == id
      }.first
    if let order = order {
      completionHandler(result: OrdersStoreResult.Success(result: order))
    } else {
      completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)")))
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: OrdersStoreCreateOrderCompletionHandler)
  {
    var order = orderToCreate
    generateOrderID(&order)
    calculateOrderTotal(&order)
    self.dynamicType.orders.append(order)
    completionHandler(result: OrdersStoreResult.Success(result: order))
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: OrdersStoreUpdateOrderCompletionHandler)
  {
    if let index = indexOfOrderWithID(orderToUpdate.id) {
      self.dynamicType.orders[index] = orderToUpdate
      let order = self.dynamicType.orders[index]
      completionHandler(result: OrdersStoreResult.Success(result: order))
    } else {
      completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotUpdate("Cannot update order with id \(orderToUpdate.id) to update")))
    }
  }
  
  func deleteOrder(id: String, completionHandler: OrdersStoreDeleteOrderCompletionHandler)
  {
    if let index = indexOfOrderWithID(id) {
      let order = self.dynamicType.orders.removeAtIndex(index)
      completionHandler(result: OrdersStoreResult.Success(result: order))
      return
    }
    completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotDelete("Cannot delete order with id \(id) to delete")))
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: (fetchedOrders: () throws -> [Order]) -> Void)
  {
    completionHandler { return self.dynamicType.orders }
  }
  
  func fetchOrder(id: String, completionHandler: (fetchedOrder: () throws -> Order?) -> Void)
  {
    if let index = indexOfOrderWithID(id) {
      completionHandler { return self.dynamicType.orders[index] }
    } else {
      completionHandler { throw OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)") }
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: (createdOrder: () throws -> Order?) -> Void)
  {
    var order = orderToCreate
    generateOrderID(&order)
    calculateOrderTotal(&order)
    self.dynamicType.orders.append(order)
    completionHandler { return order }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (updatedOrder: () throws -> Order?) -> Void)
  {
    if let index = indexOfOrderWithID(orderToUpdate.id) {
      self.dynamicType.orders[index] = orderToUpdate
      let order = self.dynamicType.orders[index]
      completionHandler { return order }
    } else {
      completionHandler { throw OrdersStoreError.CannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update") }
    }
  }
  
  func deleteOrder(id: String, completionHandler: (deletedOrder: () throws -> Order?) -> Void)
  {
    if let index = indexOfOrderWithID(id) {
      let order = self.dynamicType.orders.removeAtIndex(index)
      completionHandler { return order }
    } else {
      completionHandler { throw OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete") }
    }
  }
  
  // MARK: - Convenience methods
  
  private func indexOfOrderWithID(id: String?) -> Int?
  {
    return self.dynamicType.orders.indexOf { return $0.id == id }
  }
}
