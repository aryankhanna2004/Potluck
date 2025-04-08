import SwiftUI
import FirebaseFirestore
import FirebaseAuth

enum AuthState {
    case loading
    case profileSetupIncomplete
    case profileComplete
    case signedOut
}

struct ContentView: View {
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @StateObject var authViewModel = AuthViewModel()
    @StateObject private var deepLinkHandler = DeepLinkHandlerViewModel()
    @AppStorage("profileSetupComplete") var profileSetupComplete: Bool = false
    @State private var authState: AuthState = .loading

    var body: some View {
        Group {
            switch authState {
            case .loading:
                LoadingView()
            case .profileComplete:
                MainTabView()
                    .onAppear {
                        deepLinkHandler.handlePendingDeepLink(eventID: deepLinkManager.pendingEventID)
                        deepLinkManager.clear()
                    }
            case .profileSetupIncomplete:
                ProfileSetupView()
            case .signedOut:
                NavigationView {
                    LoginView()
                }
            }
        }
        .onReceive(authViewModel.$user) { user in
            if let user = user {
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).getDocument { document, error in
                    DispatchQueue.main.async {
                        if let document = document,
                           document.exists,
                           let data = document.data(),
                           let firstName = data["firstName"] as? String, !firstName.isEmpty,
                           let lastName = data["lastName"] as? String, !lastName.isEmpty {
                            if !profileSetupComplete {
                                profileSetupComplete = true
                            }
                            authState = .profileComplete
                        } else {
                            profileSetupComplete = false
                            authState = .profileSetupIncomplete
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    authState = .signedOut
                }
            }
        }
        .onChange(of: profileSetupComplete) {
            // Use the zero-parameter action closure.
            if profileSetupComplete {
                authState = .profileComplete
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
            ProfilePageView()  
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
