# Completed FoodTracker Backend with Kitura

<p align="center">
<img src="https://www.ibm.com/cloud-computing/bluemix/sites/default/files/assets/page/catalog-swift.svg" width="120" alt="Kitura Bird">
</p>

<p align="center">
<a href= "http://swift-at-ibm-slack.mybluemix.net/">
<img src="http://swift-at-ibm-slack.mybluemix.net/badge.svg"  alt="Slack">
</a>
</p>

This branch is a completed version of the "Building a FoodTracker Backend with Kitura" tutorial, which adds a [Kitura Swift backend](http://kitura.io) to the [FoodTracker iOS app tutorial](https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/) from Apple. This can be used as a starting point for any of the [next steps](#next-steps) of the tutorial.


## FoodTracker Setup:

Follow the steps below to set up your completed iOS Foodtracker and Kitura server:

1. Ensure you have Swift 4, Xcode 9.x and Kitura 2.x installed.

2. Ensure you have CocoaPods installed:

`sudo gem install cocoapods`

3. Install PostgreSQL:
```
brew install postgresql
brew services start postgresql
```

4. Create a database called FoodDatabase to store the data:
```
createdb FoodDatabase
```

5. Open a terminal window and clone the FoodTracker application and Server:

`git clone https://github.com/IBM/FoodTrackerBackend.git`

6. Switch to the "completedFoodBackend" branch:
```
cd FoodTrackerBackend
git checkout CompletedFoodTracker
```
7. Use Cocoapods to install app dependencies:
```
cd iOS/FoodTracker
pod install
```
8. Open the FoodTracker Application in Xcode
```
open FoodTracker.xcworkspace/
```
This Xcode workspace contains the food tracker mobile app, which can be run by clicking the play button.

9. Generate the server Xcode project:
```
cd ../../FoodServer/
swift package generate-xcodeproj
open FoodServer.xcodeproj/
```
10. In the top left corner of Xcode you should a small toolbox icon with the text "FoodServer-Package" next to it. Click this icon and then click "FoodServer" from the dropdown menu.

Now when you press play, Xcode will start your FoodTracker server listening on port 8080. You can see this by going to [http://localhost:8080/](http://localhost:8080/ ) which will show the default Kitura landing page.

To test the application and server are working, add a meal inside the application and go to [http://localhost:8080/summary](http://localhost:8080/summary). The server will display the name and rating of the meals in your app.

## Next Steps
From this completed Foodtracker, the following tasks can be completed to update your application.

### Add a Website Frontend using the Stencil Template Engine
The current implementation of the Kitura FoodServer returns a JSON array of the meals. To create a website, you would want to use html to structure the page. The following contains steps to embed the meal data into html and [add a Website Frontend using the Stencil Template Engine](StencilFrontend.md)

### Add Support for Retrieving and Deleting Meals from the FoodServer
The current implementation of the Kitura FoodServer has support for retrieving all of the stored Meals using a `GET` request on `/meals`, but the FoodTracker app is currently only saving the Meals to the FoodServer. The following contains the steps to add [Retrieving and Deleting Meals from the FoodServer](RetrievingAndDeleting.md)

### Add a Web Application to the Kitura server
Now that the Meals from the FoodTracker app are being stored on a server, it becomes possible to start building a web application that also provides users with access to the stored Meal data.
The following steps describe how to start to [Build a FoodTracker Web Application](AddWebApplication.md)

### Add HTTP Basic authentication to the Kitura server
The current implementation of the Kitura FoodServer will allow anyone to request all the meals. We can add HTTP Basic authentication to make the routes require a username and password. This allows you to authenticate a user and have the  server respond accordingly.

### Deploy and host the Kitura FoodServer in the Cloud
In order for a real iOS app to connect to a Kitura Server, it needs to be hosted at a public URL that the iOS app can reach.

Kitura is deployable to any cloud, but the project created with `kitura init` provides additonal files so that it is pre-configured for clouds that support any of Cloud Foundry, Docker or Kubernetes. The follow contains the steps to take the Kitura FoodServer and [Deploy to the IBM Cloud using Cloud Foundry](DeployToCloud.md)

### View a sample Todo list application using Kitura
This tutorial takes you through the basics of creating a Kitura server. To see a completed Todo list application with demonstrations of all HTTP requests go to [iOSSampleKituraKit](https://github.com/IBM-Swift/iOSSampleKituraKit)
