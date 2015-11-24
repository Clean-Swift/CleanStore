import Foundation
import CoreData

class ManagedOrder: NSManagedObject
{
  func toOrder() -> Order
  {
    return Order(id: id, date: date, email: email, firstName: firstName, lastName: lastName, total: total)
  }
}
