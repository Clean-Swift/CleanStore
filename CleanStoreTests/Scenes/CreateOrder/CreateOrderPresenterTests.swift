@testable import CleanStore
import UIKit
import XCTest

class CreateOrderPresenterTests: XCTestCase
{
  // MARK: - Subject under test
  
  var sut: CreateOrderPresenter!
  
  // MARK: - Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupCreateOrderPresenter()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: - Test setup
  
  func setupCreateOrderPresenter()
  {
    sut = CreateOrderPresenter()
  }
  
  // MARK: - Test doubles
  
  class CreateOrderPresenterOutputSpy: CreateOrderPresenterOutput
  {
    // MARK: Method call expectations
    var displayExpirationDateCalled = false
    var displayCreatedOrderCalled = false
    var displayOrderToEditCalled = false
    var displayUpdatedOrderCalled = false
    
    // MARK: Argument expectations
    var formatExpirationDateViewModel: CreateOrder.FormatExpirationDate.ViewModel!
    var createOrderViewModel: CreateOrder.CreateOrder.ViewModel!
    var editOrderViewModel: CreateOrder.EditOrder.ViewModel!
    var updateOrderViewModel: CreateOrder.UpdateOrder.ViewModel!
    
    // MARK: Spied methods
    func displayExpirationDate(viewModel: CreateOrder.FormatExpirationDate.ViewModel)
    {
      displayExpirationDateCalled = true
      self.formatExpirationDateViewModel = viewModel
    }
    
    func displayCreatedOrder(viewModel: CreateOrder.CreateOrder.ViewModel)
    {
      displayCreatedOrderCalled = true
      self.createOrderViewModel = viewModel
    }
    
    func displayOrderToEdit(viewModel: CreateOrder.EditOrder.ViewModel)
    {
      displayOrderToEditCalled = true
      self.editOrderViewModel = viewModel
    }
    
    func displayUpdatedOrder(viewModel: CreateOrder.UpdateOrder.ViewModel)
    {
      displayUpdatedOrderCalled = true
      self.updateOrderViewModel = viewModel
    }
  }
  
  class CreateOrderPresenterOutputMock: CreateOrderPresenterOutput
  {
    // MARK: Method call expectations
    var displayExpirationDateCalled = false
    var displayCreatedOrderCalled = false
    var displayOrderToEditCalled = false
    var displayUpdatedOrderCalled = false
    
    // MARK: Argument expectations
    var formatExpirationDateViewModel: CreateOrder.FormatExpirationDate.ViewModel!
    var createOrderViewModel: CreateOrder.CreateOrder.ViewModel!
    var editOrderViewModel: CreateOrder.EditOrder.ViewModel!
    var updateOrderViewModel: CreateOrder.UpdateOrder.ViewModel!
    
    // MARK: Spied methods
    func displayExpirationDate(viewModel: CreateOrder.FormatExpirationDate.ViewModel)
    {
      displayExpirationDateCalled = true
      self.formatExpirationDateViewModel = viewModel
    }
    
    func displayCreatedOrder(viewModel: CreateOrder.CreateOrder.ViewModel)
    {
      displayCreatedOrderCalled = true
      self.createOrderViewModel = viewModel
    }
    
    func displayOrderToEdit(viewModel: CreateOrder.EditOrder.ViewModel)
    {
      displayOrderToEditCalled = true
      self.editOrderViewModel = viewModel
    }
    
    func displayUpdatedOrder(viewModel: CreateOrder.UpdateOrder.ViewModel)
    {
      displayUpdatedOrderCalled = true
      self.updateOrderViewModel = viewModel
    }
    
    // MARK: Verifications
    func verifyDisplayExpirationDateIsCalled() -> Bool
    {
      return displayExpirationDateCalled
    }
    
    func verifyExpirationDateIsFormattedAs(date: String) -> Bool
    {
      return formatExpirationDateViewModel.date == date
    }
  }
  
  // MARK: - Test expiration date
  
