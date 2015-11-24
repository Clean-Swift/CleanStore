import Foundation

struct Order: Equatable
{
  var id: String?
  var date: NSDate?
  var email: String?
  var firstName: String?
  var lastName: String?
  var total: NSDecimalNumber?
}

func ==(lhs: Order, rhs: Order) -> Bool
{
  var dateEqual = false
  if let lhsDate = lhs.date, rhsDate = rhs.date {
    dateEqual = lhsDate.timeIntervalSinceDate(rhsDate) < 1.0
  }
  return lhs.id == rhs.id
    && dateEqual
    && lhs.email == rhs.email
    && lhs.firstName == rhs.firstName
    && lhs.lastName == rhs.lastName
    && lhs.total == rhs.total
}
