@testable import CleanStore
import UIKit
import XCTest

class CreateOrderPresenterTests: XCTestCase
{
  // MARK: Subject under test
  
  var createOrderPresenter: CreateOrderPresenter!
  
  // MARK: Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupCreateOrderPresenter()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupCreateOrderPresenter()
  {
    createOrderPresenter = CreateOrderPresenter()
  }
  
  // MARK: Test doubles
  
  class CreateOrderPresenterOutputSpy: CreateOrderPresenterOutput
  {
    // MARK: Method call expectations
    var displayExpirationDateCalled = false
    
    // MARK: Argument expectations
    var createOrder_formatExpirationDate_viewModel: CreateOrder_FormatExpirationDate_ViewModel!
    
    // MARK: Spied methods
    func displayExpirationDate(viewModel: CreateOrder_FormatExpirationDate_ViewModel)
    {
      displayExpirationDateCalled = true
      createOrder_formatExpirationDate_viewModel = viewModel
    }
  }
  
  class CreateOrderPresenterOutputMock: CreateOrderPresenterOutput
  {
    // MARK: Method call expectations
    var displayExpirationDateCalled = false
    
    // MARK: Argument expectations
    var createOrder_formatExpirationDate_viewModel: CreateOrder_FormatExpirationDate_ViewModel!
    
    // MARK: Spied methods
    func displayExpirationDate(viewModel: CreateOrder_FormatExpirationDate_ViewModel)
    {
      displayExpirationDateCalled = true
      createOrder_formatExpirationDate_viewModel = viewModel
    }
    
    // MARK: Verifications
    func verifyDisplayExpirationDateIsCalled() -> Bool
    {
      return displayExpirationDateCalled
    }
    
    func verifyExpirationDateIsFormattedAs(date: String) -> Bool
    {
      return createOrder_formatExpirationDate_viewModel.date == date
    }
  }
  
  // MARK: Test expiration date
  
  func testPresentExpirationDateShouldConvertDateToStringUsingSpy()
  {
    // Given
    let createOrderPresenterOutputSpy = CreateOrderPresenterOutputSpy()
    createOrderPresenter.output = createOrderPresenterOutputSpy
    
    let dateComponents = NSDateComponents()
    dateComponents.year = 2007
    dateComponents.month = 6
    dateComponents.day = 29
    let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    let response = CreateOrder_FormatExpirationDate_Response(date: date)
    
    // When
    createOrderPresenter.presentExpirationDate(response)
    
    // Then
    let returnedDate = createOrderPresenterOutputSpy.createOrder_formatExpirationDate_viewModel.date
    let expectedDate = "6/29/07"
    XCTAssertEqual(returnedDate, expectedDate, "Presenting an expiration date should convert date to string")
  }
  
  func testPresentExpirationDateShouldAskViewControllerToDisplayDateStringUsingSpy()
  {
    // Given
    let createOrderPresenterOutputSpy = CreateOrderPresenterOutputSpy()
    createOrderPresenter.output = createOrderPresenterOutputSpy
    let response = CreateOrder_FormatExpirationDate_Response(date: NSDate())
    
    // When
    createOrderPresenter.presentExpirationDate(response)
    
    // Then
    XCTAssert(createOrderPresenterOutputSpy.displayExpirationDateCalled, "Presenting an expiration date should ask view controller to display date string")
  }
  
  func testPresentExpirationDateShouldConvertDateToStringUsingMock()
  {
    // Given
    let createOrderPresenterOutputMock = CreateOrderPresenterOutputMock()
    createOrderPresenter.output = createOrderPresenterOutputMock
    
    let dateComponents = NSDateComponents()
    dateComponents.year = 2007
    dateComponents.month = 6
    dateComponents.day = 29
    let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    let response = CreateOrder_FormatExpirationDate_Response(date: date)
    
    // When
    createOrderPresenter.presentExpirationDate(response)
    
    // Then
    let expectedDate = "6/29/07"
    XCTAssert(createOrderPresenterOutputMock.verifyExpirationDateIsFormattedAs(expectedDate), "Presenting an expiration date should convert date to string")
  }
  
  func testPresentExpirationDateShouldAskViewControllerToDisplayDateStringUsingMock()
  {
    // Given
    let createOrderPresenterOutputMock = CreateOrderPresenterOutputMock()
    createOrderPresenter.output = createOrderPresenterOutputMock
    let response = CreateOrder_FormatExpirationDate_Response(date: NSDate())
    
    // When
    createOrderPresenter.presentExpirationDate(response)
    
    // Then
    XCTAssert(createOrderPresenterOutputMock.verifyDisplayExpirationDateIsCalled(), "Presenting an expiration date should ask view controller to display date string")
  }
}
