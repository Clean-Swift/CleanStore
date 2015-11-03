protocol OrdersStoreProtocol
{
  func fetchOrders(completionHandler: (orders: [Order]) -> Void)
}

class OrdersWorker
{
  var ordersStore: OrdersStoreProtocol
  
  init(ordersStore: OrdersStoreProtocol)
  {
    self.ordersStore = ordersStore
  }
  
  func fetchOrders(completionHandler: (orders: [Order]) -> Void)
  {
    ordersStore.fetchOrders { (orders: [Order]) -> Void in
      completionHandler(orders: orders)
    }
  }
}
