@testable import CleanStore
import UIKit
import XCTest

class TestDisplayCreateOrderFailureShouldShowAnAlert
{
  static var presentViewControllerAnimatedCompletionCalled = false
  static var viewControllerToPresent: UIViewController?
}

extension CreateOrderViewController
{
  
  override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
  {
    TestDisplayCreateOrderFailureShouldShowAnAlert.presentViewControllerAnimatedCompletionCalled = true
    TestDisplayCreateOrderFailureShouldShowAnAlert.viewControllerToPresent = viewControllerToPresent
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
    let bundle = NSBundle.mainBundle()
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    sut = storyboard.instantiateViewControllerWithIdentifier("CreateOrderViewController") as! CreateOrderViewController
    _ = sut.view
    addViewToWindow()
  }
  
  func addViewToWindow()
  {
    window.addSubview(sut.view)
    NSRunLoop.currentRunLoop().runUntilDate(NSDate())
  }
  
  // MARK: - Test doubles
  
  class CreateOrderViewControllerOutputSpy: CreateOrderViewControllerOutput
  {
    // MARK: Method call expectations
    var formatExpirationDateCalled = false
    var createOrderCalled = false
    
    // MARK: Argument expectations
    var formatExpirationDateRequest: CreateOrder.FormatExpirationDate.Request!
    var createOrderRequest: CreateOrder.CreateOrder.Request!
    
    // MARK: Spied variables
    var shippingMethods = [String]()
    
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
  }
  
  class CreateOrderRouterSpy: CreateOrderRouter
  {
    // MARK: Method call expectations
    var navigateBackToListOrdersSceneCalled = false
    
    // MARK: Spied methods
    override func navigateBackToListOrdersScene()
    {
      navigateBackToListOrdersSceneCalled = true
    }
  }
  
  // MARK: - Test expiration date
  
  func testDisplayExpirationDateShouldDisplayDateStringInTextField()
  {
    // Given
    let viewModel = CreateOrder.FormatExpirationDate.ViewModel(date: "6/29/07")
    
    // When
    sut.displayExpirationDate(viewModel)
    
    // Then
    let displayedDate = sut.expirationDateTextField.text
    XCTAssertEqual(displayedDate, "6/29/07", "Displaying an expiration date should display the date string in the expiration date text field")
  }
  
  func testExpirationDatePickerValueChangedShouldFormatSelectedDate()
  {
    // Given
    let createOrderViewControllerOutputSpy = CreateOrderViewControllerOutputSpy()
    sut.output = createOrderViewControllerOutputSpy
    
    let dateComponents = NSDateComponents()
    dateComponents.year = 2007
    dateComponents.month = 6
    dateComponents.day = 29
    let selectedDate = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    
    // When
    sut.expirationDatePicker.date = selectedDate
    sut.expirationDatePickerValueChanged(self)
    
    // Then
    XCTAssert(createOrderViewControllerOutputSpy.formatExpirationDateCalled, "Changing the expiration date should format the expiration date")
    let actualDate = createOrderViewControllerOutputSpy.formatExpirationDateRequest.date
    XCTAssertEqual(actualDate, selectedDate, "Changing the expiration date should format the date selected in the date picker")
  }
  
  // MARK: - Test shipping method
  
  func testNumberOfComponentsInPickerViewShouldReturnOneComponent()
  {
    // Given
    let pickerView = sut.shippingMethodPicker
    
    // When
    let numberOfComponents = sut.numberOfComponentsInPickerView(pickerView)
    
    // Then
    XCTAssertEqual(numberOfComponents, 1, "The number of components in the shipping method picker should be 1")
  }
  
  func testNumberOfRowsInFirstComponentOfPickerViewShouldEqualNumberOfAvailableShippingMethods()
  {
    // Given
    let pickerView = sut.shippingMethodPicker
    
    // When
    let numberOfRows = sut.pickerView(pickerView, numberOfRowsInComponent: 0)
    
    // Then
    let numberOfAvailableShippingtMethods = sut.output.shippingMethods.count
    XCTAssertEqual(numberOfRows, numberOfAvailableShippingtMethods, "The number of rows in the first component of shipping method picker should equal to the number of available shipping methods")
  }
  
  func testShippingMethodPickerShouldDisplayProperTitles()
  {
    // Given
    let pickerView = sut.shippingMethodPicker
    
    // When
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
    let pickerView = sut.shippingMethodPicker
    
    // When
    sut.pickerView(pickerView, didSelectRow: 1, inComponent: 0)
    
    // Then
    let expectedShippingMethod = "One-Day Shipping"
    let displayedShippingMethod = sut.shippingMethodTextField.text
    XCTAssertEqual(displayedShippingMethod, expectedShippingMethod, "Selecting a shipping method in the shipping method picker should display the selected shipping method to the user")
  }
  
