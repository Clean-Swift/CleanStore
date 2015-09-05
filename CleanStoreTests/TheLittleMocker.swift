//
//  TheLittleMocker.swift
//  CleanStoreTests
//
//  This file translates Uncle Bob's The Little Mocker from Java to Swift. You
//  can read the post at http://clean-swift.com/swifty-little-mocker/
//

import UIKit
import XCTest

protocol Authorizer
{
  func authorize(username: String, password: String) -> Bool?
}

class DummyAuthorizer: Authorizer
{
  func authorize(username: String, password: String) -> Bool?
  {
    return nil
  }
}

class AcceptingAuthorizerStub: Authorizer
{
  func authorize(username: String, password: String) -> Bool?
  {
    return true
  }
}

class AcceptingAuthorizerSpy: Authorizer
{
  var authorizeWasCalled = false
  
  func authorize(username: String, password: String) -> Bool?
  {
    authorizeWasCalled = true
    return true
  }
}

class AcceptingAuthorizerVerificationMock: Authorizer
{
  var authorizeWasCalled = false
  
  func authorize(username: String, password: String) -> Bool?
  {
    authorizeWasCalled = true
    return true
  }
  
  func verify() -> Bool
  {
    return authorizeWasCalled
  }
}

class AcceptingAuthorizerFake: Authorizer
{
  func authorize(username: String, password: String) -> Bool?
  {
    return username == "Bob"
  }
}

class System
{
  var authorizer: Authorizer
  
  init(authorizer: Authorizer)
  {
    self.authorizer = authorizer
  }
  
  func loginCount() -> Int
  {
    return 0
  }
}

class TheLittleMocker: XCTestCase
{
  func testNewlyCreatedSystem_hasNoLoggedInUsers()
  {
    let system = System(authorizer: DummyAuthorizer())
    XCTAssert(system.loginCount() == 0, "Pass")
  }
}
