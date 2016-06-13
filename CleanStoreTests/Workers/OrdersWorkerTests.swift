@testable import CleanStore
import XCTest

class OrdersWorkerTests: XCTestCase
{
  // MARK: - Subject under test
  
  var sut: OrdersWorker!
  static var testOrders: [Order]!
  
  // MARK: - Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupOrdersWorker()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: - Test setup
  
  func setupOrdersWorker()
  {
    sut = OrdersWorker(ordersStore: OrdersMemStoreSpy())
    
    OrdersWorkerTests.testOrders = [Seeds.Orders.amy, Seeds.Orders.bob]
  }
  
  // MARK: - Test doubles
  
  class OrdersMemStoreSpy: OrdersMemStore
  {
    // MARK: Method call expectations
    var fetchOrdersCalled = false
    var createOrderCalled = false
    var updateOrderCalled = false
    
    // MARK: Spied methods
    override func fetchOrders(completionHandler: (orders: () throws -> [Order]) -> Void)
    {
      fetchOrdersCalled = true
      let oneSecond = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
      dispatch_after(oneSecond, dispatch_get_main_queue(), {
        completionHandler {
          return OrdersWorkerTests.testOrders
        }
      })
    }
    
    override func createOrder(orderToCreate: Order, completionHandler: (createdOrder: () throws -> Order?) -> Void)
    {
      createOrderCalled = true
      let oneSecond = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
      dispatch_after(oneSecond, dispatch_get_main_queue(), {
        completionHandler {
          return OrdersWorkerTests.testOrders.first!
        }
      })
    }
    
    override func updateOrder(orderToUpdate: Order, completionHandler: (updatedOrder: () throws -> Order?) -> Void)
    {
      updateOrderCalled = true
      let oneSecond = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
      dispatch_after(oneSecond, dispatch_get_main_queue(), {
        completionHandler {
          return OrdersWorkerTests.testOrders.first!
        }
      })
    }
  }
  
  // MARK: - Tests
  
  func testFetchOrdersShouldReturnListOfOrders()
  {
    // Given
    let ordersMemStoreSpy = sut.ordersStore as! OrdersMemStoreSpy
    
    // When
    var fetchedOrders = [Order]()
    let expectation = expectationWithDescription("Wait for fetchOrders() to return")
    sut.fetchOrders { (orders) in
      fetchedOrders = orders
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.1) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssert(ordersMemStoreSpy.fetchOrdersCalled, "Calling fetchOrders() should ask the data store for a list of orders")
    XCTAssertEqual(fetchedOrders.count, OrdersWorkerTests.testOrders.count, "fetchOrders() should return a list of orders")
    for order in fetchedOrders {
      XCTAssert(OrdersWorkerTests.testOrders.contains(order), "Fetched orders should match the orders in the data store")
    }
  }
  
  func testCreateOrderShouldReturnTheCreatedOrder()
  {
    // Given
    let ordersMemStoreSpy = sut.ordersStore as! OrdersMemStoreSpy
    let orderToCreate = OrdersWorkerTests.testOrders.first!
    
    // When
    var createdOrder: Order?
    let expectation = expectationWithDescription("Wait for createOrder() to return")
    sut.createOrder(orderToCreate) { (order) in
      createdOrder = order
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.1) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssert(ordersMemStoreSpy.createOrderCalled, "Calling createOrder() should ask the data store to create the new order")
    XCTAssertEqual(createdOrder, orderToCreate, "createOrder() should create the new order")
  }
  
  func testUpdateOrderShouldReturnTheUpdatedOrder()
  {
    // Given
    let ordersMemStoreSpy = sut.ordersStore as! OrdersMemStoreSpy
    var orderToUpdate = OrdersWorkerTests.testOrders.first!
    let tomorrow = NSDate(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    var updatedOrder: Order?
    let expectation = expectationWithDescription("Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate) { (order) in
      updatedOrder = order
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.1) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssert(ordersMemStoreSpy.updateOrderCalled, "Calling updateOrder() should ask the data store to update the existing order")
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update the existing order")
  }
}
