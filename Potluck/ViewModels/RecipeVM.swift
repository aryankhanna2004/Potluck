//
//  RecipeVM.swift
//  Potluck
//
//  Created by ET Loaner on 4/17/25.
//
import SwiftUI

//View Model
@MainActor
class RecipeDetailViewModel: ObservableObject {
    @Published var recipeDetail: RecipeDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let apiKey = Secrets.spoonacularAPIKey //hide when pushing to repo

    func fetchDetails(for id: Int) async {
        isLoading = true
        errorMessage = nil //error message displays if request not succesful

        let urlString = "https://api.spoonacular.com/recipes/\(id)/information?apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            isLoading = false
            return
        }

        do {//decode json
            let (data, _) = try await URLSession.shared.data(from: url)
            var decoded = try JSONDecoder().decode(RecipeDetail.self, from: data)

            //strips HTML tags from summary and instructions
            decoded.summary = decoded.summary?.htmlToPlainText()
            decoded.instructions = decoded.instructions?.htmlToPlainText()

            recipeDetail = decoded
        } catch {
            print("Fetch failed: \(error)")
            errorMessage = "Could not load recipe details."
        }

        isLoading = false
    }
}

//helper function for stripping html tags from summaries and instructions
extension String {
    func htmlToPlainText() -> String {
        guard let data = self.data(using: .utf16) else { return self }
        if let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        ) {
            return attributedString.string
        }
        return self
    }
}


//View Model
@MainActor
class RecipeSearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    

    //key hidden, for security.
    //hiding method is weak, should be upgraded
    let apiKey = Secrets.spoonacularAPIKey

    func searchRecipes() async {
        guard !searchQuery.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        let query = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?query=\(query)&number=10&apiKey=\(apiKey)"

        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
            recipes = decoded.results
        } catch {
            print("API error: \(error)")
            errorMessage = "Failed to load recipes."
        }

        isLoading = false
    }
}
