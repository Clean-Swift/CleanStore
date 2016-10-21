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
    
    testOrders = [
      Order(id: "abc123", date: Date(), email: "amy.apple@clean-swift.com", firstName: "Amy", lastName: "Apple", total: NSDecimalNumber(string: "1.23")),
      Order(id: "def456", date: Date(), email: "bob.battery@clean-swift.com", firstName: "Bob", lastName: "Battery", total: NSDecimalNumber(string: "4.56"))
    ]
    
    for order in testOrders {
      let expectation = self.expectation(description: "Wait for createOrder() to return")
      sut.createOrder(order) { (done: () throws -> Void) -> Void in
        expectation.fulfill()
      }
      waitForExpectations(timeout: 1.0) { (error) -> Void in
      }
    }
  }
  
  func deleteAllOrdersInOrdersCoreDataStore()
  {
    var allOrders = [Order]()
    let fetchOrdersExpectation = expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrders { (orders: () throws -> [Order]) -> Void in
      allOrders = try! orders()
      fetchOrdersExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    for order in allOrders {
      let deleteOrderExpectation = expectation(description: "Wait for deleteOrder() to return")
      self.sut.deleteOrder(order.id!) { (done: () throws -> Void) -> Void in
        deleteOrderExpectation.fulfill()
      }
      waitForExpectations(timeout: 1.0) { (error) -> Void in
      }
    }
  }
  
  // MARK: - Test CRUD operations - Optional error
  
  func testFetchOrdersShouldReturnListOfOrders_OptionalError()
  {
    // Given
    
    // When
    var returnedOrders = [Order]()
    let expectation = self.expectation(description: "Wait for fetchOrders() to return")
    sut.fetchOrders { (orders: [Order], error: OrdersStoreError?) -> Void in
      returnedOrders = orders
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
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
    let expectation = self.expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToFetch.id!) { (order: Order?, error: OrdersStoreError?) -> Void in
      returnedOrder = order
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    XCTAssertEqual(returnedOrder, orderToFetch, "fetchOrder() should return an order")
  }
  
  func testCreateOrderShouldCreateNewOrder_OptionalError()
  {
    // Given
    let orderToCreate = Order(id: "ghi789", date: Date(), email: "colin.code@clean-swift.com", firstName: "Colin", lastName: "Code", total: NSDecimalNumber(string: "7.89"))
    
    // When
    let createOrderExpectation = self.expectation(description: "Wait for createOrder() to return")
    sut.createOrder(orderToCreate) { (error: OrdersStoreError?) -> Void in
      createOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    var returnedOrder: Order?
    let expectation = self.expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToCreate.id!) { (order: () throws -> Order?) -> Void in
      returnedOrder = try! order()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    XCTAssertEqual(returnedOrder, orderToCreate, "createOrder() should create a new order")
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_OptionalError()
  {
    // Given
    var orderToUpdate = testOrders.first!
    let tomorrow = Date(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    let updateOrderExpectation = expectation(description: "Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate) { (error: OrdersStoreError?) -> Void in
      updateOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    var updatedOrder: Order?
    let fetchOrderExpectation = expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToUpdate.id!) { (order: Order?, error: OrdersStoreError?) -> Void in
      updatedOrder = order
      fetchOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update an existing order")
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_OptionalError()
  {
    // Given
    let orderToDelete = testOrders.first!
    
    // When
    let deleteOrderExpectation = expectation(description: "Wait for deleteOrder() to return")
    sut.deleteOrder(orderToDelete.id!) { (error: OrdersStoreError?) -> Void in
      deleteOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    var deletedOrder: Order?
    var deleteOrderError: OrdersStoreError?
    let fetchOrderExpectation = expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToDelete.id!) { (order: Order?, error: OrdersStoreError?) -> Void in
      deletedOrder = order
      deleteOrderError = error
      fetchOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    XCTAssertNil(deletedOrder, "deleteOrder() should delete an existing order")
    XCTAssertEqual(deleteOrderError, OrdersStoreError.cannotFetch("Cannot fetch order with id \(orderToDelete.id!)"), "Deleted order should not exist")
  }
  
  // MARK: - Test CRUD operations - Generic enum result type
  
  func testFetchOrdersShouldReturnListOfOrders_GenericEnumResultType()
  {
    // Given
    
    // When
    var returnedOrders = [Order]()
    let expectation = self.expectation(description: "Wait for fetchOrders() to return")
    sut.fetchOrders { (result: OrdersStoreResult<[Order]>) -> Void in
      switch (result) {
      case .success(let orders):
        returnedOrders = orders
      case .failure(let error):
        XCTFail("fetchOrders() should not return an error: \(error)")
      }
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
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
    let expectation = self.expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToFetch.id!) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .success(let order):
        returnedOrder = order
      case .failure(let error):
        XCTFail("fetchOrder() should not return an error: \(error)")
      }
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    XCTAssertEqual(returnedOrder, orderToFetch, "fetchOrder() should return an order")
  }
  
  func testCreateOrderShouldCreateNewOrder_GenericEnumResultType()
  {
    // Given
    let orderToCreate = Order(id: "ghi789", date: Date(), email: "colin.code@clean-swift.com", firstName: "Colin", lastName: "Code", total: NSDecimalNumber(string: "7.89"))
    
    // When
    let createOrderExpectation = self.expectation(description: "Wait for createOrder() to return")
    sut.createOrder(orderToCreate) { (result: OrdersStoreResult<Void>) -> Void in
      createOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    var returnedOrder: Order?
    let expectation = self.expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToCreate.id!) { (order: () throws -> Order?) -> Void in
      returnedOrder = try! order()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    XCTAssertEqual(returnedOrder, orderToCreate, "createOrder() should create a new order")
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_GenericEnumResultType()
  {
    // Given
    var orderToUpdate = testOrders.first!
    let tomorrow = Date(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    let updateOrderExpectation = expectation(description: "Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate) { (result: OrdersStoreResult<Void>) -> Void in
      switch (result) {
      case .success:
        break;
      case .failure(let error):
        XCTFail("updateOrder() should not return an error: \(error)")
      }
      updateOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    var updatedOrder: Order?
    let fetchOrderExpectation = expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToUpdate.id!) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .success(let order):
        updatedOrder = order
      case .failure(let error):
        XCTFail("fetchOrder() should not return an error: \(error)")
      }
      fetchOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update an existing order")
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_GenericEnumResultType()
  {
    // Given
    let orderToDelete = testOrders.first!
    
    // When
    let deleteOrderExpectation = expectation(description: "Wait for deleteOrder() to return")
    sut.deleteOrder(orderToDelete.id!) { (result: OrdersStoreResult<Void>) -> Void in
      deleteOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    var deletedOrder: Order?
    var deleteOrderError: OrdersStoreError?
    let fetchOrderExpectation = expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToDelete.id!) { (result: OrdersStoreResult<Order>) -> Void in
      switch (result) {
      case .success(let order):
        deletedOrder = order
      case .failure(let error):
        deleteOrderError = error
      }
      fetchOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    XCTAssertNil(deletedOrder, "deleteOrder() should delete an existing order")
    XCTAssertEqual(deleteOrderError, OrdersStoreError.cannotFetch("Cannot fetch order with id \(orderToDelete.id!)"), "Deleted order should not exist")
  }
  
  // MARK: - Test CRUD operations - Inner closure
  
  func testFetchOrdersShouldReturnListOfOrders_InnerClosure()
  {
    // Given
    
    // When
    var returnedOrders = [Order]()
    let expectation = self.expectation(description: "Wait for fetchOrders() to return")
    sut.fetchOrders { (orders: () throws -> [Order]) -> Void in
      returnedOrders = try! orders()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
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
    let expectation = self.expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToFetch.id!) { (order: () throws -> Order?) -> Void in
      returnedOrder = try! order()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    XCTAssertEqual(returnedOrder, orderToFetch, "fetchOrder() should return an order")
  }
  
  func testCreateOrderShouldCreateNewOrder_InnerClosure()
  {
    // Given
    let orderToCreate = Order(id: "ghi789", date: Date(), email: "colin.code@clean-swift.com", firstName: "Colin", lastName: "Code", total: NSDecimalNumber(string: "7.89"))
    
    // When
    let createOrderExpectation = self.expectation(description: "Wait for createOrder() to return")
    sut.createOrder(orderToCreate) { (done: () throws -> Void) -> Void in
      try! done()
      createOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    var returnedOrder: Order?
    let expectation = self.expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToCreate.id!) { (order: () throws -> Order?) -> Void in
      returnedOrder = try! order()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    XCTAssertEqual(returnedOrder, orderToCreate, "createOrder() should create a new order")
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_InnerClosure()
  {
    // Given
    var orderToUpdate = testOrders.first!
    let tomorrow = Date(timeIntervalSinceNow: 24*60*60)
    orderToUpdate.date = tomorrow
    
    // When
    let updateOrderExpectation = expectation(description: "Wait for updateOrder() to return")
    sut.updateOrder(orderToUpdate) { (done: () throws -> Void) -> Void in
      try! done()
      updateOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    var updatedOrder: Order?
    let fetchOrderExpectation = expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToUpdate.id!) { (order: () throws -> Order?) -> Void in
      updatedOrder = try! order()
      fetchOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    XCTAssertEqual(updatedOrder, orderToUpdate, "updateOrder() should update an existing order")
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_InnerClosure()
  {
    // Given
    let orderToDelete = testOrders.first!
    
    // When
    let deleteOrderExpectation = expectation(description: "Wait for deleteOrder() to return")
    sut.deleteOrder(orderToDelete.id!) { (done: () throws -> Void) -> Void in
      try! done()
      deleteOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    // Then
    var deletedOrder: Order?
    var deleteOrderError: OrdersStoreError?
    let fetchOrderExpectation = expectation(description: "Wait for fetchOrder() to return")
    sut.fetchOrder(orderToDelete.id!) { (order: () throws -> Order?) -> Void in
      do {
        deletedOrder = try order()
      } catch let error as OrdersStoreError {
        deleteOrderError = error
      } catch {
      }
      fetchOrderExpectation.fulfill()
    }
    waitForExpectations(timeout: 1.0) { (error) -> Void in
    }
    
    XCTAssertNil(deletedOrder, "deleteOrder() should delete an existing order")
    XCTAssertEqual(deleteOrderError, OrdersStoreError.cannotFetch("Cannot fetch order with id \(orderToDelete.id!)"), "Deleted order should not exist")
  }
}
