import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileSetupView: View {
    @AppStorage("profileSetupComplete") var profileSetupComplete = false
    @StateObject private var vm = ProfileViewModel()
    @StateObject private var deepLinkHandler = DeepLinkHandlerViewModel()
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @State private var currentStep = 0
    @State private var showDeepLinkAlert = false

    // Dietary and allergy options
    let dietaryOptions = ["No Preference","Vegetarian","Vegan","Gluten‑Free","Keto","Paleo","Other"]
    let allergyOptions = ["Peanuts","Shellfish","Dairy","Eggs","Other"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.6), Color.green.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Branding
                    Image("logoHQ")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("Simplifying Group Meals")
                        .font(.title).bold()
                    
                    // Step views
                    Group {
                        switch currentStep {
                        case 0: introStep
                        case 1: nameStep
                        case 2: dietaryStep
                        case 3: allergyStep
                        default: introStep
                        }
                    }
                }
                .padding()
                
                // Loading overlay if needed
                if vm.isLoading {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Saving…")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .navigationBarHidden(true)
            // Error alert from ProfileViewModel if needed
            .alert("Error", isPresented: Binding<Bool>(
                get: { vm.errorMessage != nil },
                set: { newVal in if !newVal { vm.errorMessage = nil } }
            )) {
                Button("OK") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
            .alert(isPresented: $showDeepLinkAlert) {
                Alert(title: Text("Welcome!"),
                      message: Text("You have been added to the event."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
        
    private var introStep: some View {
        VStack(spacing: 15) {
            Text("Potluck makes organizing group meals easy, tracks dietary needs anonymously, and ensures safe and enjoyable dining for everyone.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Let's Get Started") {
                currentStep = 1
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }
    
    private var nameStep: some View {
        VStack(spacing: 15) {
            TextField("First Name", text: $vm.firstName)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
            
            TextField("Last Name", text: $vm.lastName)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
            
            HStack {
                Button("Previous") {
                    currentStep = 0
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Spacer()
                
                Button("Next") {
                    currentStep = 2
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(vm.firstName.isEmpty || vm.lastName.isEmpty)
            }
            .padding(.top)
        }
    }
    
    private var dietaryStep: some View {
        VStack(spacing: 15) {
            Text("Select Dietary Preference")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(dietaryOptions, id: \.self) { option in
                    Text(option)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(vm.selectedDietaryPreferences.contains(option) ? Color.green : Color.white)
                        .foregroundColor(vm.selectedDietaryPreferences.contains(option) ? .white : .black)
                        .cornerRadius(20)
                        .shadow(radius: 2)
                        .onTapGesture {
                            if vm.selectedDietaryPreferences.contains(option) {
                                vm.selectedDietaryPreferences.remove(option)
                            } else {
                                // For single‑selection, we clear previous options.
                                vm.selectedDietaryPreferences = [option]
                            }
                        }
                }
            }
            .padding()
            
            HStack {
                Button("Previous") {
                    currentStep = 1
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Spacer()
                
                Button("Next") {
                    currentStep = 3
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.top)
        }
    }
    
    private var allergyStep: some View {
        VStack(spacing: 15) {
            Text("Select Allergies")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(allergyOptions, id: \.self) { allergy in
                    Text(allergy)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(vm.selectedAllergies.contains(allergy) ? Color.green : Color.white)
                        .foregroundColor(vm.selectedAllergies.contains(allergy) ? .white : .black)
                        .cornerRadius(20)
                        .shadow(radius: 2)
                        .onTapGesture {
                            if vm.selectedAllergies.contains(allergy) {
                                vm.selectedAllergies.remove(allergy)
                            } else {
                                vm.selectedAllergies.insert(allergy)
                            }
                        }
                }
            }
            .padding()
            
            if vm.selectedAllergies.contains("Other") {
                TextField("Please specify other allergy", text: $vm.otherAllergy)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            HStack {
                Button("Previous") {
                    currentStep = 2
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Spacer()
                
                Button("Complete") {
                    vm.saveProfile { success in
                        if success {
                            // After successful profile save, check for a pending deep link.
//                            deepLinkHandler.handlePendingDeepLink(eventID: deepLinkManager.pendingEventID)
//                            deepLinkManager.clear()
                            
                            // Show alert if deep link was processed.
//                            showDeepLinkAlert = true
                            profileSetupComplete = true
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.top)
        }
    }
}
