import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Image("logoHQ")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            
            Text("Welcome Back")
                .font(.largeTitle).bold()
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                if let error = authVM.authError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    authVM.signIn(email: email, password: password)
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Text("—or—")
                .foregroundColor(.gray)
            
            GoogleSignInButton()  // your existing Google sign‑in button
            
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                NavigationLink("Sign Up here", destination: SignUpView())
                    .foregroundColor(Color.green)
            }
            .font(.footnote)
        }
        .padding()
    }
}


struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Image("logoHQ")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("Create Account")
                .font(.title).bold()
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                SecureField("Confirm Password", text: $confirm)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                if let error = authVM.authError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    guard password == confirm else {
                        authVM.authError = "Passwords do not match"
                        return
                    }
                    authVM.signUp(email: email, password: password)
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}
