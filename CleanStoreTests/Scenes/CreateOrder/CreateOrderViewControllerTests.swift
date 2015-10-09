import UIKit
import XCTest

class CreateOrderViewControllerTests: XCTestCase
{
  // MARK: Subject under test
  
  var createOrderViewController: CreateOrderViewController!
  let window = UIWindow()
  
  // MARK: Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupCreateOrderViewController()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupCreateOrderViewController()
  {
    let bundle = NSBundle(forClass: self.dynamicType)
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    createOrderViewController = storyboard.instantiateViewControllerWithIdentifier("CreateOrderViewController") as! CreateOrderViewController
    _ = createOrderViewController.view
    addViewToWindow()
  }
  
  func addViewToWindow()
  {
    window.addSubview(createOrderViewController.view)
    NSRunLoop.currentRunLoop().runUntilDate(NSDate())
  }
  
  // MARK: Test doubles
  
  class CreateOrderViewControllerOutputSpy: CreateOrderViewControllerOutput
  {
    // MARK: Method call expectations
    var formatExpirationDateCalled = false
    
    // MARK: Argument expectations
    var createOrder_formatExpirationDate_request: CreateOrder_FormatExpirationDate_Request!
    
    // MARK: Spied variables
    var shippingMethods = [String]()
    
    // MARK: Spied methods
    func formatExpirationDate(request: CreateOrder_FormatExpirationDate_Request)
    {
      formatExpirationDateCalled = true
      createOrder_formatExpirationDate_request = request
    }
  }
  
  // MARK: Test expiration date
  
  func testDisplayExpirationDateShouldDisplayDateStringInTextField()
  {
    // Given
    let viewModel = CreateOrder_FormatExpirationDate_ViewModel(date: "6/29/07")
    
    // When
    createOrderViewController.displayExpirationDate(viewModel)
    
    // Then
    let displayedDate = createOrderViewController.expirationDateTextField.text
    XCTAssertEqual(displayedDate, "6/29/07", "Displaying an expiration date should display the date string in the expiration date text field")
  }
  
  func testExpirationDatePickerValueChangedShouldFormatSelectedDate()
  {
    // Given
    let createOrderViewControllerOutputSpy = CreateOrderViewControllerOutputSpy()
    createOrderViewController.output = createOrderViewControllerOutputSpy
    
    let dateComponents = NSDateComponents()
    dateComponents.year = 2007
    dateComponents.month = 6
    dateComponents.day = 29
    let selectedDate = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    
    // When
    createOrderViewController.expirationDatePicker.date = selectedDate
    createOrderViewController.expirationDatePickerValueChanged(self)
    
    // Then
    XCTAssert(createOrderViewControllerOutputSpy.formatExpirationDateCalled, "Changing the expiration date should format the expiration date")
    let actualDate = createOrderViewControllerOutputSpy.createOrder_formatExpirationDate_request.date
    XCTAssertEqual(actualDate, selectedDate, "Changing the expiration date should format the date selected in the date picker")
  }
  
  // MARK: Test shipping method
  
  func testNumberOfComponentsInPickerViewShouldReturnOneComponent()
  {
    // Given
    let pickerView = createOrderViewController.shippingMethodPicker
    
    // When
    let numberOfComponents = createOrderViewController.numberOfComponentsInPickerView(pickerView)
    
    // Then
    XCTAssertEqual(numberOfComponents, 1, "The number of components in the shipping method picker should be 1")
  }
  
  func testNumberOfRowsInFirstComponentOfPickerViewShouldEqualNumberOfAvailableShippingMethods()
  {
    // Given
    let pickerView = createOrderViewController.shippingMethodPicker
    
    // When
    let numberOfRows = createOrderViewController.pickerView(pickerView, numberOfRowsInComponent: 0)
    
    // Then
    let numberOfAvailableShippingtMethods = createOrderViewController.output.shippingMethods.count
    XCTAssertEqual(numberOfRows, numberOfAvailableShippingtMethods, "The number of rows in the first component of shipping method picker should equal to the number of available shipping methods")
  }
  
  func testShippingMethodPickerShouldDisplayProperTitles()
  {
    // Given
    let pickerView = createOrderViewController.shippingMethodPicker
    
    // When
    let returnedTitles = [
      createOrderViewController.pickerView(pickerView, titleForRow: 0, forComponent: 0),
      createOrderViewController.pickerView(pickerView, titleForRow: 1, forComponent: 0),
      createOrderViewController.pickerView(pickerView, titleForRow: 2, forComponent: 0)
    ]
    
    // Then
    var expectedTitles = [
      "Standard Shipping",
      "Two-Day Shipping",
      "One-Day Shipping"
    ]
    XCTAssertEqual(returnedTitles[0], expectedTitles[0], "The shipping method picker should display proper titles")
    XCTAssertEqual(returnedTitles[1], expectedTitles[1], "The shipping method picker should display proper titles")
    XCTAssertEqual(returnedTitles[2], expectedTitles[2], "The shipping method picker should display proper titles")
  }
  
