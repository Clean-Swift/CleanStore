class OrdersMemStore: OrdersStoreProtocol
{
  var orders = [Order]()
  
  func fetchOrders(completionHandler: (orders: [Order]) -> Void)
  {
    completionHandler(orders: orders)
  }
}
