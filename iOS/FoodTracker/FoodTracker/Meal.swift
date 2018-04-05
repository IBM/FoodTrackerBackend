//
//  Meal.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 11/10/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import Foundation

struct Meal: Codable {

    //MARK: Properties

    var name: String
    var photo: Data
    var rating: Int

    //MARK: Initialization

    init?(name: String, photo: Data, rating: Int) {

        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }

        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }

        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0  {
            return nil
        }

        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating

    }
}

struct Summary: Codable {
    var summary: [NoPhotoMeal]
    struct NoPhotoMeal: Codable {
        var name: String
        var rating: Int
        init(_ meal: Meal) {
            self.name = meal.name
            self.rating = meal.rating
        }
    }
    
    init(_ meals: [String: Meal]) {
        summary = meals.map({ NoPhotoMeal($0.value) })
    }
    init(_ meals: [Meal]) {
        summary = meals.map({ NoPhotoMeal($0) })
    }
}
