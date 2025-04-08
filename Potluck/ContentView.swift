
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @StateObject var authViewModel = AuthViewModel()
    @StateObject private var deepLinkHandler = DeepLinkHandlerViewModel()
    @State private var isLoading = true
    @AppStorage("profileSetupComplete") var profileSetupComplete: Bool = false
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if authViewModel.user != nil {
                if profileSetupComplete {
                    MainTabView()
                        .onAppear {
                            // Delegate deep link handling to the view model.
                            deepLinkHandler.handlePendingDeepLink(eventID: deepLinkManager.pendingEventID)
                            deepLinkManager.clear()
                        }
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
                withAnimation { isLoading = false }
                return
            }
            
            if profileSetupComplete {
                withAnimation { isLoading = false }
            } else {
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).getDocument { document, error in
                    if let document = document, document.exists,
                       let data = document.data(),
                       let firstName = data["firstName"] as? String, !firstName.isEmpty,
                       let lastName = data["lastName"] as? String, !lastName.isEmpty {
                        DispatchQueue.main.async { profileSetupComplete = true }
                    }
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

