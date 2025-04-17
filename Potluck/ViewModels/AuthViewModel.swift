import FirebaseAuth
import Combine
import FirebaseFirestore   

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var authError: String?
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signIn(email: String, password: String) {
        authError = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            self?.authError = error?.localizedDescription
        }
    }
    
    func signUp(email: String, password: String) {
        authError = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            self?.authError = error?.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            authError = error.localizedDescription
        }
    }
}
