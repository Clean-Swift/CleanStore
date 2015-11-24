@testable import CleanStore
import XCTest

class OrdersMemStoreTests: XCTestCase
{
  // MARK: - Subject under test
  
  var sut: OrdersMemStore!
  var testOrders: [Order]!
  
  // MARK: - Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupOrdersMemStore()
  }
  
  override func tearDown()
  {
    resetOrdersMemStore()
    super.tearDown()
  }
  
  // MARK: - Test setup
  
  func setupOrdersMemStore()
  {
    sut = OrdersMemStore()
    
    testOrders = [
      Order(id: "abc123", date: NSDate(), email: "amy.apple@clean-swift.com", firstName: "Amy", lastName: "Apple", total: NSDecimalNumber(string: "1.23")),
      Order(id: "def456", date: NSDate(), email: "bob.battery@clean-swift.com", firstName: "Bob", lastName: "Battery", total: NSDecimalNumber(string: "4.56"))
    ]
    
    sut.orders = testOrders
  }
  
  func resetOrdersMemStore()
  {
    sut.orders = []
    sut = nil
  }
  
  // MARK: - Test CRUD operations - Optional error
  
  func testFetchOrdersShouldReturnListOfOrders_OptionalError()
  {
    // Given
    
    // When
    var returnedOrders = [Order]()
    let expectation = expectationWithDescription("Wait for fetchOrders() to return")
    sut.fetchOrders { (orders: [Order], error: OrdersStoreError?) -> Void in
      returnedOrders = orders
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(returnedOrders.count, testOrders.count, "fetchOrders() should return a list of orders")
    for order in returnedOrders {
      XCTAssert(testOrders.contains(order), "Returned orders should match the orders in the data store")
    }
  }
  
  func testFetchOrderShouldReturnOrder_OptionalError()
  {
    // Given
    let orderToFetch = testOrders.first!
    
    // When
    var returnedOrder: Order?
    let expectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToFetch.id!) { (order: Order?, error: OrdersStoreError?) -> Void in
      returnedOrder = order
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(returnedOrder, orderToFetch, "fetchOrder() should return an order")
  }
  
  func testCreateOrderShouldCreateNewOrder_OptionalError()
  {
    // Given
    let orderToCreate = Order(id: "ghi789", date: NSDate(), email: "colin.code@clean-swift.com", firstName: "Colin", lastName: "Code", total: NSDecimalNumber(string: "7.89"))
    
    // When
    let createOrderExpectation = expectationWithDescription("Wait for createOrder() to return")
    sut.createOrder(orderToCreate) { (error: OrdersStoreError?) -> Void in
      createOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    var createdOrder: Order?
    let fetchOrderExpectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToCreate.id!) { (order: Order?, error: OrdersStoreError?) -> Void in
      createdOrder = order
      fetchOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    XCTAssertEqual(createdOrder, orderToCreate, "createOrder() should create a new order")
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_OptionalError()
  {
    // Given
    var orderToUpdate = testOrders.first!
    let tomorrow = NSDate(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    let updateOrderExpectation = expectationWithDescription("Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate) { (error: OrdersStoreError?) -> Void in
      updateOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    var updatedOrder: Order?
    let fetchOrderExpectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToUpdate.id!) { (order: Order?, error: OrdersStoreError?) -> Void in
      updatedOrder = order
      fetchOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update an existing order")
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_OptionalError()
  {
    // Given
    let orderToDelete = testOrders.first!
    
    // When
    let deleteOrderExpectation = expectationWithDescription("Wait for deleteOrder() to return")
    sut.deleteOrder(orderToDelete.id!) { (error: OrdersStoreError?) -> Void in
      deleteOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    var deletedOrder: Order?
    var deleteOrderError: OrdersStoreError?
    let fetchOrderExpectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToDelete.id!) { (order: Order?, error: OrdersStoreError?) -> Void in
      deletedOrder = order
      deleteOrderError = error
      fetchOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    XCTAssertNil(deletedOrder, "deleteOrder() should delete an existing order")
    XCTAssertEqual(deleteOrderError, OrdersStoreError.CannotFetch("Cannot fetch order with id \(orderToDelete.id!)"), "Deleted order should not exist")
  }
  
  // MARK: - Test CRUD operations - Generic enum result type
  
  func testFetchOrdersShouldReturnListOfOrders_GenericEnumResultType()
  {
    // Given
    
    // When
    var returnedOrders = [Order]()
    let expectation = expectationWithDescription("Wait for fetchOrders() to return")
    sut.fetchOrders { (result: OrdersStoreResult<[Order]>) -> Void in
      switch (result) {
      case .Success(let orders):
        returnedOrders = orders
      case .Failure(let error):
        XCTFail("fetchOrders() should not return an error: \(error)")
      }
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(returnedOrders.count, testOrders.count, "fetchOrders() should return a list of orders")
    for order in returnedOrders {
      XCTAssert(testOrders.contains(order), "Returned orders should match the orders in the data store")
    }
  }
  
  func testFetchOrderShouldReturnOrder_GenericEnumResultType()
  {
    // Given
    let orderToFetch = testOrders.first!
    
    // When
    var returnedOrder: Order?
    let expectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToFetch.id!) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .Success(let order):
        returnedOrder = order
      case .Failure(let error):
        XCTFail("fetchOrder() should not return an error: \(error)")
      }
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(returnedOrder, orderToFetch, "fetchOrder() should return an order")
  }
  
  func testCreateOrderShouldCreateNewOrder_GenericEnumResultType()
  {
    // Given
    let orderToCreate = Order(id: "ghi789", date: NSDate(), email: "colin.code@clean-swift.com", firstName: "Colin", lastName: "Code", total: NSDecimalNumber(string: "7.89"))
    
    // When
    let createOrderExpectation = expectationWithDescription("Wait for createOrder() to return")
    sut.createOrder(orderToCreate) { (result: OrdersStoreResult<Void>) -> Void in
      switch (result) {
      case .Success:
        break;
      case .Failure(let error):
        XCTFail("createOrder() should not return an error: \(error)")
      }
      createOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    var createdOrder: Order?
    let fetchOrderExpectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToCreate.id!) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .Success(let order):
        createdOrder = order
      case .Failure(let error):
        XCTFail("fetchOrder() should not return an error: \(error)")
      }
      fetchOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    XCTAssertEqual(createdOrder, orderToCreate, "createOrder() should create a new order")
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_GenericEnumResultType()
  {
    // Given
    var orderToUpdate = testOrders.first!
    let tomorrow = NSDate(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    let updateOrderExpectation = expectationWithDescription("Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate) { (result: OrdersStoreResult<Void>) -> Void in
      switch (result) {
      case .Success:
        break;
      case .Failure(let error):
        XCTFail("updateOrder() should not return an error: \(error)")
      }
      updateOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    var updatedOrder: Order?
    let fetchOrderExpectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToUpdate.id!) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .Success(let order):
        updatedOrder = order
      case .Failure(let error):
        XCTFail("fetchOrder() should not return an error: \(error)")
      }
      fetchOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update an existing order")
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_GenericEnumResultType()
  {
    // Given
    let orderToDelete = testOrders.first!
    
    // When
    let deleteOrderExpectation = expectationWithDescription("Wait for deleteOrder() to return")
    sut.deleteOrder(orderToDelete.id!) { (result: OrdersStoreResult<Void>) -> Void in
      deleteOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    var deletedOrder: Order?
    var deleteOrderError: OrdersStoreError?
    let fetchOrderExpectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToDelete.id!) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .Success(let order):
        deletedOrder = order
      case .Failure(let error):
        deleteOrderError = error
      }
      fetchOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    XCTAssertNil(deletedOrder, "deleteOrder() should delete an existing order")
    XCTAssertEqual(deleteOrderError, OrdersStoreError.CannotFetch("Cannot fetch order with id \(orderToDelete.id!)"), "Deleted order should not exist")
  }
  
  // MARK: - Test CRUD operations - Inner closure
  
  func testFetchOrdersShouldReturnListOfOrders_InnerClosure()
  {
    // Given
    
    // When
    var returnedOrders = [Order]()
    let expectation = expectationWithDescription("Wait for fetchOrders() to return")
    sut.fetchOrders { (orders: () throws -> [Order]) -> Void in
      returnedOrders = try! orders()
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(returnedOrders.count, testOrders.count, "fetchOrders() should return a list of orders")
    for order in returnedOrders {
      XCTAssert(testOrders.contains(order), "Returned orders should match the orders in the data store")
    }
  }
  
  func testFetchOrderShouldReturnOrder_InnerClosure()
  {
    // Given
    let orderToFetch = testOrders.first!
    
    // When
    var returnedOrder: Order?
    let expectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToFetch.id!) { (order: () throws -> Order?) -> Void in
      returnedOrder = try! order()
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    XCTAssertEqual(returnedOrder, orderToFetch, "fetchOrder() should return an order")
  }
  
  func testCreateOrderShouldCreateNewOrder_InnerClosure()
  {
    // Given
    let orderToCreate = Order(id: "ghi789", date: NSDate(), email: "colin.code@clean-swift.com", firstName: "Colin", lastName: "Code", total: NSDecimalNumber(string: "7.89"))
    
    // When
    let createOrderExpectation = expectationWithDescription("Wait for createOrder() to return")
    sut.createOrder(orderToCreate) { (done: () throws -> Void) -> Void in
      try! done()
      createOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    var createdOrder: Order?
    let fetchOrderExpectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToCreate.id!) { (order: () throws -> Order?) -> Void in
      createdOrder = try! order()
      fetchOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    XCTAssertEqual(createdOrder, orderToCreate, "createOrder() should create a new order")
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_InnerClosure()
  {
    // Given
    var orderToUpdate = testOrders.first!
    let tomorrow = NSDate(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    let updateOrderExpectation = expectationWithDescription("Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate) { (done: () throws -> Void) -> Void in
      try! done()
      updateOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    var updatedOrder: Order?
    let fetchOrderExpectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToUpdate.id!) { (order: () throws -> Order?) -> Void in
      updatedOrder = try! order()
      fetchOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update an existing order")
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_InnerClosure()
  {
    // Given
    let orderToDelete = testOrders.first!
    
    // When
    let deleteOrderExpectation = expectationWithDescription("Wait for deleteOrder() to return")
    sut.deleteOrder(orderToDelete.id!) { (done: () throws -> Void) -> Void in
      try! done()
      deleteOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    // Then
    var deletedOrder: Order?
    var deleteOrderError: OrdersStoreError?
    let fetchOrderExpectation = expectationWithDescription("Wait for fetchOrder() to return")
    sut.fetchOrder(orderToDelete.id!) { (order: () throws -> Order?) -> Void in
      do {
        deletedOrder = try order()
      } catch let error as OrdersStoreError {
        deleteOrderError = error
      } catch {}
      fetchOrderExpectation.fulfill()
    }
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
    }
    
    XCTAssertNil(deletedOrder, "deleteOrder() should delete an existing order")
    XCTAssertEqual(deleteOrderError, OrdersStoreError.CannotFetch("Cannot fetch order with id \(orderToDelete.id!)"), "Deleted order should not exist")
  }
}
