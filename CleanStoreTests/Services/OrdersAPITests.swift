@testable import CleanStore
import XCTest

class OrdersAPITests: XCTestCase
{
  // MARK: - Subject under test
  
  var sut: OrdersAPI!
  var testOrders: [Order]!
  
  // MARK: - Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupOrdersAPI()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: - Test setup
  
  func setupOrdersAPI()
  {
    sut = OrdersAPI()
    
    testOrders = [Seeds.Orders.amy, Seeds.Orders.bob]
  }
  
  // MARK: - Test CRUD operations - Optional error
  
  func testFetchOrdersShouldReturnListOfOrders_OptionalError()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testFetchOrderShouldReturnOrder_OptionalError()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testCreateOrderShouldCreateNewOrder_OptionalError()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_OptionalError()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_OptionalError()
  {
    // Given
    
    // When
    
    // Then
  }
  
  // MARK: - Test CRUD operations - Generic enum result type
  
  func testFetchOrdersShouldReturnListOfOrders_GenericEnumResultType()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testFetchOrderShouldReturnOrder_GenericEnumResultType()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testCreateOrderShouldCreateNewOrder_GenericEnumResultType()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_GenericEnumResultType()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_GenericEnumResultType()
  {
    // Given
    
    // When
    
    // Then
  }
  
  // MARK: - Test CRUD operations - Inner closure
  
  func testFetchOrdersShouldReturnListOfOrders_InnerClosure()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testFetchOrderShouldReturnOrder_InnerClosure()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testCreateOrderShouldCreateNewOrder_InnerClosure()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testUpdateOrderShouldUpdateExistingOrder_InnerClosure()
  {
    // Given
    
    // When
    
    // Then
  }
  
  func testDeleteOrderShouldDeleteExistingOrder_InnerClosure()
  {
    // Given
    
    // When
    
    // Then
  }
}
