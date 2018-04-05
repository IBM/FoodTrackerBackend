# Retrieving and Deleting Meals from the FoodServer
The current implementation of the [Kitura FoodServer](README.md) has support for retrieving all of the stored Meals using a `GET` request on `/meals`, but the FoodTracker app is currently only saving the Meals to the FoodServer.

### Pre-Requisites:
This tutorial follows on from the FoodTracker Application and server created by following the [FoodTrackerBackend](https://github.com/IBM/FoodTrackerBackend) tutorial. If you have completed the FoodTracker Backend there are no further pre-requisites.

If you have not completed the [FoodTrackerBackend](https://github.com/IBM/FoodTrackerBackend) tutorial go to the [CompletedFoodTracker](https://github.com/IBM/FoodTrackerBackend/tree/CompletedFoodTracker) branch and follow the README instructions.

### Retrieving Meals from the FoodServer  
1. Open the FoodTracker workspace
 `open ~/FoodTrackerBackend/iOS/FoodTracker/FoodTracker.xcworkspace/`
2. Inside MealTableViewController.swift add the following function:
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
The above code will query the saved Meals from the server, and update the TableView.

3. Call this new function by replacing the `loadMeals` function with:
```swift
private func loadMeals() -> [Meal]?  {
        loadFromServer()
        return meals
    }
```
4. Inside your `saveMeals` function, replace:
```swift
do {
    let data = try PropertyListEncoder().encode(meals)
    let isSuccessfulSave  = NSKeyedArchiver.archiveRootObject(data, toFile: MealTableViewController.ArchiveURL.path)
    if isSuccessfulSave {
        os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
    } else {
        os_log("Failed to save meals...", log: OSLog.default, type: .error)
    }
} catch {
    os_log("Failed to save meals...", log: OSLog.default, type: .error)
}
```  
with:
```swift
loadFromServer()
```

This change makes the food tracker app to load it's meals from the server's database, instead of a local cache. You can test this by closing then deleting the app in the simulator and restarting the food tracker. All your meals from the Server will persist since they have been loaded from the database.
### Deleting Meals from the FoodServer  
Support for deleting Meals from the FoodServer can be added by adding a REST API that responds to a DELETE request, with an additional identifier that provides information about which meal to delete.
1. Open the FoodServer project
`open  ~/FoodTrackerBackend/FoodServer/FoodServer.xcodeproj/`
2. Add the following code as a DELETE handler for a single Meal:
```swift
router.delete("/meal", handler: deleteHandler)
```  
With the following deleteHandler implementation:  
```swift
func deleteHandler(id: String, completion: @escaping (RequestError?) -> Void ) {
    Meal.delete(id: id, completion)
}
```
Note that rather than receiving a Meal, this receives an `id`. The `id` is an `Identifier` that is added to the URL in order to denote which Meal to delete. Kitura extends String to conform to Identifier, so strings can be used directly. Here, we will be using the meal name as the `Identifier`.

3. The following function is added to MealTableViewController.swift to make the DELETE call to the FoodServer.
```swift
    private func deleteFromServer(meal: Meal) {
        guard let client = KituraKit(baseURL: "http://localhost:8080") else {
            print("Error creating KituraKit client")
            return
        }
        client.delete("/meal", identifier: meal.name) { (error: Error?) in
            guard error == nil else {
                print("Error deleting meal from Kitura: \(error!)")
                return
            }
            print("Deleting meal from Kitura succeeded")
        }
    }
```
4. Call this new function inside `func tableView` by replacing:
```swift
meals.remove(at: indexPath.row)
```
with:
```swift
deleteFromServer(meal: meals[indexPath.row])
```

### Congratulations, Your iOS app will now load and delete meals from the server!!!
