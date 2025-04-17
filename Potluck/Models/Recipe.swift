//
//  Recipe.swift
//  Potluck
//
//  Created by ET Loaner on 4/17/25.
//
import SwiftUI
import SwiftData

//recipe model
struct RecipeDetail: Codable {
    let title: String
    let image: String?
    var summary: String?
    var instructions: String?
    let extendedIngredients: [Ingredient]?
}

struct Ingredient: Codable, Identifiable {
    let id: Int
    let original: String
}

struct RecipeSearchResponse: Codable {
    let results: [Recipe]
}


@Model
final class Dish {
    var id: UUID = UUID()
    var name: String
    // Optionally, will relate a dish to a potluck event.
    var event: PotluckEvent?

    init(name: String, event: PotluckEvent? = nil) {
        self.name = name
        self.event = event
    }
}

struct Recipe: Identifiable, Codable {
    let id: Int
    let title: String
    let image: String?
    
}
