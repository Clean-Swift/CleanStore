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
    
    // MARK: Argument expectations
    var formatExpirationDateViewModel: CreateOrder.FormatExpirationDate.ViewModel!
    var createOrderViewModel: CreateOrder.CreateOrder.ViewModel!
    
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
  }
  
  class CreateOrderPresenterOutputMock: CreateOrderPresenterOutput
  {
    // MARK: Method call expectations
    var displayExpirationDateCalled = false
    
    // MARK: Argument expectations
    var viewModel: CreateOrder.FormatExpirationDate.ViewModel!
    
    // MARK: Spied methods
    func displayExpirationDate(viewModel: CreateOrder.FormatExpirationDate.ViewModel)
    {
      displayExpirationDateCalled = true
      self.viewModel = viewModel
    }
    
    func displayCreatedOrder(viewModel: CreateOrder.CreateOrder.ViewModel)
    {
      
    }
    
    // MARK: Verifications
    func verifyDisplayExpirationDateIsCalled() -> Bool
    {
      return displayExpirationDateCalled
    }
    
    func verifyExpirationDateIsFormattedAs(date: String) -> Bool
    {
      return viewModel.date == date
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
  
  func testPresentCreatedOrderShouldAskViewControllerToDisplayFetchedOrders()
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
}