  func testPresentExpirationDateShouldConvertDateToStringUsingSpy()
  {
    // Given
    let createOrderPresenterOutputSpy = CreateOrderPresenterOutputSpy()
    sut.output = createOrderPresenterOutputSpy
    
    let dateComponents = NSDateComponents()
    dateComponents.year = 2007
    dateComponents.month = 6
    dateComponents.day = 29
    let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    let response = CreateOrder.FormatExpirationDate.Response(date: date)
    
    // When
    sut.presentExpirationDate(response)
    
    // Then
    let returnedDate = createOrderPresenterOutputSpy.formatExpirationDateViewModel.date
    let expectedDate = "6/29/07"
    XCTAssertEqual(returnedDate, expectedDate, "Presenting an expiration date should convert date to string")
  }
  
  func testPresentExpirationDateShouldAskViewControllerToDisplayDateStringUsingSpy()
  {
    // Given
    let createOrderPresenterOutputSpy = CreateOrderPresenterOutputSpy()
    sut.output = createOrderPresenterOutputSpy
    let response = CreateOrder.FormatExpirationDate.Response(date: NSDate())
    
    // When
    sut.presentExpirationDate(response)
    
    // Then
    XCTAssert(createOrderPresenterOutputSpy.displayExpirationDateCalled, "Presenting an expiration date should ask view controller to display date string")
  }
  
  func testPresentExpirationDateShouldConvertDateToStringUsingMock()
  {
    // Given
    let createOrderPresenterOutputMock = CreateOrderPresenterOutputMock()
    sut.output = createOrderPresenterOutputMock
    
    let dateComponents = NSDateComponents()
    dateComponents.year = 2007
    dateComponents.month = 6
    dateComponents.day = 29
    let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    let response = CreateOrder.FormatExpirationDate.Response(date: date)
    
    // When
    sut.presentExpirationDate(response)
    
    // Then
    let expectedDate = "6/29/07"
    XCTAssert(createOrderPresenterOutputMock.verifyExpirationDateIsFormattedAs(expectedDate), "Presenting an expiration date should convert date to string")
  }
  
  func testPresentExpirationDateShouldAskViewControllerToDisplayDateStringUsingMock()
  {
    // Given
    let createOrderPresenterOutputMock = CreateOrderPresenterOutputMock()
    sut.output = createOrderPresenterOutputMock
    let response = CreateOrder.FormatExpirationDate.Response(date: NSDate())
    
    // When
    sut.presentExpirationDate(response)
    
    // Then
    XCTAssert(createOrderPresenterOutputMock.verifyDisplayExpirationDateIsCalled(), "Presenting an expiration date should ask view controller to display date string")
  }
  
  // MARK: - Test created order
  
  func testPresentCreatedOrderShouldFormatCreatedOrderForDisplay()
  {
    // Given
    let createOrderPresenterOutputSpy = CreateOrderPresenterOutputSpy()
    sut.output = createOrderPresenterOutputSpy
    
    let order = Seeds.Orders.amy
    let response = CreateOrder.CreateOrder.Response(order: order)
    
    // When
    sut.presentCreatedOrder(response)
    
    // Then
    XCTAssert(createOrderPresenterOutputSpy.createOrderViewModel.success, "Presenting the newly created order should succeed")
  }
  
  func testPresentCreatedOrderShouldAskViewControllerToDisplayTheNewlyCreatedOrder()
  {
    // Given
    let createOrderPresenterOutputSpy = CreateOrderPresenterOutputSpy()
    sut.output = createOrderPresenterOutputSpy
    
    let order = Seeds.Orders.amy
    let response = CreateOrder.CreateOrder.Response(order: order)
    
    // When
    sut.presentCreatedOrder(response)
    
    // Then
    XCTAssert(createOrderPresenterOutputSpy.displayCreatedOrderCalled, "Presenting the newly created order should ask view controller to display it")
  }
  
  // MARK: Test editing order
  
