# Build a FoodTracker Web Application

Now that there is a [FoodServer as a backend for the FoodTracker app](README.md), it becomes possible to start building a web application that also provides users with access to the stored Meal data.

The steps below show how to start hosting a web application for the images in the Kitura server.

### Pre-Requisites:
This tutorial follows on from the FoodTracker Application and server created by following the [FoodTrackerBackend](https://github.com/IBM/FoodTrackerBackend) tutorial. If you have completed the FoodTracker Backend there are no further pre-requisites.

If you have not completed the [FoodTrackerBackend](https://github.com/IBM/FoodTrackerBackend) tutorial go to the [CompletedFoodTracker](https://github.com/IBM/FoodTrackerBackend/tree/CompletedFoodTracker) branch and follow the README instructions.

### Serve the Meals using Static File Serving
One approach to making the Meals available through a web application is to store copies of the images on the local file system, and serve them using Kitura's StaticFileServer.

1. Update the Kitura server application to add a StaticFileServer  
   1. Open the `Sources/Application/Application.swift` source file that contains the REST API routes
   2. Setup the file handler to write to the web hosting directory by adding the following under the `let cloudEnv = CloudEnv()` declaration:
    ```swift
    private var fileManager = FileManager.default
    private var rootPath = StaticFileServer().absoluteRootPath
    ```
   3. Add a Static File Server by adding the following to the `postInit()` function:  
    ```swift
    router.get("/images", middleware: StaticFileServer())
    ```

    This will serve the contents of a directory, defaulting to the projects `/public` directory, as web pages.

2. Save the images to the StaticFileServer directory  
   Update the `storeHandler()` function to save the images to the directory the Static File Server is using by adding the following:
      ```swift
        let path = rootPath + "/" + meal.name + ".jpg"
        fileManager.createFile(atPath: path, contents: meal.photo)
      ```

3. Create the `public` directory to store the images:
   ```
   cd ~/FoodTrackerBackend/FoodServer/
   mkdir public
   ```

4. Re-build and re-run the server  
   Press the Run button or use the ⌘+R key shortcut.

5. Rerun the FoodTracker iOS App and view the images
   1. Run the iOS app in XCode and add or remove a Meal entry.  
   This is required to trigger a new save of the data to the server.
   2. Visit the web application to see the saved image at:  
   [http://localhost:8080/images/Caprese Salad.jpg](http://localhost:8080/images/Caprese%20Salad.jpg)

You can now view any of the saved images from the food tracker by going to: `http://localhost:8080/images/<meal name>.jpg`
These images can then be referenced in HTML using:  
`<img src="images/<meal name>.jpg">`
