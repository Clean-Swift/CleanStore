import CoreData

class OrdersCoreDataStore: OrdersStoreProtocol
{
  // MARK: - Managed object contexts
  
  var mainManagedObjectContext: NSManagedObjectContext
  var privateManagedObjectContext: NSManagedObjectContext
  
  // MARK: - Object lifecycle
  
  init()
  {
    // This resource is the same name as your xcdatamodeld contained in your project.
    guard let modelURL = Bundle.main.url(forResource: "CleanStore", withExtension:"momd") else {
      fatalError("Error loading model from bundle")
    }
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Error initializing mom from: \(modelURL)")
    }
    
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
    mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    mainManagedObjectContext.persistentStoreCoordinator = psc
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docURL = urls[urls.endIndex-1]
    /* The directory the application uses to store the Core Data store file.
    This code uses a file named "DataModel.sqlite" in the application's documents directory.
    */
    let storeURL = docURL.appendingPathComponent("CleanStore.sqlite")
    do {
      try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    } catch {
      fatalError("Error migrating store: \(error)")
    }
  
    privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    privateManagedObjectContext.parent = mainManagedObjectContext
  }
  
  deinit
  {
    do {
      try self.mainManagedObjectContext.save()
    } catch {
      fatalError("Error deinitializing main managed object context")
    }
  }
  
  // MARK: - CRUD operations - Optional error
  
  func fetchOrders(_ completionHandler: @escaping (_ orders: [Order], _ error: OrdersStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        let orders = results.map { $0.toOrder() }
        completionHandler(orders, nil)
      } catch {
        completionHandler([], OrdersStoreError.cannotFetch("Cannot fetch orders"))
      }
    }
  }
  
  func fetchOrder(_ id: String, completionHandler: @escaping (_ order: Order?, _ error: OrdersStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let order = results.first?.toOrder() {
          completionHandler(order, nil)
        } else {
          completionHandler(nil, OrdersStoreError.cannotFetch("Cannot fetch order with id \(id)"))
        }
      } catch {
        completionHandler(nil, OrdersStoreError.cannotFetch("Cannot fetch order with id \(id)"))
      }
    }
  }
  
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let managedOrder = NSEntityDescription.insertNewObject(forEntityName: "ManagedOrder", into: self.privateManagedObjectContext) as! ManagedOrder
        managedOrder.id = orderToCreate.id
        managedOrder.date = orderToCreate.date
        managedOrder.email = orderToCreate.email
        managedOrder.firstName = orderToCreate.firstName
        managedOrder.lastName = orderToCreate.lastName
        managedOrder.total = orderToCreate.total
        try self.privateManagedObjectContext.save()
        completionHandler(nil)
      } catch {
        completionHandler(OrdersStoreError.cannotCreate("Cannot create order with id \(orderToCreate.id)"))
      }
    }
  }
  
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          do {
            managedOrder.id = orderToUpdate.id
            managedOrder.date = orderToUpdate.date
            managedOrder.email = orderToUpdate.email
            managedOrder.firstName = orderToUpdate.firstName
            managedOrder.lastName = orderToUpdate.lastName
            managedOrder.total = orderToUpdate.total
            try self.privateManagedObjectContext.save()
            completionHandler(nil)
          } catch {
            completionHandler(OrdersStoreError.cannotUpdate("Cannot update order with id \(orderToUpdate.id)"))
          }
        }
      } catch {
        completionHandler(OrdersStoreError.cannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update"))
      }
    }
  }
  
  func deleteOrder(_ id: String, completionHandler: @escaping (_ error: OrdersStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          self.privateManagedObjectContext.delete(managedOrder)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler(nil)
          } catch {
            completionHandler(OrdersStoreError.cannotDelete("Cannot delete order with id \(id)"))
          }
        } else {
          throw OrdersStoreError.cannotDelete("Cannot fetch order with id \(id) to delete")
        }
      } catch {
        completionHandler(OrdersStoreError.cannotDelete("Cannot fetch order with id \(id) to delete"))
      }
    }
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(_ completionHandler: @escaping OrdersStoreFetchOrdersCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        let orders = results.map { $0.toOrder() }
        completionHandler(OrdersStoreResult.success(result: orders))
      } catch {
        completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotFetch("Cannot fetch orders")))
      }
    }
  }
  
  func fetchOrder(_ id: String, completionHandler: @escaping OrdersStoreFetchOrderCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let order = results.first?.toOrder() {
          completionHandler(OrdersStoreResult.success(result: order))
        } else {
          completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotFetch("Cannot fetch order with id \(id)")))
        }
      } catch {
        completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotFetch("Cannot fetch order with id \(id)")))
      }
    }
  }
  
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping OrdersStoreCreateOrderCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let managedOrder = NSEntityDescription.insertNewObject(forEntityName: "ManagedOrder", into: self.privateManagedObjectContext) as! ManagedOrder
        managedOrder.id = orderToCreate.id
        managedOrder.date = orderToCreate.date
        managedOrder.email = orderToCreate.email
        managedOrder.firstName = orderToCreate.firstName
        managedOrder.lastName = orderToCreate.lastName
        managedOrder.total = orderToCreate.total
        try self.privateManagedObjectContext.save()
        completionHandler(OrdersStoreResult.success(result: ()))
      } catch {
        let error = OrdersStoreError.cannotCreate("Cannot create order with id \(orderToCreate.id)")
        completionHandler(OrdersStoreResult.failure(error: error))
      }
    }
  }
  
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping OrdersStoreUpdateOrderCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          do {
            managedOrder.id = orderToUpdate.id
            managedOrder.date = orderToUpdate.date
            managedOrder.email = orderToUpdate.email
            managedOrder.firstName = orderToUpdate.firstName
            managedOrder.lastName = orderToUpdate.lastName
            managedOrder.total = orderToUpdate.total
            try self.privateManagedObjectContext.save()
            completionHandler(OrdersStoreResult.success(result: ()))
          } catch {
            completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotUpdate("Cannot update order with id \(orderToUpdate.id)")))
          }
        }
      } catch {
        completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update")))
      }
    }
  }
  
  func deleteOrder(_ id: String, completionHandler: @escaping OrdersStoreDeleteOrderCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          self.privateManagedObjectContext.delete(managedOrder)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler(OrdersStoreResult.success(result: ()))
          } catch {
            completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotDelete("Cannot delete order with id \(id)")))
          }
        } else {
          completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotDelete("Cannot fetch order with id \(id) to delete")))
        }
      } catch {
        completionHandler(OrdersStoreResult.failure(error: OrdersStoreError.cannotDelete("Cannot fetch order with id \(id) to delete")))
      }
    }
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(_ completionHandler: @escaping (_ orders: () throws -> [Order]) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        let orders = results.map { $0.toOrder() }
        completionHandler { return orders }
      } catch {
        completionHandler { throw OrdersStoreError.cannotFetch("Cannot fetch orders") }
      }
    }
  }
  
  func fetchOrder(_ id: String, completionHandler: @escaping (_ order: () throws -> Order?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let order = results.first?.toOrder() {
          completionHandler { return order }
        } else {
          throw OrdersStoreError.cannotFetch("Cannot fetch order with id \(id)")
        }
      } catch {
        completionHandler { throw OrdersStoreError.cannotFetch("Cannot fetch order with id \(id)") }
      }
    }
  }
  
  func createOrder(_ orderToCreate: Order, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let managedOrder = NSEntityDescription.insertNewObject(forEntityName: "ManagedOrder", into: self.privateManagedObjectContext) as! ManagedOrder
        managedOrder.id = orderToCreate.id
        managedOrder.date = orderToCreate.date
        managedOrder.email = orderToCreate.email
        managedOrder.firstName = orderToCreate.firstName
        managedOrder.lastName = orderToCreate.lastName
        managedOrder.total = orderToCreate.total
        try self.privateManagedObjectContext.save()
        completionHandler { return }
      } catch {
        completionHandler { throw OrdersStoreError.cannotCreate("Cannot create order with id \(orderToCreate.id)") }
      }
    }
  }
  
  func updateOrder(_ orderToUpdate: Order, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
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
            completionHandler { throw OrdersStoreError.cannotUpdate("Cannot update order with id \(orderToUpdate.id)") }
          }
        }
      } catch {
        completionHandler { throw OrdersStoreError.cannotUpdate("Cannot fetch order with id \(orderToUpdate.id) to update") }
      }
    }
  }
  
  func deleteOrder(_ id: String, completionHandler: @escaping (_ done: () throws -> Void) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          self.privateManagedObjectContext.delete(managedOrder)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler { return }
          } catch {
            completionHandler { throw OrdersStoreError.cannotDelete("Cannot delete order with id \(id)") }
          }
        } else {
          throw OrdersStoreError.cannotDelete("Cannot fetch order with id \(id) to delete")
        }
      } catch {
        completionHandler { throw OrdersStoreError.cannotDelete("Cannot fetch order with id \(id) to delete") }
      }
    }
  }
}
