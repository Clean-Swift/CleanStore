import Foundation
import CoreData

class ManagedOrder: NSManagedObject
{
  func toOrder() -> Order
  {
    return Order(date: date, id: id)
  }
}
