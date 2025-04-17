//
//  RecipeDetailView.swift
//  Potluck
//
//  Created by Itea on 4/15/25.
//

import SwiftUI

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




