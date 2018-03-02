# Building a FoodTracker Backend with Kitura

<p align="center">
<img src="https://www.ibm.com/cloud-computing/bluemix/sites/default/files/assets/page/catalog-swift.svg" width="120" alt="Kitura Bird">
</p>

<p align="center">
<a href= "http://swift-at-ibm-slack.mybluemix.net/">
    <img src="http://swift-at-ibm-slack.mybluemix.net/badge.svg"  alt="Slack">
</a>
</p>

This tutorial teaches how to create a [Kitura Swift backend](http://kitura.io) for the [FoodTracker iOS app tutorial](https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/) from Apple. This project contains a version of the tutorial code that has been updated to use [Codable](https://developer.apple.com/documentation/swift/codable) rather than [NSCoder](https://developer.apple.com/documentation/foundation/nscoder).

Upon completion of this tutorial there are several [next steps](#next-steps) you can take to add further functionality to the application:

- [Add a Website Frontend using the Stencil Template Engine](StencilFrontend.md)
- [Add Support for Retrieving and Deleting Meals from the FoodServer](RetrievingAndDeleting.md)
- [Add a Web Application to the Kitura server](AddWebApplication.md)
- [Deploy and host the Kitura FoodServer in the Cloud](DeployToCloud.md)
- [View a sample Todo list application using Kitura](https://github.com/IBM-Swift/iOSSampleKituraKit)

If you would like to jump straight to one of these next steps a completed version of this tutorial with instruction on starting the server and application is available on the [CompletedFoodTracker branch](https://github.com/IBM/FoodTrackerBackend/tree/CompletedFoodTracker).

## Pre-Requisites:
**Note:** This workshop has been developed for Swift 4, Xcode 9.x and Kitura 2.x.

1. Install the [Kitura CLI](https://github.com/ibm-swift/kitura-cli):  
   1. Configure the Kitura homebrew tap  
   `brew tap ibm-swift/kitura`  
   2. Install the Kitura CLI from homebrew  
   `brew install kitura`

2. Ensure you have CocoaPods installed  
   1. Install CocoaPods:
   `sudo gem install cocoapods`

3. Clone this project from GitHub to your machine (don't use the Download ZIP option):
   ```
   cd ~
   git clone http://github.com/IBM/FoodTrackerBackend
   cd ~/FoodTrackerBackend
   ```

## Getting Started
### 1. Run the Food Tracker App:
The Food Tracker application is taken from the Apple tutorial for building your first iOS application. It allows you to store names, photos and ratings for  "meals". The meals are then stored onto the device using `NSKeyedArchiver`. The following shows you how to see the application running.

1. Change into the iOS app directory:  
```
cd ~/FoodTrackerBackend/iOS/FoodTracker
```  

2. Open the Xcode Project  
```
open FoodTracker.xcodeproj
```  

3. Run the project to ensure that it's working  
    1. Press the Run button or use the ⌘+R key shortcut.  
    2. Add a meal in the Simulator by clicking the '+' button, providing a name, selecting a photo and a rating and clicking "Save".
    3. Check that you receive a “Meals successfully saved.” message in the console

## Building a Kitura Backend
The Food Tracker application stores the meal data to the local device, which means it's not possible to share the data with other users, or to build an additional web interface for the application. The following steps show you how to create a Kitura Backend to allow you to store and share the data.

### 1. Initialize a Kitura Server Project
1. Create a directory for the server project
```
mkdir ~/FoodTrackerBackend/FoodServer
cd ~/FoodTrackerBackend/FoodServer
```  

2. Create a Kitura starter project  
```
kitura init
```  
The Kitura CLI will now create and build an starter Kitura application for you. This includes adding best-practice implementations of capabilities such as configuration, health checking and monitoring to the application for you.

More information about the [project structure](http://kitura.io/en/starter/generator/project_layout_reference.html) is available on kitura.io.

### 2. Create an in-memory data store for Meals
The `init` command has created a fully running Kitura application, but one which has no application logic. In order to use it to store the data from the FoodTracker application, you need to create a datastore in the Kitura application for the Meal data from the FoodTracker iOS application. This tutorial uses a simple in-memory dictionary to store exactly the same Meal types that are used in the FoodTracker application.

1. Copy the Meal.swift file from the FoodTracker app to the Server
   ```
   cd ~/FoodTrackerBackend
   cp ./iOS/FoodTracker/FoodTracker/Meal.swift ./FoodServer/Sources/Application
   ```
2. Open the FoodServer project in Xcode  
   ```
   cd ~/FoodTrackerBackend/FoodServer  
   open FoodServer.xcodeproj
   ```
3. Add the Meal.swift file into the FoodServer project  
   1. Select the yellow Sources > Application folder in the left hand explorer menu  
   2. Click right mouse and select Add Files to "FoodServer"...
   3. Find the Meal.swift file found in FoodTrackerBackend > FoodServer > Sources > Application
   4. Single right click it, then select the Options button. Scroll down about halfway through the "Add to targets" and tick "Application". Untick any other options in "add to targets" and click "Add".
4. Add a dictionary to the Application.swift file to store the Meal types  
   1. Open the Sources > Application > Application.swift file
   2. Add a "mealstore" inside the app class,  by inserting the following code:
      ```
      private var mealStore: [String: Meal] = [:]
      ```
      On the line below `let cloudEnv = CloudEnv()`

This now provides a simple dictionary to store Meal data passed to the FoodServer from the FoodTracker app.

### 3. Create a REST API to allow FoodTracker to store Meals
REST APIs typically consist of a HTTP request using a verb such as POST, PUT, GET or DELETE along with a URL and an optional data payload. The server then handles the request and responds with an optional data payload.

A request to store data typically consists of a POST request with the data to be stored, which the server then handles and responds with a copy of the data that has just been stored.

1. Register a handler for a `POST` request on `/meals` that stores the data  
Add the following into the `postInit()` function in the App class:
```swift
router.post("/meals", handler: storeHandler)
```
2. Implement the storeHandler that receives a Meal, and returns the stored Meal  
Add the following code as a function in the App class, beneath the postInit() function:  
```swift
    func storeHandler(meal: Meal, completion: (Meal?, RequestError?) -> Void ) {
        mealStore[meal.name] = meal
        completion(mealStore[meal.name], nil)
    }
```    

As well as being able to store Meals on the FoodServer, the FoodTracker app will also need to be able to access the stored meals. A request to load all of the stored data typically consists of a GET request with no data, which the server then handles and responds with an array of the data that has just been stored.

3. Register a handler for a `GET` request on `/meals` that loads the data  
Add the following into the `postInit()` function:  
```swift
	router.get("/meals", handler: loadHandler)
```
4. Implement the loadHandler that returns the stored Meals as an array.      
Add the following as another function in the App class:
```swift
    func loadHandler(completion: ([Meal]?, RequestError?) -> Void ) {
	    let meals: [Meal] = self.mealStore.map({ $0.value })
       completion(meals, nil)
    }
```

### 4. Test the newly created REST API


1. Run the server project in Xcode
    1. Edit the scheme by clicking on the "FoodServer-Package" section on the top-left the toolbar and selecting "Edit scheme"
    2. In "Run" click on the "Executable" dropdown, select FoodServer and click Close
    3. Press the Run button or use the ⌘+R key shortcut.
    4. Select "Allow incoming network connections" if you are prompted.

2. Check that some of the standard Kitura URLs are running:
    * Kitura Monitoring: http://localhost:8080/swiftmetrics-dash/
    * Kitura Health check: http://localhost:8080/health

3. Test the GET REST API is running correctly  
There are many utilities for testing REST APIs, such as [Postman](https://www.getpostman.com). Here we'll use "curl", which is a simple command line utility:
```
curl -X GET \
  http://localhost:8080/meals \
  -H 'content-type: application/json'
```
If the GET endpoint is working correctly, this should return an array of JSON data representing the stored Meals. As no data is yet stored, this should return an empty array, ie:  
```
[]
```
4.  Test the POST REST API is running correctly  
In order to test the POST API, we make a similar call, but also sending in a JSON object that matches the Meal data:  
```
curl -X POST \
  http://localhost:8080/meals \
  -H 'content-type: application/json' \
  -d '{
    "name": "test",
    "photo": "0e430e3a",
    "rating": 1
}'
```
If the POST endpoint is working correctly, this should return the same JSON that was passed in, eg:  
```
{"name":"test","photo":"0e430e3a","rating":1}
```

5. Test the GET REST API is returning the stored data correctly  
In order to check that the data is being stored correctly, re-run the GET check:  
```
curl -X GET \
  http://localhost:8080/meals \
  -H 'content-type: application/json'
```
This should now return a single entry array containing the Meal that was stored by the POST request, eg:  
```
[{"name":"test","photo":"0e430e3a","rating":1}]
```

## Connect FoodTracker to the Kitura FoodServer

Any package that can make REST calls from an iOS app is sufficient to make the connection to the Kitura FoodServer to store and retrieve the Meals. Kitura itself provides a client connector called [KituraKit](https://github.com/ibm-swift/kiturakit) which makes it easy to connect to Kitura using shared data types, in our case Meals, using an API that is almost identical on the client and the server. In this example we'll use KituraKit to make the connection.

### Install KituraKit into the FoodTracker app
KituraKit is designed to be used both in iOS apps and in server projects. Currently the easiest way to install KituraKit into an iOS app it to download a bundling containing KituraKit and its dependencies, and to install it into the app as a CocoaPod.

1. If the "FoodTracker" Xcode project it is open, close it.
Installing the KituraKit bundle as a CocoaPod will edit the project and create a workspace, so it is best if the project is closed.
2. Create a Podfile in the FoodTracker iOS application directory:
```
cd ~/FoodTrackerBackend/iOS/FoodTracker/
pod init
```
3. Edit the Podfile to use KituraKit:
   1. Open the Podfile for editing
   ```
   open Podfile
   ```
   2. Set a global platform of iOS 11 for your project  
   Uncomment `# platform :ios, '9.0'` and set the value to `11.0`
   3. Under the "# Pods for FoodTracker" line add:
   ```
   # Pods for FoodTracker
   pod 'KituraKit', :git => 'https://github.com/IBM-Swift/KituraKit.git', :branch => 'pod'
   ```
   4. Save and close the file
4. Install KituraKit:
```
pod install
```
5. Open the Xcode workspace (not project!)
```
cd ~/FoodTrackerBackend/iOS/FoodTracker/
open FoodTracker.xcworkspace
```

KituraKit should now be installed, and you should be able to build and run the FoodTracker project as before. Note that from now on you should open the Xcode workspace ('FoodTracker.xcworkspace') not project.

### Update FoodTracker to call the Kitura FoodServer
Now that KituraKit is installed into the FoodTracker application, it needs to be updated to use it to call the Kitura FoodServer. The code to do that is already provided. As a result, you only need to uncomment the code that invokes those APIs. The code to uncomment is marked with `UNCOMMENT`.  

1. Edit the `FoodTracker > MealTableViewController.swift` file:
    1. Uncomment the import of KituraKit at the top of the file.
    ```swift
    import KituraKit
    ```
    2. Uncomment the following at the start of the saveMeals() function:
    ```swift
            for meal in meals {
                  saveToServer(meal: meal)
            }
    ```
    3. Uncomment the following `saveToServer(meal:)` function towards the end of the file:
    ```swift
    private func saveToServer(meal: Meal) {
        guard let client = KituraKit(baseURL: "http://localhost:8080") else {
            print("Error creating KituraKit client")
            return
        }
        client.post("/meals", data: meal) { (meal: Meal?, error: Error?) in
            guard error == nil else {
                print("Error saving meal to Kitura: \(error!)")
                return
            }
            print("Saving meal to Kitura succeeded")
        }
    }
    ```

### Update the FoodTracker app to allow interaction with a Server
The final step is to update the FoodTracker application to allow loads from a server.

1. Update the `FoodTracker > Info.plist` file to allow loads from a server:  
**Note:** This step has been completed already:  
```
    <key>NSAppTransportSecurity</key>
	<dict>
	    <key>NSAllowsArbitraryLoads</key>
	<true/>
	</dict>
```

## Run the FoodTracker app, storing data to the Kitura server  
1. Make sure the Kitura server is still running and you have the Kitura monitoring dashboard open in your browser (http://localhost:8080/swiftmetrics-dash)
2. Build and run the FoodTracker app in the iOS simulator and add or remove a Meal entry
   You should see the following messages in the Xcode console:
   ```
   Saving meal to Kitura succeeded
   Saving meal to Kitura succeeded
   ```
3. View the monitoring panel to see the responsiveness of the API call
4. Check the data has been persisted by the Kitura server
```
curl -X GET \
  http://localhost:8080/meals \
  -H 'content-type: application/json'
```
This should now return an array containing the Meals that was stored by the POST request. As this contains the full images stored in the Meal objects, this will involve several screens of data!

### Congratulations, you have successfully build a Kitura Backend for an iOS app!

## Connecting A PostgreSQL Database
### Creating a PostgreSQL Database
 We created a server and connected it to the iOS application. This means created meals are posted to the server and a user can then view these meals on [localhost:8080/meals](http://localhost:8080/meals). Since the meals are stored on the server, if the server is restarted the meal data is lost. To solve this problem, we will start by creating a PostgreSQL database where the meals will be stored.

1. Install PostgreSQL:
```
brew install postgresql
brew services start postgresql
```
You should receive a message that either PostgreSQL has been started or the service is already running. This installation should have installed two applications we need, namely `createdb` and `psql`, which will be used as clients to your locally running PostgreSQL.

2. Create a database called FoodDatabase to store the data:
```
createdb FoodDatabase
```

### Adding Swift-Kuery-ORM dependencies to your server
[Swift-Kuery-ORM](https://github.com/IBM-Swift/Swift-Kuery-ORM) is an ORM that works alongside a specific database library, such as [Swift-Kuery-PostgreSQL](https://github.com/IBM-Swift/Swift-Kuery-PostgreSQL), to allow a user to easily interact with database in Swift. These two libraries are added to our `Package.swift` file, so the server can access them.

1. If the "FoodServer" Xcode project is open, close it. Installing Swift-Kuery-ORM and Swift-Kuery-PostgreSQL will modify the Xcode project.

2. Open a new terminal window and go to your `Package.swift` file.
```
cd FoodTrackerBackend/FoodServer
open Package.swift
```
3. Add the Swift-Kuery-ORM and Swift-Kuery-PostgreSQL packages.
```swift
.package(url: "https://github.com/IBM-Swift/Swift-Kuery-ORM.git", .upToNextMinor(from: "0.0.1")),
.package(url: "https://github.com/IBM-Swift/Swift-Kuery-PostgreSQL.git", .upToNextMinor(from: "1.1.0")),
```
below the line `.package(url:
  "https://github.com/IBM-Swift/Health.git", from: "0.0.0"),`

4. Change the target for Application to include SwiftKueryORM and SwiftKueryPostgreSQL after Health
```swift
.target(name: "Application", dependencies: [ "Kitura", "Configuration", "CloudEnvironment","SwiftMetrics","Health", "SwiftKueryORM", "SwiftKueryPostgreSQL"]),
```

### Generate your FoodServer Xcode project
Now we have added the dependencies to our `Package.swift` file we can generate our FoodServer Xcode project to make editing the code easier. The FoodServer is a pure Swift project and so the following steps could also be achieved by editing the .swift files.

1. Generate the server Xcode project:
```
swift package generate-xcodeproj
open FoodServer.xcodeproj/
```
2. Click on the "FoodServer-Package" text on the top-left of the toolbar and select "Edit scheme" from the dropdown menu.
3. In "Run" click on the "Executable" dropdown, select FoodServer and click Close.

Now when you press play, Xcode will start your FoodTracker server listening on port 8080. You can see this by going to [http://localhost:8080/](http://localhost:8080/ ) which will show the default Kitura landing page.

### Making Meal a Model
To work with the ORM, the struct Meal needs to implement the Model.

1. Open your `Sources > Application > Application.swift` file
2. Add two libraries to the import statements:
```swift
import SwiftKueryORM
import SwiftKueryPostgreSQL
```
3. Below the line that reads `public let health = Health()`, extend `Meal` to conform to `Model` like so: 
```swift
extension Meal: Model { }
```

### Deleting the server mealStore
Since we will be storing the meal data in a database, we no longer need a local meal store on the server.

1. Open your `Sources > Application > Application.swift` file

2. Delete the mealStore initialiser:
```swift
private var mealStore: [String: Meal] = [:]
```

3. Delete the mealStore references in `storeHandler`:
```swift
mealStore[meal.name] = meal
completion(mealStore[meal.name], nil)
```

4. Delete the mealStore references in `loadHandler`:
```swift
let meals: [Meal] = self.mealStore.map({ $0.value })
completion(meals, nil)
```

### Connecting to the PostgreSQL database
We will now connect to our server to the PostgreSQL database. This will allow us to send and receive information from the database.

1. In the same `Application.swift` file, go underneath your extension of `Meal` and add a new class:

```swift
class Persistence {

}
```
2. Inside this class, create a static function that will set up a connection pool and assign it to a default database:

```swift
static func setUp() {
    let pool = PostgreSQLConnection.createPool(host: "localhost", port: 5432, options: [.databaseName("FoodDatabase")], poolOptions: ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 50, timeout: 10000))
    Database.default = Database(pool)
}
```
**Note** We use a connection pool since we have concurrent requests.

3. Go to the `postInit` function below the line `router.get("/meals", handler: loadHandler)` and call your setup function, and create a table sync for your `Meal` object:

```swift
Persistence.setUp()
do {
    try Meal.createTableSync()
} catch let error {
    print(error)
}
```

Before we start using the PostgreSQL Database, we need to create a table in the database. Add the following:

2. Add the `@escaping` keyword to the completion closure in the `storeHandler`  signatures.
```swift
func storeHandler(meal: Meal, completion: @escaping (Meal?, RequestError?) -> Void ) {
```

3. Add the `@escaping` keyword to the completion closure in the `loadHandler`  signatures.
```swift
func loadHandler(completion: @escaping ([Meal]?, RequestError?) -> Void ) {
```

Allowing the completion closure to be escaping means the database queries can be asynchronous.

## Using the PostgreSQL Database
### Handling an HTTP POST request
We are now going to save a meal in our `storeHandler`. This will mean that when our server receives an HTTP `POST` request, it will take the Meal instance received and save it to the database.

1.  Inside the `storeHandler` function add the following line:
```swift
meal.save(completion)
```
2. Your completed `storeHandler` function should now look as follows:
```swift
func storeHandler(meal: Meal, completion: @escaping (Meal?, RequestError?) -> Void ) {
      meal.save(completion)
}
```
You can verify this by:

Starting the FoodTracker application in Xcode.
Creating a meal in the application.
Go to your terminal.
Accessing your database: psql FoodDatabase
Viewing your meals table: SELECT name, rating FROM meals;
This should produce a table with the name and the rating of your newly added meal.
**NOTE** We do not print out the photo because it is too large


Now when you create a meal in the application, the server will save it to the PostgreSQL database.

### Handling an HTTP GET request
We are going to get our meals in our `loadHandler` function. This will mean that when the server receives an HTTP `GET` request, it will get the meals from the database. This means the data the server returns to the client is taken from the database and will persist, even if the server is restarted.

1.  Inside the `loadHander` function add the following line:
```swift
Meal.findAll(completion)
```

2. Your completed `loadHandler` function should now look as follows:
```swift
func loadHandler(completion: @escaping ([Meal]?, RequestError?) -> Void ) {
      Meal.findAll(completion)
}
```

Now when you perform a `GET` call to your server it will retrieve the meals from your database.
You can verify this by going to [http://localhost:8080/meals](http://localhost:8080/meals), where you should see your meals.
You can now restart your server and this data will persist, since it is stored within the database!

### Congratulations, you have successfully built a Kitura backend and stored the data in a PostgreSQL database!

## Next Steps
If you have sufficient time, the following tasks can be completed to update your application.

### Add a Website Frontend using the Stencil Template Engine
The current implementation of the Kitura FoodServer returns a JSON array of the meals. To create a website, you would want to use html to structure the page. The following contains steps to embed the meal data into html and [add a Website Frontend using the Stencil Template Engine](StencilFrontend.md)

### Add Support for Retrieving and Deleting Meals from the FoodServer
The current implementation of the Kitura FoodServer has support for retrieving all of the stored Meals using a `GET` request on `/meals`, but the FoodTracker app is currently only saving the Meals to the FoodServer. The following contains the steps to add [Retrieving and Deleting Meals from the FoodServer](RetrievingAndDeleting.md).

### Add a Web Application to the Kitura server
Now that the Meals from the FoodTracker app are being stored on a server, it becomes possible to start building a web application that also provides users with access to the stored Meal data.
The following steps describe how to start to [Build a FoodTracker Web Application](AddWebApplication.md).

### Deploy and host the Kitura FoodServer in the Cloud
In order for a real iOS app to connect to a Kitura Server, it needs to be hosted at a public URL that the iOS app can reach.

Kitura is deployable to any cloud, but the project created with `kitura init` provides additonal files so that it is pre-configured for clouds that support any of Cloud Foundry, Docker or Kubernetes. The follow contains the steps to take the Kitura FoodServer and [Deploy to the IBM Cloud using Cloud Foundry](DeployToCloud.md).

### View a sample Todo list application using Kitura
This tutorial takes you through the basics of creating a Kitura server. To see a completed Todo list application with demonstrations of all HTTP requests go to [iOSSampleKituraKit](https://github.com/IBM-Swift/iOSSampleKituraKit)
