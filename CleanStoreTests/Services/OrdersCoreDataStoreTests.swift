@testable import CleanStore
import XCTest
import CoreData

class OrdersCoreDataStoreTests: XCTestCase
{
  // MARK: - Subject under test
  
  var sut: OrdersCoreDataStore!
  var testOrders: [Order]!
  
  // MARK: - Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupOrdersCoreDataStore()
  }
  
  override func tearDown()
  {
    sut = nil
    super.tearDown()
  }
  
  // MARK: - Test setup
  
  func setupOrdersCoreDataStore()
  {
    sut = OrdersCoreDataStore()
    
    deleteAllOrdersInOrdersCoreDataStore()
    
    testOrders = [Seeds.Orders.amy, Seeds.Orders.bob]
    
    for order in testOrders {
      let expectation = expectationWithDescription("Wait for createOrder() to return")
      sut.createOrder(order) { (order: () throws -> Order?) -> Void in
        expectation.fulfill()
      }
      waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
      }
    }
  }
  
  func deleteAllOrdersInOrdersCoreDataStore()
  {
    var allOrders = [Order]()
    let fetchOrdersExpectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrders { (orders: () throws -> [Order]) -> Void in
      allOrders = try! orders()
      fetchOrdersExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    for order in allOrders {
      let deleteOrderExpectation = expectationWithDescription("Wait for deleteOrder() to return")
      self.sut.deleteOrder(order.id!) { (order: () throws -> Order?) -> Void in
        deleteOrderExpectation.fulfill()
      }
      waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
      }
    }
  }
  
  // MARK: - Test CRUD operations - Optional error
  
  func testFetchOrdersShouldReturnListOfOrders_OptionalError()
  {
    // Given
    
    // When
    var fetchedOrders = [Order]()
    var fetchOrdersError: OrdersStoreError?
    let expectation = expectationWithDescription("Wait for fetchOrders() to return")
    sut.fetchOrders { (orders: [Order], error: OrdersStoreError?) -> Void in
      fetchedOrders = orders
      fetchOrdersError = error
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(fetchedOrders.count, testOrders.count, "fetchOrders() should return a list of orders")
    for order in fetchedOrders {
      XCTAssert(testOrders.contains(order), "Fetched orders should match the orders in the data store")
    }
    XCTAssertNil(fetchOrdersError, "fetchOrders() should not return an error")
  }
  
  func testFetchOrderShouldReturnOrder_OptionalError()
  {
    // Given
    let orderToFetch = testOrders.first!
    
    // When
    var fetchedOrder: Order?
    var fetchOrderError: OrdersStoreError?
    let expectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToFetch.id!) { (order: Order?, error: OrdersStoreError?) -> Void in
      fetchedOrder = order
      fetchOrderError = error
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(fetchedOrder, orderToFetch, "fetchOrder() should return an order")
    XCTAssertNil(fetchOrderError, "fetchOrder() should not return an error")
  }
  
  func testCreateOrderShouldCreateNewOrder_OptionalError()
  {
    // Given
    let orderToCreate = Seeds.Orders.chris
    
    // When
    var createdOrder: Order?
    var creatOrderError: OrdersStoreError?
    let createOrderExpectation = expectationWithDescription("Wait for createOrder() to return")
    sut.createOrder(orderToCreate) { (returnedOrder: Order?, error: OrdersStoreError?) -> Void in
      createdOrder = returnedOrder
      creatOrderError = error
      createOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(createdOrder, orderToCreate, "createOrder() should create a new order")
    XCTAssertNil(creatOrderError, "createOrder() should not return an error")
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_OptionalError()
  {
    // Given
    var orderToUpdate = testOrders.first!
    let tomorrow = NSDate(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    var updatedOrder: Order?
    var updatOrderError: OrdersStoreError?
    let updateOrderExpectation = expectationWithDescription("Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate) { (returnedOrder: Order?, error: OrdersStoreError?) -> Void in
      updatedOrder = returnedOrder
      updatOrderError = error
      updateOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update an existing order")
    XCTAssertNil(updatOrderError, "updateOrder() should not return an error")
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_OptionalError()
  {
    // Given
    let orderToDelete = testOrders.first!
    
    // When
    var deletedOrder: Order?
    var deletOrderError: OrdersStoreError?
    let deleteOrderExpectation = expectationWithDescription("Wait for deleteOrder() to return")
    sut.deleteOrder(orderToDelete.id!) { (returnedOrder: Order?, error: OrdersStoreError?) -> Void in
      deletedOrder = returnedOrder
      deletOrderError = error
      deleteOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(deletedOrder, orderToDelete, "deleteOrder() should delete an existing order")
    XCTAssertNil(deletOrderError, "deleteOrder() should not return an error")
  }
  
  // MARK: - Test CRUD operations - Generic enum result type
  
  func testFetchOrdersShouldReturnListOfOrders_GenericEnumResultType()
  {
    // Given
    
    // When
    var fetchedOrders = [Order]()
    var fetchOrdersError: OrdersStoreError?
    let expectation = expectationWithDescription("Wait for fetchOrders() to return")
    sut.fetchOrders { (result: OrdersStoreResult<[Order]>) -> Void in
      switch (result) {
      case .Success(let orders):
        fetchedOrders = orders
      case .Failure(let error):
        fetchOrdersError = error
        XCTFail("fetchOrders() should not return an error: \(error)")
      }
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(fetchedOrders.count, testOrders.count, "fetchOrders() should return a list of orders")
    for order in fetchedOrders {
      XCTAssert(testOrders.contains(order), "Fetched orders should match the orders in the data store")
    }
    XCTAssertNil(fetchOrdersError, "fetchOrders() should not return an error")
  }
  
  func testFetchOrderShouldReturnOrder_GenericEnumResultType()
  {
    // Given
    let orderToFetch = testOrders.first!
    
    // When
    var fetchedOrder: Order?
    var fetchOrderError: OrdersStoreError?
    let expectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToFetch.id!) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .Success(let order):
        fetchedOrder = order
      case .Failure(let error):
        fetchOrderError = error
        XCTFail("fetchOrder() should not return an error: \(error)")
      }
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(fetchedOrder, orderToFetch, "fetchOrder() should return an order")
    XCTAssertNil(fetchOrderError, "fetchOrder() should not return an error")
  }
  
  func testCreateOrderShouldCreateNewOrder_GenericEnumResultType()
  {
    // Given
    let orderToCreate = Seeds.Orders.chris
    
    // When
    var createdOrder: Order?
    var creatOrderError: OrdersStoreError?
    let createOrderExpectation = expectationWithDescription("Wait for createOrder() to return")
    sut.createOrder(orderToCreate) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .Success(let returnedOrder):
        createdOrder = returnedOrder
      case .Failure(let error):
        creatOrderError = error
        XCTFail("createOrder() should not return an error: \(error)")
      }
      createOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(createdOrder, orderToCreate, "createOrder() should create a new order")
    XCTAssertNil(creatOrderError, "createOrder() should not return an error")
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_GenericEnumResultType()
  {
    // Given
    var orderToUpdate = testOrders.first!
    let tomorrow = NSDate(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    var updatedOrder: Order?
    var updatOrderError: OrdersStoreError?
    let updateOrderExpectation = expectationWithDescription("Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .Success(let returnedOrder):
        updatedOrder = returnedOrder
      case .Failure(let error):
        updatOrderError = error
        XCTFail("updateOrder() should not return an error: \(error)")
      }
      updateOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update an existing order")
    XCTAssertNil(updatOrderError, "updateOrder() should not return an error")
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_GenericEnumResultType()
  {
    // Given
    let orderToDelete = testOrders.first!
    
    // When
    var deletedOrder: Order?
    var deleteOrderError: OrdersStoreError?
    let deleteOrderExpectation = expectationWithDescription("Wait for deleteOrder() to return")
    sut.deleteOrder(orderToDelete.id!) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .Success(let returnedOrder):
        deletedOrder = returnedOrder
        break
      case .Failure(let error):
        deleteOrderError = error
      }
      deleteOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(deletedOrder, orderToDelete, "deleteOrder() should delete an existing order")
    XCTAssertNil(deleteOrderError, "deleteOrder() should not return an error")
  }
  
  // MARK: - Test CRUD operations - Inner closure
  
  func testFetchOrdersShouldReturnListOfOrders_InnerClosure()
  {
    // Given
    
    // When
    var fetchedOrders = [Order]()
    var fetchOrdersError: OrdersStoreError?
    let expectation = expectationWithDescription("Wait for fetchOrders() to return")
    sut.fetchOrders { (orders: () throws -> [Order]) -> Void in
      do {
        fetchedOrders = try orders()
      } catch let error as OrdersStoreError {
        fetchOrdersError = error
      } catch {}
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(fetchedOrders.count, testOrders.count, "fetchOrders() should return a list of orders")
    for order in fetchedOrders {
      XCTAssert(testOrders.contains(order), "Fetched orders should match the orders in the data store")
    }
    XCTAssertNil(fetchOrdersError, "fetchOrders() should not return an error")
  }
  
  func testFetchOrderShouldReturnOrder_InnerClosure()
  {
    // Given
    let orderToFetch = testOrders.first!
    
    // When
    var fetchedOrder: Order?
    var fetchOrderError: OrdersStoreError?
    let expectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToFetch.id!) { (order: () throws -> Order?) -> Void in
      do {
        fetchedOrder = try order()
      } catch let error as OrdersStoreError {
        fetchOrderError = error
      } catch {}
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(fetchedOrder, orderToFetch, "fetchOrder() should return an order")
    XCTAssertNil(fetchOrderError, "fetchOrder() should not return an error")
  }
  
  func testCreateOrderShouldCreateNewOrder_InnerClosure()
  {
    // Given
    let orderToCreate = Seeds.Orders.chris
    
    // When
    var createdOrder: Order?
    var creatOrderError: OrdersStoreError?
    let createOrderExpectation = expectationWithDescription("Wait for createOrder() to return")
    sut.createOrder(orderToCreate) { (order: () throws -> Order?) -> Void in
      try! order()
      do {
        createdOrder = try order()
      } catch let error as OrdersStoreError {
        creatOrderError = error
      } catch {}
      createOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(createdOrder, orderToCreate, "createOrder() should create a new order")
    XCTAssertNil(creatOrderError, "createOrder() should not return an error")
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_InnerClosure()
  {
    // Given
    var orderToUpdate = testOrders.first!
    let tomorrow = NSDate(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    var updatedOrder: Order?
    var updatOrderError: OrdersStoreError?
    let updateOrderExpectation = expectationWithDescription("Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate) { (order: () throws -> Order?) -> Void in
      do {
        updatedOrder = try order()
      } catch let error as OrdersStoreError {
        updatOrderError = error
      } catch {}
      updateOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update an existing order")
    XCTAssertNil(updatOrderError, "updateOrder() should not return an error")
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_InnerClosure()
  {
    // Given
    let orderToDelete = testOrders.first!
    
    // When
    var deletedOrder: Order?
    var deleteOrderError: OrdersStoreError?
    let deleteOrderExpectation = expectationWithDescription("Wait for deleteOrder() to return")
    sut.deleteOrder(orderToDelete.id!) { (order: () throws -> Order?) -> Void in
      do {
        deletedOrder = try order()
      } catch let error as OrdersStoreError {
        deleteOrderError = error
      } catch {}
      deleteOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(deletedOrder, orderToDelete, "deleteOrder() should delete an existing order")
    XCTAssertNil(deleteOrderError, "deleteOrder() should not return an error")
  }
}
