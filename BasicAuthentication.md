# Adding Basic authentication to Kitura FoodServer

<p align="center">
<img src="https://www.ibm.com/cloud-computing/bluemix/sites/default/files/assets/page/catalog-swift.svg" width="120" alt="Kitura Bird">
</p>

<p align="center">
<a href= "http://swift-at-ibm-slack.mybluemix.net/">
<img src="http://swift-at-ibm-slack.mybluemix.net/badge.svg"  alt="Slack">
</a>
</p>

Now that there is a FoodServer backend for the [FoodTracker](https://github.com/IBM/FoodTrackerBackend) app, you can add HTTP basic authentication to the routes. This will allow your users to log in, have the server identify them and respond accordingly.


## Pre-Requisites:
These instructions follow on from the FoodTracker application and server created by following the [FoodTrackerBackend](https://github.com/IBM/FoodTrackerBackend) tutorial. If you have completed the FoodTracker Backend there are no further pre-requisites.

If you have not completed the [FoodTrackerBackend](https://github.com/IBM/FoodTrackerBackend) tutorial go to the [CompletedFoodTracker](https://github.com/IBM/FoodTrackerBackend/tree/CompletedFoodTracker) branch and follow the [README](https://github.com/IBM/FoodTrackerBackend/blob/CompletedFoodTracker/README.md) instructions.

## HTTP Basic authentication

HTTP Basic authentication transmits credentials in an “Authorization” header as base64 encoded user ID/password pairs. Kitura also allows you to send the username and password in the URL as follows:
```
https://username:password@www.example.com/
```
Note: some web browsers disable this for security reasons.

### Add the Kitura-CredentialsHTTP dependency
[Kitura-CredentialsHTTP](https://github.com/IBM-Swift/Kitura-CredentialsHTTP) is a [Kitura-Credentials](https://github.com/IBM-Swift/Kitura-Credentials) plugin that lets you perform HTTP basic authentication and needs to be added to our `Package.swift` file.

1. In the terminal, go to your server's `Package.swift` file.
```
cd ~/FoodTrackerBackend/FoodServer
open Package.swift
```
2. Add the `Kitura-CredentialsHTTP` package:
```swift
.package(url: "https://github.com/IBM-Swift/Kitura-CredentialsHTTP", from: "2.1.0"),
```
3. Change the target for Application to include "CredentialsHTTP":
```swift
.target(name: "Application", dependencies: [ "Kitura", "CloudEnvironment", "SwiftMetrics", "Health", "SwiftKueryORM", "SwiftKueryPostgreSQL", "CredentialsHTTP"]),
```
4. Regenerate your FoodServer Xcode project:
```
swift package generate-xcodeproj
```

### Create the TypeSafeHTTPBasic struct

We will declare a struct which conforms to `TypeSafeHTTPBasic`. This will be initialized when our route is successfully authenticated and we will be able to access the authenticated user's id within our Codable route.
1. Open the FoodServer Xcode project
```
open FoodServer.xcodeproj/
```
2. Inside `Sources > Application > Application.swift` add `CredentialsHTTP` to your imports:
```swift
import CredentialsHTTP
```

Below the `Persistence` Class, define a public struct called `MyBasicAuth` that conforms to the `TypeSafeHTTPBasic` protocol:
```swift
public struct MyBasicAuth: TypeSafeHTTPBasic {

}
```
3. Xcode should display the message:
```
Type 'MyBasicAuth' does not conform to protocol 'TypeSafeCredentials'
```
Click "Fix" to autogenerate the stubs below:
```swift
public static func verifyPassword(username: String, password: String, callback: @escaping (MyBasicAuth?) -> Void) {

}

public var id: String
```
4. Inside `MyBasicAuth`, add an authentication dictionary:
```swift
public static let authenticate = ["username": "password"]
```
5. The function, `verifyPassword`, takes a username and password and, on success, returns a `MyBasicAuth` instance. We want to check if the password matches the user's stored password. On successful match, we initialize `MyBasicAuth` with an `id` equal to username.
```swift
if let storedPassword = authenticate[username], storedPassword == password {
    callback(MyBasicAuth(id: username))
    return
}
callback(nil)
```
This function is async, so that you can perform async actions to verify the password, e.g. looking up the username and password in a database. You must call the callback closure with either an instance of 'Self' or 'nil' before exiting 'verifyPassword'. If you do not, the server will not know to continue and you will receive a 503 "Service Unavailable" error, when you call the route.  

Your complete struct should now look as follows:
```swift
public struct MyBasicAuth: TypeSafeHTTPBasic {

    public static let authenticate = ["username": "password"]

    public static func verifyPassword(username: String, password: String, callback: @escaping (MyBasicAuth?) -> Void) {
        if let storedPassword = authenticate[username], storedPassword == password {
            callback(MyBasicAuth(id: username))
            return
        }
        callback(nil)
    }

    public var id: String
}
```

### Adding Basic Auth to the routes

`MyBasicAuth` is a Type-safe middleware and can be registered to a Codable route by adding it to the handler signature.

Add `auth: MyBasicAuth` to the completion closure in the storeHandler signature.
```swift
func storeHandler(auth: MyBasicAuth, meal: Meal, completion: @escaping (Meal?, RequestError?) -> Void ) {
```
Add `auth: MyBasicAuth` to the completion closure in the loadHandler signature.
```swift
func loadHandler(auth: MyBasicAuth, completion: @escaping ([Meal]?, RequestError?) -> Void ) {
```
Add `auth: MyBasicAuth` to the completion closure in the summaryHandler signature.
```swift
func summaryHandler(auth: MyBasicAuth, completion: @escaping (Summary?, RequestError?) -> Void ) {
```

These routes now require basic authentication. You can test this by running the server and going to [http://localhost:8080/summary](http://localhost:8080/summary).  

The request will be rejected as unauthorized and your browser will offer a window for you to input the username and password.  

Enter "username" and "password" to be allowed to view the route or any other combination to have the request rejected.  

The browser will store correct credentials so use a private window if you want to test rejected credentials.

Congratulations!!! You have just added HTTP basic authentication to your Kitura server.

### Sending credentials from your mobile app

You need to enable your food tracker mobile application to send the username and password so that it can continue to connect to your now protected routes. You can do this by setting the default credentials on the KituraKit client as shown below.

1. Open the FoodTracker workspace:
```
cd ~/FoodTrackerBackend/iOS/FoodTracker/  
open FoodTracker.xcworkspace
```
2. Open the `FoodTracker > MealTableViewController.swift` file
3. Add default credentials inside the `saveToServer` function to be used by the client:
```swift
client.defaultCredentials = HTTPBasic(username: "username", password: "password")
```
This will add the credentials to all your KituraKit requests.  

4. You could also add credentials on individual routes as follows:
```swift
client.post("/meals", data: meal, credentials: HTTPBasic(username: "username", password: "password"))
```
However that is not required for this example.  

Now your Foodtracker app and server will be able to send and receive requests using basic authentication!
