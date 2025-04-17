import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

struct GoogleSignInButton: View {
    var body: some View {
        Button(action: googleSignIn) {
            HStack {
                Text("Sign in with Google")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .background(Color.purple)
            .cornerRadius(8)
        }
    }
    
    func googleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Missing clientID")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("No root view controller found")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Google sign in error: \(error.localizedDescription)")
                return
            }
            
            guard let result = result,
                  let idToken = result.user.idToken?.tokenString else {
                print("Failed to retrieve Google user or id token")
                return
            }
            let accessToken = result.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in with Google error: \(error.localizedDescription)")
                } else {
                    print("Google sign in successful!")
                }
            }
        }
    }
}
