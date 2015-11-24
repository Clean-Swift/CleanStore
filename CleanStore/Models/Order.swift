import Foundation

struct Order: Equatable
{
  var date: NSDate?
  var id: String?
}

func ==(lhs: Order, rhs: Order) -> Bool
{
  var dateEqual = false
  if let lhsDate = lhs.date, rhsDate = rhs.date {
    dateEqual = lhsDate.timeIntervalSinceDate(rhsDate) < 1.0
  }
  return lhs.id == rhs.id && dateEqual
}
