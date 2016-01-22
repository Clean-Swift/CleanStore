import CoreData

class OrdersCoreDataStore: OrdersStoreProtocol {
  // MARK: - Managed object contexts
  
  var mainManagedObjectContext: NSManagedObjectContext
  var privateManagedObjectContext: NSManagedObjectContext
  
  // MARK: - Object lifecycle
  
  init() {
    // This resource is the same name as your xcdatamodeld contained in your project.
    guard let modelURL = NSBundle.mainBundle().URLForResource("CleanStore", withExtension:"momd") else {
      fatalError("Error loading model from bundle")
    }
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
      fatalError("Error initializing mom from: \(modelURL)")
    }
    
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
    mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    mainManagedObjectContext.persistentStoreCoordinator = psc
    
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    let docURL = urls[urls.endIndex-1]
    /* The directory the application uses to store the Core Data store file.
    This code uses a file named "DataModel.sqlite" in the application's documents directory.
    */
    let storeURL = docURL.URLByAppendingPathComponent("CleanStore.sqlite")
    do {
      try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
    } catch {
      fatalError("Error migrating store: \(error)")
    }
  
    privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    privateManagedObjectContext.parentContext = mainManagedObjectContext
  }
  
  deinit {
    do {
      try self.mainManagedObjectContext.save()
    } catch {
      fatalError("Error deinitializing main managed object context")
    }
  }
  
  // MARK: - CRUD operations - Optional error
  
  func fetchOrders(completionHandler: (orders: [Order], error: OrdersStoreError?) -> Void) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        let orders = results.map { $0.toOrder() }
        completionHandler(orders: orders, error: nil)
      } catch {
        completionHandler(orders: [], error: OrdersStoreError.CannotFetch("Cannot fetch orders"))
      }
    }
  }
  
  func fetchOrder(id: String, completionHandler: (order: Order?, error: OrdersStoreError?) -> Void) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        if let order = results.first?.toOrder() {
          completionHandler(order: order, error: nil)
        } else {
          completionHandler(order: nil, error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)"))
        }
      } catch {
        completionHandler(order: nil, error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)"))
      }
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: (error: OrdersStoreError?) -> Void) {
    privateManagedObjectContext.performBlock {
      do {
        let managedOrder = NSEntityDescription.insertNewObjectForEntityForName("ManagedOrder", inManagedObjectContext: self.privateManagedObjectContext) as! ManagedOrder
        managedOrder.id = orderToCreate.id
        managedOrder.date = orderToCreate.date
        managedOrder.email = orderToCreate.email
        managedOrder.firstName = orderToCreate.firstName
        managedOrder.lastName = orderToCreate.lastName
        managedOrder.total = orderToCreate.total
        try self.privateManagedObjectContext.save()
        completionHandler(error: nil)
      } catch {
        completionHandler(error: OrdersStoreError.CannotCreate("Cannot create order with id \(orderToCreate.id)"))
      }
    }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (error: OrdersStoreError?) -> Void) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderToUpdate.id!)
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          do {
            managedOrder.id = orderToUpdate.id
            managedOrder.date = orderToUpdate.date
            managedOrder.email = orderToUpdate.email
            managedOrder.firstName = orderToUpdate.firstName
            managedOrder.lastName = orderToUpdate.lastName
            managedOrder.total = orderToUpdate.total
            try self.privateManagedObjectContext.save()
            completionHandler(error: nil)
          } catch {
            completionHandler(error: OrdersStoreError.CannotUpdate("Cannot update order with id \(orderToUpdate.id)"))
          }
        }
      } catch {
        completionHandler(error: OrdersStoreError.CannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update"))
      }
    }
  }
  
  func deleteOrder(id: String, completionHandler: (error: OrdersStoreError?) -> Void) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          self.privateManagedObjectContext.deleteObject(managedOrder)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler(error: nil)
          } catch {
            completionHandler(error: OrdersStoreError.CannotDelete("Cannot delete order with id \(id)"))
          }
        } else {
          throw OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete")
        }
      } catch {
        completionHandler(error: OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete"))
      }
    }
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: OrdersStoreFetchOrdersCompletionHandler) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        let orders = results.map { $0.toOrder() }
        completionHandler(result: OrdersStoreResult.Success(result: orders))
      } catch {
        completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotFetch("Cannot fetch orders")))
      }
    }
  }
  
  func fetchOrder(id: String, completionHandler: OrdersStoreFetchOrderCompletionHandler) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        if let order = results.first?.toOrder() {
          completionHandler(result: OrdersStoreResult.Success(result: order))
        } else {
          completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)")))
        }
      } catch {
        completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)")))
      }
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: OrdersStoreCreateOrderCompletionHandler) {
    privateManagedObjectContext.performBlock {
      do {
        let managedOrder = NSEntityDescription.insertNewObjectForEntityForName("ManagedOrder", inManagedObjectContext: self.privateManagedObjectContext) as! ManagedOrder
        managedOrder.id = orderToCreate.id
        managedOrder.date = orderToCreate.date
        managedOrder.email = orderToCreate.email
        managedOrder.firstName = orderToCreate.firstName
        managedOrder.lastName = orderToCreate.lastName
        managedOrder.total = orderToCreate.total
        try self.privateManagedObjectContext.save()
        completionHandler(result: OrdersStoreResult.Success(result: ()))
      } catch {
        let error = OrdersStoreError.CannotCreate("Cannot create order with id \(orderToCreate.id)")
        completionHandler(result: OrdersStoreResult.Failure(error: error))
      }
    }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: OrdersStoreUpdateOrderCompletionHandler) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderToUpdate.id!)
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          do {
            managedOrder.id = orderToUpdate.id
            managedOrder.date = orderToUpdate.date
            managedOrder.email = orderToUpdate.email
            managedOrder.firstName = orderToUpdate.firstName
            managedOrder.lastName = orderToUpdate.lastName
            managedOrder.total = orderToUpdate.total
            try self.privateManagedObjectContext.save()
            completionHandler(result: OrdersStoreResult.Success(result: ()))
          } catch {
            completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotUpdate("Cannot update order with id \(orderToUpdate.id)")))
          }
        }
      } catch {
        completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update")))
      }
    }
  }
  
  func deleteOrder(id: String, completionHandler: OrdersStoreDeleteOrderCompletionHandler) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          self.privateManagedObjectContext.deleteObject(managedOrder)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler(result: OrdersStoreResult.Success(result: ()))
          } catch {
            completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotDelete("Cannot delete order with id \(id)")))
          }
        } else {
          completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete")))
        }
      } catch {
        completionHandler(result: OrdersStoreResult.Failure(error: OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete")))
      }
    }
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: (orders: () throws -> [Order]) -> Void) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        let orders = results.map { $0.toOrder() }
        completionHandler { return orders }
      } catch {
        completionHandler { throw OrdersStoreError.CannotFetch("Cannot fetch orders") }
      }
    }
  }
  
  func fetchOrder(id: String, completionHandler: (order: () throws -> Order?) -> Void) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        if let order = results.first?.toOrder() {
          completionHandler { return order }
        } else {
          throw OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)")
        }
      } catch {
        completionHandler { throw OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)") }
      }
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: (done: () throws -> Void) -> Void) {
    privateManagedObjectContext.performBlock {
      do {
        let managedOrder = NSEntityDescription.insertNewObjectForEntityForName("ManagedOrder", inManagedObjectContext: self.privateManagedObjectContext) as! ManagedOrder
        managedOrder.id = orderToCreate.id
        managedOrder.date = orderToCreate.date
        managedOrder.email = orderToCreate.email
        managedOrder.firstName = orderToCreate.firstName
        managedOrder.lastName = orderToCreate.lastName
        managedOrder.total = orderToCreate.total
        try self.privateManagedObjectContext.save()
        completionHandler { return }
      } catch {
        completionHandler { throw OrdersStoreError.CannotCreate("Cannot create order with id \(orderToCreate.id)") }
      }
    }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: (done: () throws -> Void) -> Void) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderToUpdate.id!)
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          do {
            managedOrder.id = orderToUpdate.id
            managedOrder.date = orderToUpdate.date
            managedOrder.email = orderToUpdate.email
            managedOrder.firstName = orderToUpdate.firstName
            managedOrder.lastName = orderToUpdate.lastName
            managedOrder.total = orderToUpdate.total
            try self.privateManagedObjectContext.save()
            completionHandler { return }
          } catch {
            completionHandler { throw OrdersStoreError.CannotUpdate("Cannot update order with id \(orderToUpdate.id)") }
          }
        }
      } catch {
        completionHandler { throw OrdersStoreError.CannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update") }
      }
    }
  }
  
  func deleteOrder(id: String, completionHandler: (done: () throws -> Void) -> Void) {
    privateManagedObjectContext.performBlock {
      do {
        let fetchRequest = NSFetchRequest(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          self.privateManagedObjectContext.deleteObject(managedOrder)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler { return }
          } catch {
            completionHandler { throw OrdersStoreError.CannotDelete("Cannot delete order with id \(id)") }
          }
        } else {
          throw OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete")
        }
      } catch {
        completionHandler { throw OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete") }
      }
    }
  }
}