  func testSelectingShippingMethodInThePickerShouldDisplayTheSelectedShippingMethodToUser()
  {
    // Given
    let pickerView = createOrderViewController.shippingMethodPicker
    
    // When
    createOrderViewController.pickerView(pickerView, didSelectRow: 1, inComponent: 0)
    
    // Then
    let expectedShippingMethod = "Two-Day Shipping"
    let displayedShippingMethod = createOrderViewController.shippingMethodTextField.text
    XCTAssertEqual(displayedShippingMethod, expectedShippingMethod, "Selecting a shipping method in the shipping method picker should display the selected shipping method to the user")
  }

  // MARK: Test text fields
  
  func testCursorFocusShouldMoveToNextTextFieldWhenUserTapsReturnKey()
  {
    // Given
    let currentTextField = createOrderViewController.textFields[0]
    let nextTextField = createOrderViewController.textFields[1]
    currentTextField.becomeFirstResponder()
    NSRunLoop.currentRunLoop().runUntilDate(NSDate())
    
    // When
    createOrderViewController.textFieldShouldReturn(currentTextField)
    
    // Then
    XCTAssert(!currentTextField.isFirstResponder(), "Current text field should lose keyboard focus")
    XCTAssert(nextTextField.isFirstResponder(), "Next text field should gain keyboard focus")
  }
  
  func testKeyboardShouldBeDismissedWhenUserTapsReturnKeyWhenFocusIsInLastTextField()
  {
    // Given
    
    // Scroll to the bottom of table view so the last text field is visible and its gesture recognizer is set up
    let lastSectionIndex = createOrderViewController.tableView.numberOfSections - 1
    let lastRowIndex = createOrderViewController.tableView.numberOfRowsInSection(lastSectionIndex) - 1
    createOrderViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRowIndex, inSection: lastSectionIndex), atScrollPosition: .Bottom, animated: false)
    
    // Show keyboard for the last text field
    let numTextFields = createOrderViewController.textFields.count
    let lastTextField = createOrderViewController.textFields[numTextFields - 1]
    lastTextField.becomeFirstResponder()
    NSRunLoop.currentRunLoop().runUntilDate(NSDate())
    
    expectationForNotification(UIKeyboardWillHideNotification, object: nil) { (notification: NSNotification) -> Bool in
      return true
    }
    NSRunLoop.currentRunLoop().runUntilDate(NSDate())
    
    // When
    createOrderViewController.textFieldShouldReturn(lastTextField)
    NSRunLoop.currentRunLoop().runUntilDate(NSDate())
    
    // Then
    waitForExpectationsWithTimeout(5.0) { (error: NSError?) -> Void in
      XCTAssert(!lastTextField.isFirstResponder(), "Last text field should lose keyboard focus")
      XCTAssert(true, "Keyboard should be dismissed when user taps the return key while focus is in the last text field")
    }
  }
  
  func testKeyboardShouldBeDismissedWhenUserTapsReturnKeyWhenFocusIsInLastTextField2()
  {
    // Given
    
    // Scroll to the bottom of table view so the last text field is visible and its gesture recognizer is set up
    let lastSectionIndex = createOrderViewController.tableView.numberOfSections - 1
    let lastRowIndex = createOrderViewController.tableView.numberOfRowsInSection(lastSectionIndex) - 1
    createOrderViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRowIndex, inSection: lastSectionIndex), atScrollPosition: .Bottom, animated: false)
    
    // Show keyboard for the last text field
    let numTextFields = createOrderViewController.textFields.count
    let lastTextField = createOrderViewController.textFields[numTextFields - 1]
    lastTextField.becomeFirstResponder()
    NSRunLoop.currentRunLoop().runUntilDate(NSDate())
    
    let expectation = expectationWithDescription("UIKeyboardWillHideNotification")
    let observer = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) -> Void in
      expectation.fulfill()
    }
    NSRunLoop.currentRunLoop().runUntilDate(NSDate())
    
    // When
    createOrderViewController.textFieldShouldReturn(lastTextField)
    NSRunLoop.currentRunLoop().runUntilDate(NSDate())
    
    // Then
    waitForExpectationsWithTimeout(5.0) { (error: NSError?) -> Void in
      XCTAssert(!lastTextField.isFirstResponder(), "Last text field should lose keyboard focus")
      XCTAssert(true, "Keyboard should be dismissed when user taps the return key while focus is in the last text field")
    }
    NSNotificationCenter.defaultCenter().removeObserver(observer, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func testTextFieldShouldHaveFocusWhenUserTapsOnTableViewRow()
  {
    // Given
    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    let textField = createOrderViewController.textFields[0]
    
    // When
    createOrderViewController.tableView(createOrderViewController.tableView, didSelectRowAtIndexPath: indexPath)
    
    // Then
    XCTAssert(textField.isFirstResponder(), "The text field should have keyboard focus when user taps on the corresponding table view row")
  }
  
  // MARK: Test picker configs when view is loaded
  
  func testCreateOrderViewControllerShouldConfigurePickersWhenViewIsLoaded() // viewDidLoad() -> configurePickers()
  {
    // Given
    
    // When
    
    // Then
    XCTAssertEqual(createOrderViewController.shippingMethodTextField.inputView, createOrderViewController.shippingMethodPicker, "")
    XCTAssertEqual(createOrderViewController.expirationDateTextField.inputView, createOrderViewController.expirationDatePicker, "")
  }
}
