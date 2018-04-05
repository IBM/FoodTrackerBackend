import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health
import SwiftKueryORM
import SwiftKueryPostgreSQL

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()
extension Meal: Model {
    static var idColumnName = "name"
}

class Persistence {
    static func setUp() {
        let pool = PostgreSQLConnection.createPool(host: "localhost", port: 5432, options: [.databaseName("FoodDatabase")], poolOptions: ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 50, timeout: 10000))
        Database.default = Database(pool)
    }
}

public class App {
    let router = Router()
    let cloudEnv = CloudEnv()

    public init() throws {
        // Run the metrics initializer
        initializeMetrics(router: router)
    }

    func postInit() throws {
        // Endpoints
        initializeHealthRoutes(app: self)
        router.post("/meals", handler: storeHandler)
        router.get("/meals", handler: loadHandler)
        router.get("/summary", handler: summaryHandler)
        Persistence.setUp()
        do {
            try Meal.createTableSync()
        } catch let error {
            print(error)
        }
    }
    
    func storeHandler(meal: Meal, completion: @escaping (Meal?, RequestError?) -> Void ) {
        meal.save(completion)
    }
    
    func loadHandler(completion: @escaping ([Meal]?, RequestError?) -> Void ) {
        Meal.findAll(completion)
    }
    
    func summaryHandler(completion: @escaping (Summary?, RequestError?) -> Void ) {
        Meal.findAll { meals, error in
            if let meals = meals {
                completion(Summary(meals), nil)
            }
        }
    }
    
    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
}
