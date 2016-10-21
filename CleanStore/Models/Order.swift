import Foundation

struct Order: Equatable
{
  var id: String?
  var date: Date?
  var email: String?
  var firstName: String?
  var lastName: String?
  var total: NSDecimalNumber?
}

func ==(lhs: Order, rhs: Order) -> Bool
{
  var dateEqual = false
  if let lhsDate = lhs.date, let rhsDate = rhs.date {
    dateEqual = lhsDate.timeIntervalSince(rhsDate) < 1.0
  }
  return lhs.id == rhs.id
    && dateEqual
    && lhs.email == rhs.email
    && lhs.firstName == rhs.firstName
    && lhs.lastName == rhs.lastName
    && lhs.total == rhs.total
}
