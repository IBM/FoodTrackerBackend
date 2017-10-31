# Retrieving and Deleting Meals from the FoodServer
The current implementation of the [Kitura FoodServer](README.md) has support for retrieving all of the stored Meals using a `GET` request on `/meals`, but the FoodTracker app is currently only saving the Meals to the FoodServer.

### Retrieving Meals from the FoodServer  
The following code can be added to the FoodTracker app and will query the saved Meals from the server, and update the TableView:  
```swift
    private func loadFromServer() {
        guard let client = KituraKit(baseURL: "http://localhost:8080") else {
            print("Error creating KituraKit client")
            return
        }
        client.get("/meals") { (meals: [Meal]?, error: Error?) in
            guard error == nil else {
                print("Error saving meal to Kitura: \(error!)")
                return
            }
            guard let meals = meals else {
                self.meals = [Meal]()
                return
            }
            self.meals = meals
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }
    }
```  
Try inserting this into the FoodTracker app and loading the Meals from the FoodServer.

### Deleting Meals from the FoodServer  
The design of the FoodTracker app is such that it saves all of the Meals when any Meal is added or removed, overwriting the previous store of Meals. Whilst this provides an implememtation, it is not one that scales to large numbers of Meals.

Support for deleting Meals from the FoodServer can be added by adding a REST API that responds to a DELETE request, with an additional identifier that provides information about which meal to delete.

1. The following code adds a DELETE handler to the FoodServer for a single Meal:  
```swift
    router.delete("/meal", codableHandler: deleteHandler)
```  
With the following handler implementation:  
```swift
    func deleteHandler(id: String, completion: (RequestError?) -> Void ) -> Void {
        print("Deleting \(id) from mealStore")
        mealStore[id] = nil
        completion(nil)
    }
```
Note that rather than receiving a Meal, this receives an `id`. The `id` is an `Identifier` that is added to the URL in order to denote which Meal to delete. Kitura extends String to conform to Identifier, so strings can be used directly.  

2. The following code can be used in the FoodTracker app to make the call to the FoodServer. Here the Meal name is used for the Identifier.  
```swift
    private func deleteFromServer(meal: Meal) {
        guard let client = KituraKit(baseURL: "http://localhost:8080") else {
            print("Error creating KituraKit client")
            return
        }
        let client = KituraKit(baseURL: "http://localhost:8080")
        client.delete("/meal", identifier: meal.name) { (error: Error?) in
            guard error == nil else {
                print("Error deleting meal from Kitura: \(error!)")
                return
            }
            print("Deleting meal from Kitura succeeded")
        }
    }
```