  func testPresentOrderToEditShouldFormatTheExistingOrderForDisplay()
  {
    // Given
    let createOrderPresenterOutputSpy = CreateOrderPresenterOutputSpy()
    sut.output = createOrderPresenterOutputSpy
    
    let order = Seeds.Orders.amy
    let response = CreateOrder.EditOrder.Response(order: order)
    
    // When
    sut.presentOrderToEdit(response)
    
    // Then
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .ShortStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
    let orderPaymentMethodExpirationDate = dateFormatter.stringFromDate(order.paymentMethod.expirationDate)
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.firstName, order.firstName, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.lastName, order.lastName, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.phone, order.phone, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.email, order.email, "Presenting the order to edit should format the existing order")
    
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.billingAddressStreet1, order.billingAddress.street1, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.billingAddressStreet2, order.billingAddress.street2, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.billingAddressCity, order.billingAddress.city, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.billingAddressState, order.billingAddress.state, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.billingAddressZIP, order.billingAddress.zip, "Presenting the order to edit should format the existing order")
    
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.paymentMethodCreditCardNumber, order.paymentMethod.creditCardNumber, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.paymentMethodCVV, order.paymentMethod.cvv, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.paymentMethodExpirationDate, order.paymentMethod.expirationDate, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.paymentMethodExpirationDateString, orderPaymentMethodExpirationDate, "Presenting the order to edit should format the existing order")
    
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.shipmentAddressStreet1, order.shipmentAddress.street1, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.shipmentAddressStreet2, order.shipmentAddress.street2, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.shipmentAddressCity, order.shipmentAddress.city, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.shipmentAddressState, order.shipmentAddress.state, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.shipmentAddressZIP, order.shipmentAddress.zip, "Presenting the order to edit should format the existing order")
    
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.shipmentMethodSpeed, order.shipmentMethod.speed.rawValue, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.shipmentMethodSpeedString, order.shipmentMethod.toString(), "Presenting the order to edit should format the existing order")
    
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.id, order.id, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.date, order.date, "Presenting the order to edit should format the existing order")
    XCTAssertEqual(createOrderPresenterOutputSpy.editOrderViewModel.orderFormFields.total, order.total, "Presenting the order to edit should format the existing order")
  }
  
  func testPresentOrderToEditShouldAskViewControllerToDisplayTheExistingOrder()
  {
    // Given
    let createOrderPresenterOutputSpy = CreateOrderPresenterOutputSpy()
    sut.output = createOrderPresenterOutputSpy
    
    let order = Seeds.Orders.amy
    let response = CreateOrder.EditOrder.Response(order: order)
    
    // When
    sut.presentOrderToEdit(response)
    
    // Then
    XCTAssert(createOrderPresenterOutputSpy.displayOrderToEditCalled, "Presenting the order to edit should ask view controller to display it")
  }
  
  func testPresentUpdatedOrderShouldFormatUpdatedOrderForDisplay()
  {
    // Given
    let createOrderPresenterOutputSpy = CreateOrderPresenterOutputSpy()
    sut.output = createOrderPresenterOutputSpy
    
    let order = Seeds.Orders.amy
    let response = CreateOrder.UpdateOrder.Response(order: order)
    
    // When
    sut.presentUpdatedOrder(response)
    
    // Then
    XCTAssert(createOrderPresenterOutputSpy.updateOrderViewModel.success, "Presenting the updated order should succeed")
  }
  
  func testPresentUpdatedOrderShouldAskViewControllerToDisplayTheUpdatedOrder()
  {
    // Given
    let createOrderPresenterOutputSpy = CreateOrderPresenterOutputSpy()
    sut.output = createOrderPresenterOutputSpy
    
    let order = Seeds.Orders.amy
    let response = CreateOrder.UpdateOrder.Response(order: order)
    
    // When
    sut.presentUpdatedOrder(response)
    
    // Then
    XCTAssert(createOrderPresenterOutputSpy.displayUpdatedOrderCalled, "Presenting the updated order should ask view controller to display it")
  }
}
