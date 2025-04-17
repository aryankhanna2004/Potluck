//
//  RecipeSearchView.swift
//  Potluck
//
//  Created by Itea on 4/15/25.
//

import SwiftUI

//Model
struct Recipe: Identifiable, Codable {
    let id: Int
    let title: String
    let image: String?
    
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

struct RecipeSearchResponse: Codable {
    let results: [Recipe]
}

//View
struct RecipeSearchView: View {
    @StateObject private var viewModel = RecipeSearchViewModel()

    var body: some View {
        
        VStack {
            HStack {
                TextField("Search recipes...", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Search") {
                    Task {
                        await viewModel.searchRecipes()
                    }
                }
            }
            .padding()

            if viewModel.isLoading {
                ProgressView()
            }

            List(viewModel.recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    HStack {//format each recipe 
                        if let imageUrl = recipe.image,
                           let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }

                        Text(recipe.title)
                            .font(.headline)
                            .padding(.leading, 5)
                    }
                    .padding(.vertical, 4)
                }
            }

            Spacer()
        }
        .navigationTitle("Recipes")
        
    }
}
