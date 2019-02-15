@testable import CleanStore
import XCTest

struct Seeds
{
  struct Orders
  {
    static let billingAddress = Address(street1: "1 Infinite Loop", street2: "", city: "Cupertino", state: "CA", zip: "95014")
    static let shipmentAddress = Address(street1: "One Microsoft Way", street2: "", city: "Redmond", state: "WA", zip: "98052-7329")
    static let paymentMethod = PaymentMethod(creditCardNumber: "1234-123456-1234", expirationDate: Date(), cvv: "999")
    static let shipmentMethod = ShipmentMethod(speed: .Standard)
    
    static let amy = Order(firstName: "Amy", lastName: "Apple", phone: "111-111-1111", email: "amy.apple@clean-swift.com", billingAddress: billingAddress, paymentMethod: paymentMethod, shipmentAddress: shipmentAddress, shipmentMethod: shipmentMethod, id: "aaa111", date: Date(), total: NSDecimalNumber(string: "1.11"))
    static let bob = Order(firstName: "Bob", lastName: "Battery", phone: "222-222-2222", email: "bob.battery@clean-swift.com", billingAddress: billingAddress, paymentMethod: paymentMethod, shipmentAddress: shipmentAddress, shipmentMethod: shipmentMethod, id: "bbb222", date: Date(), total: NSDecimalNumber(string: "2.22"))
    static let chris = Order(firstName: "Chris", lastName: "Camera", phone: "333-333-3333", email: "chris.camera@clean-swift.com", billingAddress: billingAddress, paymentMethod: paymentMethod, shipmentAddress: shipmentAddress, shipmentMethod: shipmentMethod, id: "ccc333", date: Date(), total: NSDecimalNumber(string: "3.33"))
  }
}