  // MARK: - Test text fields
  
  func testCursorFocusShouldMoveToNextTextFieldWhenUserTapsReturnKey()
  {
    // Given
    let currentTextField = sut.textFields[0]
    let nextTextField = sut.textFields[1]
    currentTextField.becomeFirstResponder()
    
    // When
    sut.textFieldShouldReturn(currentTextField)
    
    // Then
    XCTAssert(!currentTextField.isFirstResponder(), "Current text field should lose keyboard focus")
    XCTAssert(nextTextField.isFirstResponder(), "Next text field should gain keyboard focus")
  }
  
  func testKeyboardShouldBeDismissedWhenUserTapsReturnKeyWhenFocusIsInLastTextField()
  {
    // Given
    
    // Scroll to the bottom of table view so the last text field is visible and its gesture recognizer is set up
    let lastSectionIndex = sut.tableView.numberOfSections - 1
    let lastRowIndex = sut.tableView.numberOfRowsInSection(lastSectionIndex) - 1
    sut.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRowIndex, inSection: lastSectionIndex), atScrollPosition: .Bottom, animated: false)
    
    // Show keyboard for the last text field
    let numTextFields = sut.textFields.count
    let lastTextField = sut.textFields[numTextFields - 1]
    lastTextField.becomeFirstResponder()
    
    // When
    sut.textFieldShouldReturn(lastTextField)
    
    // Then
    XCTAssert(!lastTextField.isFirstResponder(), "Last text field should lose keyboard focus")
  }
  
  func testTextFieldShouldHaveFocusWhenUserTapsOnTableViewRow()
  {
    // Given
    
    // When
    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
    sut.tableView(sut.tableView, didSelectRowAtIndexPath: indexPath)
    
    // Then
    let textField = sut.textFields[0]
    XCTAssert(textField.isFirstResponder(), "The text field should have keyboard focus when user taps on the corresponding table view row")
  }
  
  // MARK: - Test picker configs when view is loaded
  
  func testCreateOrderViewControllerShouldConfigurePickersWhenViewIsLoaded()
  {
    // Given
    
    // When
    
    // Then
    XCTAssertEqual(sut.expirationDateTextField.inputView, sut.expirationDatePicker, "Expiration date text field should have the expiration date picker as input view")
    XCTAssertEqual(sut.shippingMethodTextField.inputView, sut.shippingMethodPicker, "Shipping method text field should have the shipping method picker as input view")
  }
  
  // MARK: - Test creating a new order
  
  func testSaveButtonTappedShouldCreateOrder()
  {
    // Given
    let createOrderViewControllerOutputSpy = CreateOrderViewControllerOutputSpy()
    sut.output = createOrderViewControllerOutputSpy
    
    // When
    sut.saveButtonTapped(self)
    
    // Then
    XCTAssert(createOrderViewControllerOutputSpy.createOrderCalled, "It should create a new order when the user taps the Save button")
  }
  
  func testDisplaySuccessfullyCreatedOrderShouldNavigateBackToListOrdersScene()
  {
    // Given
    let createOrderRouterSpy = CreateOrderRouterSpy()
    sut.router = createOrderRouterSpy
    
    let viewModel = CreateOrder.CreateOrder.ViewModel(success: true)
    
    // When
    sut.displayCreatedOrder(viewModel)
    
    // Then
    XCTAssert(createOrderRouterSpy.navigateBackToListOrdersSceneCalled, "Displaying a successfully created order should navigate back to the List Orders scene")
  }
  
  func testDisplayCreateOrderFailureShouldShowAnAlert()
  {
    // Given
    let viewModel = CreateOrder.CreateOrder.ViewModel(success: false)
    
    // When
    sut.displayCreatedOrder(viewModel)
    
    // Then
    let alertController = TestDisplayCreateOrderFailureShouldShowAnAlert.viewControllerToPresent as! UIAlertController
    XCTAssert(TestDisplayCreateOrderFailureShouldShowAnAlert.presentViewControllerAnimatedCompletionCalled, "Displaying create order failure should show an alert")
    XCTAssertEqual(alertController.title, "Failed to create order", "Displaying create order failure should display proper title")
    XCTAssertEqual(alertController.message, "Please correct your order and submit again.", "Displaying create order failure should display proper message")
  }
}
