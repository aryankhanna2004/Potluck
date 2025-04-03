import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if authViewModel.user != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .onReceive(authViewModel.$user) { _ in
            // Once the auth state is determined, hide the loading view.
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

