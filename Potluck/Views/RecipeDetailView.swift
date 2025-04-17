//
//  RecipeDetailView.swift
//  Potluck
//
//  Created by Itea on 4/15/25.
//

import SwiftUI

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


struct RecipeDetailView: View {
    let recipe: Recipe
    @StateObject private var viewModel = RecipeDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let detail = viewModel.recipeDetail {
                    //image of meal
                    if let imageUrl = detail.image,
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                            case .failure(_):
                                Image(systemName: "photo")
                            default:
                                ProgressView()
                            }
                        }
                        .frame(height: 200)
                    }

                    //title food
                    Text(detail.title)
                        .font(.title).bold()

                    //ingredients
                    if let ingredients = detail.extendedIngredients {
                        Text("Ingredients:")
                            .font(.headline)
                        ForEach(ingredients) { ingredient in
                            Text("• \(ingredient.original)")
                                .font(.body)
                        }
                    }

                    //instructions
                    if let instructions = detail.instructions {
                        Text("Instructions:")
                            .font(.headline)
                            .padding(.top, 10)

                        Text(instructions)
                            .font(.body)
                    }
                } else if viewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .task {
            await viewModel.fetchDetails(for: recipe.id)
        }
    }
}




