@testable import CleanStore
import UIKit
import XCTest

class CreateOrderViewControllerTests: XCTestCase
{
  // MARK: Subject under test
  
  var createOrderViewController: CreateOrderViewController!
  var window: UIWindow!
  
  // MARK: Test lifecycle
  
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
  
  // MARK: Test setup
  
  func setupCreateOrderViewController()
  {
    let bundle = Bundle.main
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    createOrderViewController = storyboard.instantiateViewController(withIdentifier: "CreateOrderViewController") as! CreateOrderViewController
    _ = createOrderViewController.view
    addViewToWindow()
  }
  
  func addViewToWindow()
  {
    window.addSubview(createOrderViewController.view)
    RunLoop.current.run(until: Date())
  }
  
  // MARK: Test doubles
  
  class CreateOrderViewControllerOutputSpy: CreateOrderViewControllerOutput
  {
    // MARK: Method call expectations
    var formatExpirationDateCalled = false
    
    // MARK: Argument expectations
    var request: CreateOrder.FormatExpirationDate.Request!
    
    // MARK: Spied variables
    var shippingMethods = [String]()
    
    // MARK: Spied methods
    func formatExpirationDate(_ request: CreateOrder.FormatExpirationDate.Request)
    {
      formatExpirationDateCalled = true
      self.request = request
    }
  }
  
  // MARK: Test expiration date
  
  func testDisplayExpirationDateShouldDisplayDateStringInTextField()
  {
    // Given
    let viewModel = CreateOrder.FormatExpirationDate.ViewModel(date: "6/29/07")
    
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
    
    var dateComponents = DateComponents()
    dateComponents.year = 2007
    dateComponents.month = 6
    dateComponents.day = 29
    let selectedDate = Calendar.current.date(from: dateComponents)!
    
    // When
    createOrderViewController.expirationDatePicker.date = selectedDate
    createOrderViewController.expirationDatePickerValueChanged(self)
    
    // Then
    XCTAssert(createOrderViewControllerOutputSpy.formatExpirationDateCalled, "Changing the expiration date should format the expiration date")
    let actualDate = createOrderViewControllerOutputSpy.request.date
    XCTAssertEqual(actualDate, selectedDate, "Changing the expiration date should format the date selected in the date picker")
  }
  
  // MARK: Test shipping method
  
  func testNumberOfComponentsInPickerViewShouldReturnOneComponent()
  {
    // Given
    let pickerView = createOrderViewController.shippingMethodPicker!
    
    // When
    let numberOfComponents = createOrderViewController.numberOfComponents(in: pickerView)
    
    // Then
    XCTAssertEqual(numberOfComponents, 1, "The number of components in the shipping method picker should be 1")
  }
  
  func testNumberOfRowsInFirstComponentOfPickerViewShouldEqualNumberOfAvailableShippingMethods()
  {
    // Given
    let pickerView = createOrderViewController.shippingMethodPicker!
    
    // When
    let numberOfRows = createOrderViewController.pickerView(pickerView, numberOfRowsInComponent: 0)
    
    // Then
    let numberOfAvailableShippingtMethods = createOrderViewController.output.shippingMethods.count
    XCTAssertEqual(numberOfRows, numberOfAvailableShippingtMethods, "The number of rows in the first component of shipping method picker should equal to the number of available shipping methods")
  }
  
  func testShippingMethodPickerShouldDisplayProperTitles()
  {
    // Given
    let pickerView = createOrderViewController.shippingMethodPicker!
    
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
    let pickerView = createOrderViewController.shippingMethodPicker!
    
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
    
    // When
    _ = createOrderViewController.textFieldShouldReturn(currentTextField)
    
    // Then
    XCTAssert(!currentTextField.isFirstResponder, "Current text field should lose keyboard focus")
    XCTAssert(nextTextField.isFirstResponder, "Next text field should gain keyboard focus")
  }
  
  func testKeyboardShouldBeDismissedWhenUserTapsReturnKeyWhenFocusIsInLastTextField()
  {
    // Given
    
    // Scroll to the bottom of table view so the last text field is visible and its gesture recognizer is set up
    let lastSectionIndex = createOrderViewController.tableView.numberOfSections - 1
    let lastRowIndex = createOrderViewController.tableView.numberOfRows(inSection: lastSectionIndex) - 1
    createOrderViewController.tableView.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: .bottom, animated: false)
    
    // Show keyboard for the last text field
    let numTextFields = createOrderViewController.textFields.count
    let lastTextField = createOrderViewController.textFields[numTextFields - 1]
    lastTextField.becomeFirstResponder()
    
    // When
    _ = createOrderViewController.textFieldShouldReturn(lastTextField)
    
    // Then
    XCTAssert(!lastTextField.isFirstResponder, "Last text field should lose keyboard focus")
  }
  
  func testTextFieldShouldHaveFocusWhenUserTapsOnTableViewRow()
  {
    // Given
    
    // When
    let indexPath = IndexPath(row: 0, section: 0)
    createOrderViewController.tableView(createOrderViewController.tableView, didSelectRowAt: indexPath)
    
    // Then
    let textField = createOrderViewController.textFields[0]
    XCTAssert(textField.isFirstResponder, "The text field should have keyboard focus when user taps on the corresponding table view row")
  }
  
  // MARK: Test picker configs when view is loaded
  
  func testCreateOrderViewControllerShouldConfigurePickersWhenViewIsLoaded()
  {
    // Given
    
    // When
    
    // Then
    XCTAssertEqual(createOrderViewController.expirationDateTextField.inputView, createOrderViewController.expirationDatePicker, "Expiration date text field should have the expiration date picker as input view")
    XCTAssertEqual(createOrderViewController.shippingMethodTextField.inputView, createOrderViewController.shippingMethodPicker, "Shipping method text field should have the shipping method picker as input view")
  }
}
