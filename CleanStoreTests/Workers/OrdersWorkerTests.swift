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
    
    override func fetchOrders(completionHandler: @escaping (() throws -> [Order]) -> Void)
    {
      fetchOrdersCalled = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
        completionHandler { () -> [Order] in
          return OrdersWorkerTests.testOrders
        }
      }
    }
    
    override func createOrder(orderToCreate: Order, completionHandler: @escaping (() throws -> Order?) -> Void)
    {
      createOrderCalled = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
        completionHandler { () -> Order in
          return OrdersWorkerTests.testOrders.first!
        }
      }
    }
    
    override func updateOrder(orderToUpdate: Order, completionHandler: @escaping (() throws -> Order?) -> Void)
    {
      updateOrderCalled = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
        completionHandler { () -> Order in
          return OrdersWorkerTests.testOrders.first!
        }
      }
    }
  }
  
  // MARK: - Tests
  
  func testFetchOrdersShouldReturnListOfOrders()
  {
    // Given
    let ordersMemStoreSpy = sut.ordersStore as! OrdersMemStoreSpy
    
    // When
    var fetchedOrders = [Order]()
    let expect = expectation(description: "Wait for fetchOrders() to return")
    sut.fetchOrders { (orders) in
      fetchedOrders = orders
      expect.fulfill()
    }
    waitForExpectations(timeout: 1.1)
    
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
    let expect = expectation(description: "Wait for createOrder() to return")
    sut.createOrder(orderToCreate: orderToCreate) { (order) in
      createdOrder = order
      expect.fulfill()
    }
    waitForExpectations(timeout: 1.1)
    
    // Then
    XCTAssert(ordersMemStoreSpy.createOrderCalled, "Calling createOrder() should ask the data store to create the new order")
    XCTAssertEqual(createdOrder, orderToCreate, "createOrder() should create the new order")
  }
  
  func testUpdateOrderShouldReturnTheUpdatedOrder()
  {
    // Given
    let ordersMemStoreSpy = sut.ordersStore as! OrdersMemStoreSpy
    var orderToUpdate = OrdersWorkerTests.testOrders.first!
    let tomorrow = Date(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    var updatedOrder: Order?
    let expect = expectation(description: "Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate: orderToUpdate) { (order) in
      updatedOrder = order
      expect.fulfill()
    }
    waitForExpectations(timeout: 1.1)
    
    // Then
    XCTAssert(ordersMemStoreSpy.updateOrderCalled, "Calling updateOrder() should ask the data store to update the existing order")
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update the existing order")
  }
}
