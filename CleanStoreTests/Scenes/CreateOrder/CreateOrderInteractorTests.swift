import UIKit
import XCTest

class CreateOrderInteractorTests: XCTestCase
{
  // Subject under test
  var createOrderInteractor: CreateOrderInteractor!
  
  // MARK: Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupCreateOrderInteractor()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupCreateOrderInteractor()
  {
    let bundle = NSBundle(forClass: self.dynamicType)
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    let createOrderViewController = storyboard.instantiateViewControllerWithIdentifier("CreateOrderViewController") as! CreateOrderViewController
    createOrderInteractor = createOrderViewController.output as! CreateOrderInteractor
  }
  
  // MARK: Test doubles
  
  class CreateOrderInteractorOutputSpy: CreateOrderInteractorOutput
  {
    var presentExpirationDateCalled = false
    
    func presentExpirationDate(response: CreateOrder_FormatExpirationDate_Response)
    {
      presentExpirationDateCalled = true
    }
  }
  
  // MARK: Test expiration date
  
  func testFormatExpirationDateShouldAskPresenterToFormatExpirationDate()
  {
    // Given
    let createOrderInteractorOutputSpy = CreateOrderInteractorOutputSpy()
    createOrderInteractor.output = createOrderInteractorOutputSpy
    let request = CreateOrder_FormatExpirationDate_Request(date: NSDate())
    
    // When
    createOrderInteractor.formatExpirationDate(request)
    
    // Then
    XCTAssert(createOrderInteractorOutputSpy.presentExpirationDateCalled, "Formatting an expiration date should ask presenter to do it")
  }
  
  // MARK: Test shipping methods
  
  func testShippingMethodsShouldReturnAllAvailableShippingMethods()
  {
    // Given
    let allAvailableShippingMethods = [
      "Standard Shipping",
      "Two-Day Shipping ",
      "One-Day Shipping "
    ]
    
    // When
    let returnedShippingMethods = createOrderInteractor.shippingMethods
    
    // Then
    XCTAssertEqual(returnedShippingMethods, allAvailableShippingMethods, "Shipping Methods should list all available shipping methods")
  }
}
