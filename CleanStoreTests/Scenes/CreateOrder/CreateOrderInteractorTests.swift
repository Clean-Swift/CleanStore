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
    var presentOrderToEditCalled = false
    var presentUpdatedOrderCalled = false
    
    func presentExpirationDate(response: CreateOrder.FormatExpirationDate.Response)
    {
      presentExpirationDateCalled = true
    }
    
    func presentCreatedOrder(response: CreateOrder.CreateOrder.Response)
    {
      presentCreatedOrderCalled = true
    }
    
    func presentOrderToEdit(response: CreateOrder.EditOrder.Response) {
      presentOrderToEditCalled = true
    }
    
    func presentUpdatedOrder(response: CreateOrder.UpdateOrder.Response)
    {
      presentUpdatedOrderCalled = true
    }
  }
  
  class OrdersWorkerSpy: OrdersWorker
  {
    // MARK: Method call expectations
    var createOrderCalled = false
    var updateOrderCalled = false
    
    // MARK: Spied methods
    override func createOrder(orderToCreate: Order, completionHandler: (order: Order?) -> Void)
    {
      createOrderCalled = true
      completionHandler(order: Seeds.Orders.amy)
    }
    
    override func updateOrder(orderToUpdate: Order, completionHandler: (order: Order?) -> Void)
    {
      updateOrderCalled = true
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
    let request = CreateOrder.CreateOrder.Request(orderFormFields: CreateOrder.OrderFormFields(firstName: "", lastName: "", phone: "", email: "", billingAddressStreet1: "", billingAddressStreet2: "", billingAddressCity: "", billingAddressState: "", billingAddressZIP: "", paymentMethodCreditCardNumber: "", paymentMethodCVV: "", paymentMethodExpirationDate: NSDate(), paymentMethodExpirationDateString: "", shipmentAddressStreet1: "", shipmentAddressStreet2: "", shipmentAddressCity: "", shipmentAddressState: "", shipmentAddressZIP: "", shipmentMethodSpeed: 0, shipmentMethodSpeedString: "", id: "some id", date: NSDate(), total: NSDecimalNumber(string: "9.99")))
    sut.createOrder(request)
    
    // Then
    XCTAssert(ordersWorkerSpy.createOrderCalled, "CreateOrder() should ask OrdersWorker to create the new order")
    XCTAssert(createOrderInteractorOutputSpy.presentCreatedOrderCalled, "CreateOrder() should ask presenter to format the newly created order")
  }
  
  // MARK: - Test editing an order
  
  func testShowOrderToEditShouldAskPresenterToFormatTheExistingOrder()
  {
    // Given
    let createOrderInteractorOutputSpy = CreateOrderInteractorOutputSpy()
    sut.output = createOrderInteractorOutputSpy
    
    sut.orderToEdit = Seeds.Orders.amy
    
    let request = CreateOrder.EditOrder.Request()
    
    // When
    sut.showOrderToEdit(request)
    
    // Then
    XCTAssert(createOrderInteractorOutputSpy.presentOrderToEditCalled, "ShowOrderToEdit() should ask presenter to format the existing order")
  }
  
  func testShowOrderToEditShouldNotAskPresenterToFormatIfThereIsNoExistingOrder()
  {
    // Given
    let createOrderInteractorOutputSpy = CreateOrderInteractorOutputSpy()
    sut.output = createOrderInteractorOutputSpy
    
    sut.orderToEdit = nil
    
    let request = CreateOrder.EditOrder.Request()
    
    // When
    sut.showOrderToEdit(request)
    
    // Then
    XCTAssertFalse(createOrderInteractorOutputSpy.presentOrderToEditCalled, "ShowOrderToEdit() should not ask presenter to format if there is no existing order")
  }
  
  func testUpdateOrderShouldAskOrdersWorkerToUpdateTheExistingOrder()
  {
    // Given
    let createOrderInteractorOutputSpy = CreateOrderInteractorOutputSpy()
    sut.output = createOrderInteractorOutputSpy
    let ordersWorkerSpy = OrdersWorkerSpy(ordersStore: OrdersMemStore())
    sut.ordersWorker = ordersWorkerSpy
    
    // When
    let request = CreateOrder.UpdateOrder.Request(orderFormFields: CreateOrder.OrderFormFields(firstName: "", lastName: "", phone: "", email: "", billingAddressStreet1: "", billingAddressStreet2: "", billingAddressCity: "", billingAddressState: "", billingAddressZIP: "", paymentMethodCreditCardNumber: "", paymentMethodCVV: "", paymentMethodExpirationDate: NSDate(), paymentMethodExpirationDateString: "", shipmentAddressStreet1: "", shipmentAddressStreet2: "", shipmentAddressCity: "", shipmentAddressState: "", shipmentAddressZIP: "", shipmentMethodSpeed: 0, shipmentMethodSpeedString: "", id: "some id", date: NSDate(), total: NSDecimalNumber(string: "9.99")))
    sut.updateOrder(request)
    
    // Then
    XCTAssert(ordersWorkerSpy.updateOrderCalled, "UpdateOrder() should ask OrdersWorker to update the existing order")
    XCTAssert(createOrderInteractorOutputSpy.presentUpdatedOrderCalled, "UpdateOrder() should ask presenter to format the updated order")
  }
}
