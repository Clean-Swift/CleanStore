import CoreData

class OrdersCoreDataStore: OrdersStoreProtocol, OrdersStoreUtilityProtocol
{
  // MARK: - Managed object contexts
  
  var mainManagedObjectContext: NSManagedObjectContext
  var privateManagedObjectContext: NSManagedObjectContext
  
  // MARK: - Object lifecycle
  
  init()
  {
    // This resource is the same name as your xcdatamodeld contained in your project.
    guard let modelURL = Bundle.main.url(forResource: "CleanStore", withExtension: "momd") else {
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
  
  func fetchOrders(completionHandler: @escaping ([Order], OrdersStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        let orders = results.map { $0.toOrder() }
        completionHandler(orders, nil)
      } catch {
        completionHandler([], OrdersStoreError.CannotFetch("Cannot fetch orders"))
      }
    }
  }
  
  func fetchOrder(id: String, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let order = results.first?.toOrder() {
          completionHandler(order, nil)
        } else {
          completionHandler(nil, OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)"))
        }
      } catch {
        completionHandler(nil, OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)"))
      }
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let managedOrder = NSEntityDescription.insertNewObject(forEntityName: "ManagedOrder", into: self.privateManagedObjectContext) as! ManagedOrder
        var order = orderToCreate
        self.generateOrderID(order: &order)
        self.calculateOrderTotal(order: &order)
        managedOrder.fromOrder(order: order)
        try self.privateManagedObjectContext.save()
        completionHandler(order, nil)
      } catch {
        completionHandler(nil, OrdersStoreError.CannotCreate("Cannot create order with id \(String(describing: orderToCreate.id))"))
      }
    }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          do {
            managedOrder.fromOrder(order: orderToUpdate)
            let order = managedOrder.toOrder()
            try self.privateManagedObjectContext.save()
            completionHandler(order, nil)
          } catch {
            completionHandler(nil, OrdersStoreError.CannotUpdate("Cannot update order with id \(String(describing: orderToUpdate.id))"))
          }
        }
      } catch {
        completionHandler(nil, OrdersStoreError.CannotUpdate("Cannot fetch order with id \(String(describing: orderToUpdate.id)) to update"))
      }
    }
  }
  
  func deleteOrder(id: String, completionHandler: @escaping (Order?, OrdersStoreError?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          let order = managedOrder.toOrder()
          self.privateManagedObjectContext.delete(managedOrder)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler(order, nil)
          } catch {
            completionHandler(nil, OrdersStoreError.CannotDelete("Cannot delete order with id \(id)"))
          }
        } else {
          throw OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete")
        }
      } catch {
        completionHandler(nil, OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete"))
      }
    }
  }
  
  // MARK: - CRUD operations - Generic enum result type
  
  func fetchOrders(completionHandler: @escaping OrdersStoreFetchOrdersCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        let orders = results.map { $0.toOrder() }
        completionHandler(OrdersStoreResult.Success(result: orders))
      } catch {
        completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotFetch("Cannot fetch orders")))
      }
    }
  }
  
  func fetchOrder(id: String, completionHandler: @escaping OrdersStoreFetchOrderCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let order = results.first?.toOrder() {
          completionHandler(OrdersStoreResult.Success(result: order))
        } else {
          completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)")))
        }
      } catch {
        completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotFetch("Cannot fetch order with id \(id)")))
      }
    }
  }
  
  func createOrder(orderToCreate: Order, completionHandler: @escaping OrdersStoreCreateOrderCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let managedOrder = NSEntityDescription.insertNewObject(forEntityName: "ManagedOrder", into: self.privateManagedObjectContext) as! ManagedOrder
        var order = orderToCreate
        self.generateOrderID(order: &order)
        self.calculateOrderTotal(order: &order)
        managedOrder.fromOrder(order: order)
        try self.privateManagedObjectContext.save()
        completionHandler(OrdersStoreResult.Success(result: order))
      } catch {
        let error = OrdersStoreError.CannotCreate("Cannot create order with id \(String(describing: orderToCreate.id))")
        completionHandler(OrdersStoreResult.Failure(error: error))
      }
    }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping OrdersStoreUpdateOrderCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          do {
            managedOrder.fromOrder(order: orderToUpdate)
            let order = managedOrder.toOrder()
            try self.privateManagedObjectContext.save()
            completionHandler(OrdersStoreResult.Success(result: order))
          } catch {
            completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotUpdate("Cannot update order with id \(String(describing: orderToUpdate.id))")))
          }
        }
      } catch {
        completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotUpdate("Cannot fetch order with id \(String(describing: orderToUpdate.id)) to update")))
      }
    }
  }
  
  func deleteOrder(id: String, completionHandler: @escaping OrdersStoreDeleteOrderCompletionHandler)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          let order = managedOrder.toOrder()
          self.privateManagedObjectContext.delete(managedOrder)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler(OrdersStoreResult.Success(result: order))
          } catch {
            completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotDelete("Cannot delete order with id \(id)")))
          }
        } else {
          completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete")))
        }
      } catch {
        completionHandler(OrdersStoreResult.Failure(error: OrdersStoreError.CannotDelete("Cannot fetch order with id \(id) to delete")))
      }
    }
  }
  
  // MARK: - CRUD operations - Inner closure
  
  func fetchOrders(completionHandler: @escaping (() throws -> [Order]) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        let orders = results.map { $0.toOrder() }
        completionHandler { return orders }
      } catch {
        completionHandler { throw OrdersStoreError.CannotFetch("Cannot fetch orders") }
      }
    }
  }
  
  func fetchOrder(id: String, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
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
  
  func createOrder(orderToCreate: Order, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let managedOrder = NSEntityDescription.insertNewObject(forEntityName: "ManagedOrder", into: self.privateManagedObjectContext) as! ManagedOrder
        var order = orderToCreate
        self.generateOrderID(order: &order)
        self.calculateOrderTotal(order: &order)
        managedOrder.fromOrder(order: order)
        try self.privateManagedObjectContext.save()
        completionHandler { return order }
      } catch {
        completionHandler { throw OrdersStoreError.CannotCreate("Cannot create order with id \(String(describing: orderToCreate.id))") }
      }
    }
  }
  
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderToUpdate.id!)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          do {
            managedOrder.fromOrder(order: orderToUpdate)
            let order = managedOrder.toOrder()
            try self.privateManagedObjectContext.save()
            completionHandler { return order }
          } catch {
            completionHandler { throw OrdersStoreError.CannotUpdate("Cannot update order with id \(String(describing: orderToUpdate.id))") }
          }
        }
      } catch {
        completionHandler { throw OrdersStoreError.CannotUpdate("Cannot fetch order with id \(String(describing: orderToUpdate.id)) to update") }
      }
    }
  }
  
  func deleteOrder(id: String, completionHandler: @escaping (() throws -> Order?) -> Void)
  {
    privateManagedObjectContext.perform {
      do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedOrder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try self.privateManagedObjectContext.fetch(fetchRequest) as! [ManagedOrder]
        if let managedOrder = results.first {
          let order = managedOrder.toOrder()
          self.privateManagedObjectContext.delete(managedOrder)
          do {
            try self.privateManagedObjectContext.save()
            completionHandler { return order }
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
