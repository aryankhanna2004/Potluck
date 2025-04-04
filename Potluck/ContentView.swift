import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @State private var isLoading = true
    @AppStorage("profileSetupComplete") var profileSetupComplete: Bool = false

    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if authViewModel.user != nil {
                if profileSetupComplete {
                    MainTabView()
                } else {
                    ProfileSetupView()
                }
            } else {
                LoginView()
            }
        }
        .onReceive(authViewModel.$user) { _ in
            withAnimation {
                isLoading = false
            }
        }
        .environmentObject(authViewModel)
    }
}


struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            NewEventView()
                .tabItem {
                    Label("New Event", systemImage: "plus.circle")
                }
            MyEventsView()
                .tabItem {
                    Label("My Events", systemImage: "list.bullet")
                }
        }
    }
}

