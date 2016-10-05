@testable import CleanStore
import XCTest

class OrdersWorkerTests: XCTestCase
{
  // MARK: Subject under test
  
  var sut: OrdersWorker!
  
  // MARK: Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupOrdersWorker()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupOrdersWorker()
  {
    sut = OrdersWorker(ordersStore: OrdersMemStoreSpy())
  }
  
  // MARK: Test doubles
  
  class OrdersMemStoreSpy: OrdersMemStore
  {
    // MARK: Method call expectations
    var fetchedOrdersCalled = false
    
    // MARK: Spied methods
    override func fetchOrders(_ completionHandler: @escaping (_ orders: () throws -> [Order]) -> Void)
    {
      fetchedOrdersCalled = true
      let oneSecond = DispatchTime.now() + Double(1 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: oneSecond, execute: {
        completionHandler {
          return [
            Order(id: "abc123", date: Date(), email: "amy.apple@clean-swift.com", firstName: "Amy", lastName: "Apple", total: NSDecimalNumber(string: "1.23")),
            Order(id: "def456", date: Date(), email: "bob.battery@clean-swift.com", firstName: "Bob", lastName: "Battery", total: NSDecimalNumber(string: "4.56"))
          ]
        }
      })
    }
  }
  
  // MARK: Tests
  
  func testFetchOrdersShouldReturnListOfOrders()
  {
    // Given
    let ordersMemStoreSpy = sut.ordersStore as! OrdersMemStoreSpy
    
    // When
    let expectation = self.expectation(description: "Wait for fetchOrders() to return")
    sut.fetchOrders { (orders: [Order]) -> Void in
      expectation.fulfill()
    }
    
    // Then
    XCTAssert(ordersMemStoreSpy.fetchedOrdersCalled, "Calling fetchOrders() should ask the data store for a list of orders")
    waitForExpectations(timeout: 1.1) { _ in
      XCTAssert(true, "Calling fetchOrders() should result in the completion handler being called with the fetched orders result")
    }
  }
}
