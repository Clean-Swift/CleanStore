import XCTest

class OrdersMemStoreTests: XCTestCase
{
  // MARK: Subject under test
  
  var sut: OrdersMemStore!
  
  // MARK: Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupOrdersMemStore()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupOrdersMemStore()
  {
    sut = OrdersMemStore()
  }
  
  // MARK: Test doubles
  
  // MARK: Tests
  
  func testFetchOrdersShouldReturnListOfOrders()
  {
    // Given
    let expectedOrders = [Order()]
    sut.orders = expectedOrders
    
    // When
    var returnedOrders = [Order]()
    let expectation = expectationWithDescription("")
    sut.fetchOrders { (orders) -> Void in
      returnedOrders = orders
      expectation.fulfill()
    }
    
    // Then
    waitForExpectationsWithTimeout(1.0) { (error: NSError?) -> Void in
      XCTAssertEqual(expectedOrders, returnedOrders, "")
    }
  }
}
