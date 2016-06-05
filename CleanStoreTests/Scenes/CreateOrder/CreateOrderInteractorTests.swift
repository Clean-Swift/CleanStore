@testable import CleanStore
import UIKit
import XCTest

class CreateOrderInteractorTests: XCTestCase
{
  // MARK: - Subject under test
  
  var sut: CreateOrderInteractor!
  
  // MARK: - Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupCreateOrderInteractor()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: - Test setup
  
  func setupCreateOrderInteractor()
  {
    sut = CreateOrderInteractor()
  }
  
  // MARK: - Test doubles
  
  class CreateOrderInteractorOutputSpy: CreateOrderInteractorOutput
  {
    var presentExpirationDateCalled = false
    var presentCreatedOrderCalled = false
    
    func presentExpirationDate(response: CreateOrder.FormatExpirationDate.Response)
    {
      presentExpirationDateCalled = true
    }
    
    func presentCreatedOrder(response: CreateOrder.CreateOrder.Response)
    {
      presentCreatedOrderCalled = true
    }
  }
  
  class OrdersWorkerSpy: OrdersWorker
  {
    // MARK: Method call expectations
    var createOrderCalled = false
    
    // MARK: Spied methods
    override func createOrder(orderToCreate: Order, completionHandler: (order: Order?) -> Void)
    {
      createOrderCalled = true
      completionHandler(order: Seeds.Orders.amy)
    }
  }
  
  // MARK: - Test expiration date
  
  func testFormatExpirationDateShouldAskPresenterToFormatExpirationDate()
  {
    // Given
    let createOrderInteractorOutputSpy = CreateOrderInteractorOutputSpy()
    sut.output = createOrderInteractorOutputSpy
    let request = CreateOrder.FormatExpirationDate.Request(date: NSDate())
    
    // When
    sut.formatExpirationDate(request)
    
    // Then
    XCTAssert(createOrderInteractorOutputSpy.presentExpirationDateCalled, "Formatting an expiration date should ask presenter to do it")
  }
  
  // MARK: - Test shipping methods
  
  func testShippingMethodsShouldReturnAllAvailableShippingMethods()
  {
    // Given
    let allAvailableShippingMethods = [
      "Standard Shipping",
      "One-Day Shipping",
      "Two-Day Shipping"
    ]
    
    // When
    let returnedShippingMethods = sut.shippingMethods
    
    // Then
    XCTAssertEqual(returnedShippingMethods, allAvailableShippingMethods, "Shipping Methods should list all available shipping methods")
  }
  
  // MARK: - Test creating a new order
  
  func testCreateOrderShouldAskOrdersWorkerToCreateTheNewOrder()
  {
    // Given
    let createOrderInteractorOutputSpy = CreateOrderInteractorOutputSpy()
    sut.output = createOrderInteractorOutputSpy
    let ordersWorkerSpy = OrdersWorkerSpy(ordersStore: OrdersMemStore())
    sut.ordersWorker = ordersWorkerSpy
    
    // When
    let request = CreateOrder.CreateOrder.Request(firstName: "", lastName: "", phone: "", email: "", billingAddressStreet1: "", billingAddressStreet2: "", billingAddressCity: "", billingAddressState: "", billingAddressZIP: "", paymentMethodCreditCardNumber: "", paymentMethodExpirationDate: NSDate(), paymentMethodCVV: "", shipmentAddressStreet1: "", shipmentAddressStreet2: "", shipmentAddressCity: "", shipmentAddressState: "", shipmentAddressZIP: "", shipmentMethodSpeed: 0, id: "some id", date: NSDate(), total: NSDecimalNumber(string: "9.99"))
    sut.createOrder(request)
    
    // Then
    XCTAssert(ordersWorkerSpy.createOrderCalled, "CreateOrder() should ask OrdersWorker to create the new order")
    XCTAssert(createOrderInteractorOutputSpy.presentCreatedOrderCalled, "CreateOrders() should ask presenter to format the newly created order")
  }
}
