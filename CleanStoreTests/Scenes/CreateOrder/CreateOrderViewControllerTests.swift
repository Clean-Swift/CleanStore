//
//  CreateOrderViewControllerTests.swift
//  CleanStore
//
//  Created by Raymond Law on 09/07/15.
//  Copyright (c) 2015 Raymond Law. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import CleanStore
import UIKit
import XCTest

class TestDisplaySaveOrderFailure
{
  static var presentViewControllerAnimatedCompletionCalled = false
  static var viewControllerToPresent: UIViewController?
}

extension CreateOrderViewController
{
  override open func showDetailViewController(_ vc: UIViewController, sender: Any?)
  {
    TestDisplaySaveOrderFailure.presentViewControllerAnimatedCompletionCalled = true
    TestDisplaySaveOrderFailure.viewControllerToPresent = vc
  }
}

class CreateOrderViewControllerTests: XCTestCase
{
  // MARK: - Subject under test
  
  var sut: CreateOrderViewController!
  var window: UIWindow!
  
  // MARK: - Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    window = UIWindow()
    setupCreateOrderViewController()
  }
  
  override func tearDown()
  {
    window = nil
    super.tearDown()
  }
  
  // MARK: - Test setup
  
  func setupCreateOrderViewController()
  {
    let bundle = Bundle.main
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    sut = storyboard.instantiateViewController(withIdentifier: "CreateOrderViewController") as! CreateOrderViewController
  }
  
  func loadView()
  {
    window.addSubview(sut.view)
    RunLoop.current.run(until: Date())
  }
  
  // MARK: - Test doubles
  
  class CreateOrderBusinessLogicSpy: CreateOrderBusinessLogic
  {
    // MARK: Method call expectations
    
    var formatExpirationDateCalled = false
    var createOrderCalled = false
    var showOrderToEditCalled = false
    var updateOrderCalled = false
    var presentFetchedShipmentMethodsCalled = false
    
    // MARK: Argument expectations
    
    var formatExpirationDateRequest: CreateOrder.FormatExpirationDate.Request!
    var createOrderRequest: CreateOrder.CreateOrder.Request!
    var editOrderRequest: CreateOrder.EditOrder.Request!
    var updateOrderRequest: CreateOrder.UpdateOrder.Request!
    var fetchShipmentMethodsRequest: CreateOrder.FetchShipmentMethods.Request!
    
    // MARK: Spied variables
    
    var shippingMethods = [ShipmentMethod]()
    var orderToEdit: Order?
    
    // MARK: Spied methods
    
    func formatExpirationDate(request: CreateOrder.FormatExpirationDate.Request)
    {
      formatExpirationDateCalled = true
      self.formatExpirationDateRequest = request
    }
    
    func createOrder(request: CreateOrder.CreateOrder.Request)
    {
      createOrderCalled = true
      self.createOrderRequest = request
    }
    
    func showOrderToEdit(request: CreateOrder.EditOrder.Request)
    {
      showOrderToEditCalled = true
      self.editOrderRequest = request
    }
    
    func updateOrder(request: CreateOrder.UpdateOrder.Request)
    {
      updateOrderCalled = true
      self.updateOrderRequest = request
    }
    
    func fetchShipmentMethods(request: CreateOrder.FetchShipmentMethods.Request)
    {
      presentFetchedShipmentMethodsCalled = true
      self.fetchShipmentMethodsRequest = request
    }
  }
  
  class CreateOrderRouterSpy: CreateOrderRouter
  {
    // MARK: Method call expectations
    
    var routeToListOrdersCalled = false
    var routeToShowOrderCalled = false
    
    // MARK: Spied methods
    
    override func routeToListOrders(segue: UIStoryboardSegue?)
    {
      routeToListOrdersCalled = true
    }
    
    override func routeToShowOrder(segue: UIStoryboardSegue?)
    {
      routeToShowOrderCalled = true
    }
  }
  
  // MARK: - Test displaying order to edit when view is loaded
  
  func testShouldShowOrderToEditWhenViewIsLoaded()
  {
    // Given
    let createOrderBusinessLogicSpy = CreateOrderBusinessLogicSpy()
    sut.interactor = createOrderBusinessLogicSpy
    
    // When
    loadView()
    
    // Then
    XCTAssert(createOrderBusinessLogicSpy.showOrderToEditCalled, "Should show order to edit when the view is loaded")
  }
  
  func testShouldDisplayOrderToEdit()
  {
    // Given
    loadView()
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    let orderToEdit = Seeds.Orders.amy
    let viewModel = CreateOrder.EditOrder.ViewModel(orderFormFields: CreateOrder.OrderFormFields(firstName: orderToEdit.firstName, lastName: orderToEdit.lastName, phone: orderToEdit.phone, email: orderToEdit.email, billingAddressStreet1: orderToEdit.billingAddress.street1, billingAddressStreet2: orderToEdit.billingAddress.street2 ?? "", billingAddressCity: orderToEdit.billingAddress.city, billingAddressState: orderToEdit.billingAddress.state, billingAddressZIP: orderToEdit.billingAddress.zip, paymentMethodCreditCardNumber: orderToEdit.paymentMethod.creditCardNumber, paymentMethodCVV: orderToEdit.paymentMethod.cvv, paymentMethodExpirationDate: orderToEdit.paymentMethod.expirationDate, paymentMethodExpirationDateString: dateFormatter.string(from: orderToEdit.paymentMethod.expirationDate), shipmentAddressStreet1: orderToEdit.shipmentAddress.street1, shipmentAddressStreet2: orderToEdit.shipmentAddress.street2 ?? "", shipmentAddressCity: orderToEdit.shipmentAddress.city, shipmentAddressState: orderToEdit.shipmentAddress.state, shipmentAddressZIP: orderToEdit.shipmentAddress.zip, shipmentMethodSpeed: orderToEdit.shipmentMethod.speed.rawValue, shipmentMethodSpeedString: orderToEdit.shipmentMethod.toString(), id: orderToEdit.id, date: orderToEdit.date, total: orderToEdit.total))
    
    // When
    sut.displayOrderToEdit(viewModel: viewModel)
    
    // Then
    XCTAssertEqual(sut.firstNameTextField.text, viewModel.orderFormFields.firstName, "Displaying the order to edit should display the correct first name")
    XCTAssertEqual(sut.lastNameTextField.text, viewModel.orderFormFields.lastName, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.phoneTextField.text, viewModel.orderFormFields.phone, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.emailTextField.text, viewModel.orderFormFields.email, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.billingAddressStreet1TextField.text, viewModel.orderFormFields.billingAddressStreet1, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.billingAddressStreet2TextField.text, viewModel.orderFormFields.billingAddressStreet2, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.billingAddressCityTextField.text, viewModel.orderFormFields.billingAddressCity, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.billingAddressStateTextField.text, viewModel.orderFormFields.billingAddressState, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.billingAddressZIPTextField.text, viewModel.orderFormFields.billingAddressZIP, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.creditCardNumberTextField.text, viewModel.orderFormFields.paymentMethodCreditCardNumber, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.ccvTextField.text, viewModel.orderFormFields.paymentMethodCVV, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.shipmentAddressStreet1TextField.text, viewModel.orderFormFields.shipmentAddressStreet1, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.shipmentAddressStreet2TextField.text, viewModel.orderFormFields.shipmentAddressStreet2, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.shipmentAddressCityTextField.text, viewModel.orderFormFields.shipmentAddressCity, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.shipmentAddressStateTextField.text, viewModel.orderFormFields.shipmentAddressState, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.shipmentAddressZIPTextField.text, viewModel.orderFormFields.shipmentAddressZIP, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.shippingMethodPicker.selectedRow(inComponent: 0), viewModel.orderFormFields.shipmentMethodSpeed, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.shippingMethodTextField.text, viewModel.orderFormFields.shipmentMethodSpeedString, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.expirationDatePicker.date, viewModel.orderFormFields.paymentMethodExpirationDate, "Displaying the order to edit should display the correct ")
    XCTAssertEqual(sut.expirationDateTextField.text, viewModel.orderFormFields.paymentMethodExpirationDateString, "Displaying the order to edit should display the correct ")
  }
  
  // MARK: - Test expiration date
  
  func testDisplayExpirationDateShouldDisplayDateStringInTextField()
  {
    // Given
    loadView()
    let viewModel = CreateOrder.FormatExpirationDate.ViewModel(date: "6/29/07")
    
    // When
    sut.displayExpirationDate(viewModel: viewModel)
    
    // Then
    let displayedDate = sut.expirationDateTextField.text
    XCTAssertEqual(displayedDate, "6/29/07", "Displaying an expiration date should display the date string in the expiration date text field")
  }
  
  func testExpirationDatePickerValueChangedShouldFormatSelectedDate()
  {
    // Given
    loadView()
    let createOrderBusinessLogicSpy = CreateOrderBusinessLogicSpy()
    sut.interactor = createOrderBusinessLogicSpy
    
    var dateComponents = DateComponents()
    dateComponents.year = 2007
    dateComponents.month = 6
    dateComponents.day = 29
    let selectedDate = Calendar.current.date(from: dateComponents)!
    
    // When
    sut.expirationDatePicker.date = selectedDate
    sut.expirationDatePickerValueChanged(self)
    
    // Then
    XCTAssert(createOrderBusinessLogicSpy.formatExpirationDateCalled, "Changing the expiration date should format the expiration date")
    let actualDate = createOrderBusinessLogicSpy.formatExpirationDateRequest.date
    XCTAssertEqual(actualDate, selectedDate, "Changing the expiration date should format the date selected in the date picker")
  }
  
  // MARK: - Test shipping method
  
  func testNumberOfComponentsInPickerViewShouldReturnOneComponent()
  {
    // Given
    loadView()
    let pickerView = sut.shippingMethodPicker!
    
    // When
    let numberOfComponents = sut.numberOfComponents(in: pickerView)
    
    // Then
    XCTAssertEqual(numberOfComponents, 1, "The number of components in the shipping method picker should be 1")
  }
  
  func testNumberOfRowsInFirstComponentOfPickerViewShouldEqualNumberOfAvailableShippingMethods()
  {
    // Given
    loadView()
    let pickerView = sut.shippingMethodPicker!
    let testShipmentMethods = [CreateOrder.FetchShipmentMethods.ViewModel.DisplayedShipmentMethod(id: 1, text: "Some Shipping")]
    sut.displayedShipmentMethods = testShipmentMethods
    
    // When
    let numberOfRows = sut.pickerView(pickerView, numberOfRowsInComponent: 0)
    
    // Then
    XCTAssertEqual(numberOfRows, testShipmentMethods.count, "The number of rows in the first component of shipping method picker should equal to the number of available shipping methods")
  }
  
  func testShippingMethodPickerShouldDisplayProperTitles()
  {
    // Given
    loadView()
    let pickerView = sut.shippingMethodPicker!
    
    let displayedShipmentMethods = [
        CreateOrder.FetchShipmentMethods.ViewModel.DisplayedShipmentMethod(id: 1, text: "Standard Shipping"),
        CreateOrder.FetchShipmentMethods.ViewModel.DisplayedShipmentMethod(id: 2, text: "One-Day Shipping"),
        CreateOrder.FetchShipmentMethods.ViewModel.DisplayedShipmentMethod(id: 3, text: "Two-Day Shipping")
    ]
    
    let viewModel = CreateOrder.FetchShipmentMethods.ViewModel(displayedShipmentMethods: displayedShipmentMethods)
    
    // When
    sut.displayFetchedShipmentMethods(viewModel: viewModel)
    
    let returnedTitles = [
      sut.pickerView(pickerView, titleForRow: 0, forComponent: 0),
      sut.pickerView(pickerView, titleForRow: 1, forComponent: 0),
      sut.pickerView(pickerView, titleForRow: 2, forComponent: 0)
    ]
    
    // Then
    var expectedTitles = [
      "Standard Shipping",
      "One-Day Shipping",
      "Two-Day Shipping"
    ]
    XCTAssertEqual(returnedTitles[0], expectedTitles[0], "The shipping method picker should display proper titles")
    XCTAssertEqual(returnedTitles[1], expectedTitles[1], "The shipping method picker should display proper titles")
    XCTAssertEqual(returnedTitles[2], expectedTitles[2], "The shipping method picker should display proper titles")
  }
  
  func testSelectingShippingMethodInThePickerShouldDisplayTheSelectedShippingMethodToUser()
  {
    // Given
    loadView()
    let pickerView = sut.shippingMethodPicker!
    
    let displayedShipmentMethods = [
        CreateOrder.FetchShipmentMethods.ViewModel.DisplayedShipmentMethod(id: 1, text: "Standard Shipping"),
        CreateOrder.FetchShipmentMethods.ViewModel.DisplayedShipmentMethod(id: 2, text: "One-Day Shipping"),
        CreateOrder.FetchShipmentMethods.ViewModel.DisplayedShipmentMethod(id: 3, text: "Two-Day Shipping")
    ]
    
    let viewModel = CreateOrder.FetchShipmentMethods.ViewModel(displayedShipmentMethods: displayedShipmentMethods)
    
    // When
    sut.displayFetchedShipmentMethods(viewModel: viewModel)
    sut.pickerView(pickerView, didSelectRow: 1, inComponent: 0)
    
    // Then
    let expectedShippingMethod = "One-Day Shipping"
    let displayedShippingMethod = sut.shippingMethodTextField.text
    XCTAssertEqual(displayedShippingMethod, expectedShippingMethod, "Selecting a shipping method in the shipping method picker should display the selected shipping method to the user")
  }
  
  // MARK: - Test text fields
  
  // NOTE: Calling textField.becomeFirstResponder() doesn't set textField.isFirstResponder to true
  //       Tried to wait but didn't help. Maybe a beta issue.
  func _testCursorFocusShouldMoveToNextTextFieldWhenUserTapsReturnKey()
  {
    // Given
    loadView()
    let currentTextField = sut.textFields[0]
    let nextTextField = sut.textFields[1]
    currentTextField.becomeFirstResponder()
    
    // When
    _ = sut.textFieldShouldReturn(currentTextField)
    
    // Then
    XCTAssert(!currentTextField.isFirstResponder, "Current text field should lose keyboard focus")
    XCTAssert(nextTextField.isFirstResponder, "Next text field should gain keyboard focus")
  }
  
  func testKeyboardShouldBeDismissedWhenUserTapsReturnKeyWhenFocusIsInLastTextField()
  {
    // Given
    loadView()
    
    // Scroll to the bottom of table view so the last text field is visible and its gesture recognizer is set up
    let lastSectionIndex = sut.tableView.numberOfSections - 1
    let lastRowIndex = sut.tableView.numberOfRows(inSection: lastSectionIndex) - 1
    sut.tableView.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: .bottom, animated: false)
    
    // Show keyboard for the last text field
    let numTextFields = sut.textFields.count
    let lastTextField = sut.textFields[numTextFields - 1]
    lastTextField.becomeFirstResponder()
    
    // When
    _ = sut.textFieldShouldReturn(lastTextField)
    
    // Then
    XCTAssert(!lastTextField.isFirstResponder, "Last text field should lose keyboard focus")
  }
  
  func testTextFieldShouldHaveFocusWhenUserTapsOnTableViewRow()
  {
    // Given
    loadView()
    
    // When
    let indexPath = IndexPath(row: 0, section: 0)
    sut.tableView(sut.tableView, didSelectRowAt: indexPath)
    
    // Then
    let textField = sut.textFields[0]
    XCTAssert(textField.isFirstResponder, "The text field should have keyboard focus when user taps on the corresponding table view row")
  }
  
  // MARK: - Test picker configs when view is loaded
  
  func testCreateOrderViewControllerShouldConfigurePickersWhenViewIsLoaded()
  {
    // Given
    
    // When
    loadView()
    
    // Then
    XCTAssertEqual(sut.expirationDateTextField.inputView, sut.expirationDatePicker, "Expiration date text field should have the expiration date picker as input view")
    XCTAssertEqual(sut.shippingMethodTextField.inputView, sut.shippingMethodPicker, "Shipping method text field should have the shipping method picker as input view")
  }
  
  // MARK: - Test creating a new order
  
  func testSaveButtonTappedShouldCreateOrder()
  {
    // Given
    loadView()
    let createOrderBusinessLogicSpy = CreateOrderBusinessLogicSpy()
    createOrderBusinessLogicSpy.orderToEdit = nil
    sut.interactor = createOrderBusinessLogicSpy
    
    // When
    sut.saveButtonTapped(self)
    
    // Then
    XCTAssert(createOrderBusinessLogicSpy.createOrderCalled, "It should create a new order when the user taps the Save button")
  }
  
  func testSuccessfullyCreatedOrderShouldRouteBackToListOrdersScene()
  {
    // Given
    loadView()
    let createOrderRouterSpy = CreateOrderRouterSpy()
    sut.router = createOrderRouterSpy
    
    let viewModel = CreateOrder.CreateOrder.ViewModel(order: Seeds.Orders.amy)
    
    // When
    sut.displayCreatedOrder(viewModel: viewModel)
    
    // Then
    XCTAssert(createOrderRouterSpy.routeToListOrdersCalled, "Displaying a successfully created order should navigate back to the List Orders scene")
  }
  
  func testCreateOrderFailureShouldShowAnAlert()
  {
    // Given
    loadView()
    let viewModel = CreateOrder.CreateOrder.ViewModel(order: nil)
    
    // When
    sut.displayCreatedOrder(viewModel: viewModel)
    
    // Then
    let alertController = TestDisplaySaveOrderFailure.viewControllerToPresent as! UIAlertController
    XCTAssert(TestDisplaySaveOrderFailure.presentViewControllerAnimatedCompletionCalled, "Displaying create order failure should show an alert")
    XCTAssertEqual(alertController.title, "Failed to create order", "Displaying create order failure should display proper title")
    XCTAssertEqual(alertController.message, "Please correct your order and submit again.", "Displaying create order failure should display proper message")
  }
  
  // MARK: - Test updating an existing order
  
  func testSaveButtonTappedShouldUpdateOrder()
  {
    // Given
    loadView()
    let createOrderBusinessLogicSpy = CreateOrderBusinessLogicSpy()
    createOrderBusinessLogicSpy.orderToEdit = Seeds.Orders.amy
    sut.interactor = createOrderBusinessLogicSpy
    
    // When
    sut.saveButtonTapped(self)
    
    // Then
    XCTAssert(createOrderBusinessLogicSpy.updateOrderCalled, "It should update an existing order when the user taps the Save button")
  }
  
  func testSuccessfullyUpdatedOrderShouldRouteBackToShowOrderScene()
  {
    // Given
    loadView()
    let createOrderRouterSpy = CreateOrderRouterSpy()
    sut.router = createOrderRouterSpy
    
    let viewModel = CreateOrder.UpdateOrder.ViewModel(order: Seeds.Orders.amy)
    
    // When
    sut.displayUpdatedOrder(viewModel: viewModel)
    
    // Then
    XCTAssert(createOrderRouterSpy.routeToShowOrderCalled, "Displaying a successfully updated order should navigate back to the Show Order scene")
  }
  
  func testUpdateOrderFailureShouldShowAnAlert()
  {
    // Given
    loadView()
    let viewModel = CreateOrder.UpdateOrder.ViewModel(order: nil)
    
    // When
    sut.displayUpdatedOrder(viewModel: viewModel)
    
    // Then
    let alertController = TestDisplaySaveOrderFailure.viewControllerToPresent as! UIAlertController
    XCTAssert(TestDisplaySaveOrderFailure.presentViewControllerAnimatedCompletionCalled, "Displaying update order failure should show an alert")
    XCTAssertEqual(alertController.title, "Failed to update order", "Displaying update order failure should display proper title")
    XCTAssertEqual(alertController.message, "Please correct your order and submit again.", "Displaying update order failure should display proper message")
  }
}
