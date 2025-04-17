//
//  RecipeSearchView.swift
//  Potluck
//
//  Created by Itea on 4/15/25.
//

import SwiftUI


let spoonacularAPIKey = Secrets.spoonacularAPIKey //use your own API KEY when you sign up on Spoonacular.com

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
