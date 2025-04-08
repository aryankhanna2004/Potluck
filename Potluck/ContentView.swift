import SwiftUI
import FirebaseFirestore

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
                NavigationView {
                    LoginView()
                }
            }
        }
        .onReceive(authViewModel.$user) { user in
            guard let user = user else {
                // User not signed in – stop loading immediately.
                withAnimation { isLoading = false }
                return
            }
            
            // If AppStorage indicates profile is complete, no need to check Firestore.
            if profileSetupComplete {
                withAnimation { isLoading = false }
            } else {
                // Quick check in Firestore to see if profile values already exist.
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).getDocument { document, error in
                    if let document = document, document.exists,
                       let data = document.data(),
                       let firstName = data["firstName"] as? String, !firstName.isEmpty,
                       let lastName = data["lastName"] as? String, !lastName.isEmpty {
                        // Profile exists in the database—update AppStorage.
                        DispatchQueue.main.async {
                            profileSetupComplete = true
                        }
                    }
                    // End loading once check is complete.
                    DispatchQueue.main.async {
                        withAnimation { isLoading = false }
                    }
                }
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

