import SwiftUI

struct SignUpView: View {
    // --- LOCAL STATE ---
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var agreed: Bool = false
    @State private var navigateToSetup = false
    
    // --- VALIDATION STATES ---
    @State private var emailError: String? = nil
    @State private var isCheckingEmail = false
    @State private var usernameError: String? = nil
    @State private var isCheckingUsername = false
    
    @Environment(\.dismiss) private var dismiss

    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel

    
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    
                    // MARK: - 1. Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create Account")
                            .font(.custom(appFont, size: 32).weight(.bold))
                            .foregroundColor(.black)
                        
                        Text("Sign up to start your journey of giving.")
                            .font(.custom(appFont, size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: - 2. Input Fields
                    VStack(spacing: 20) {
                        
                        //USERNAME
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username").font(.caption).foregroundColor(.gray).fontWeight(.bold)
                            
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.appGreen)
                                    .frame(width: 20)
                                TextField("", text: $username)
                                    .autocapitalization(.none)
                                    .font(.custom(appFont, size: 16))
                                
                                if isCheckingUsername {
                                    ProgressView().scaleEffect(0.7)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(usernameError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                            
                            if let error = usernameError {
                                Text(error).font(.caption).foregroundColor(.red)
                            }
                        }
                        
                        //EMAIL
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email").font(.caption).foregroundColor(.gray).fontWeight(.bold)
                            
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.appGreen)
                                    .frame(width: 20)
                                TextField("Enter your username", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .font(.custom(appFont, size: 16))
                                
                                if isCheckingEmail {
                                    ProgressView().scaleEffect(0.7)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(emailError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                            
                            if let error = emailError {
                                Text(error).font(.caption).foregroundColor(.red)
                            }
                        }
                        
                        //PASSWORD
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password").font(.caption).foregroundColor(.gray).fontWeight(.bold)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.appGreen)
                                    .frame(width: 20)
                                SecureField("Create Password", text: $password)
                                    .font(.custom(appFont, size: 16))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                        
                        //CONFIRM PASSWORD
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password").font(.caption).foregroundColor(.gray).fontWeight(.bold)
                            
                            HStack {
                                Image(systemName: "lock.rotation")
                                    .foregroundColor(.appGreen)
                                    .frame(width: 20)
                                SecureField("Re-enter password", text: $confirmPassword)
                                    .font(.custom(appFont, size: 16))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                    }
                    
                    // MARK: - 3. Agreement
                    HStack(alignment: .top, spacing: 12) {
                        Button(action: { withAnimation { agreed.toggle() } }) {
                            Image(systemName: agreed ? "checkmark.square.fill" : "square")
                                .font(.system(size: 22))
                                .foregroundColor(agreed ? .appGreen : .gray)
                        }
                        
                        Text("By creating an account, you agree to our ")
                            .font(.custom(appFont, size: 14))
                            .foregroundColor(.gray)
                        + Text("Terms of Service")
                            .font(.custom(appFont, size: 14).weight(.bold))
                            .foregroundColor(.appGreen)
                        + Text(" and ")
                            .font(.custom(appFont, size: 14))
                            .foregroundColor(.gray)
                        + Text("Privacy Policy")
                            .font(.custom(appFont, size: 14).weight(.bold))
                            .foregroundColor(.appGreen)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                    
                    // MARK: - 4. Continue Button
                    Button(action: {
                        if canContinue() {
                            userProfileViewModel.userName = username
                            userProfileViewModel.userEmail = email
                            navigateToSetup = true
                        }
                    }) {
                        Text("Continue")
                            .font(.custom(appFont, size: 18).weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canContinue() ? Color.appGreen : Color.gray.opacity(0.5))
                            .cornerRadius(30)
                            .shadow(color: (canContinue() ? Color.appGreen : Color.gray).opacity(0.4), radius: 10, y: 5)
                    }
                    .disabled(!canContinue())
                    
                    // Navigation
                    .navigationDestination(isPresented: $navigateToSetup) {
                        SetupAccountView(password: password)
                            .navigationBarBackButtonHidden(true)
                    }
                    
                    // MARK: - 5. Social Divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                        Text("or sign up with").font(.caption).foregroundColor(.gray)
                        Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    }.padding(.vertical, 10)
                    
                    // MARK: - 6. Social Buttons
                    HStack(spacing: 20) {
                        SocialButton(icon: "google", text: "Google")
                        SocialButton(icon: "fb", text: "Facebook")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .alert("Sign Up Error", isPresented: .constant(authViewModel.errorMessage != nil), actions: {
            Button("OK") { authViewModel.errorMessage = nil }
        }, message: {
            Text(authViewModel.errorMessage ?? "An unknown error occurred.")
        })
        
        //REAL-TIME VALIDATION TASKS
        .task(id: email) {
            emailError = nil
            guard !email.isEmpty, email.contains("@"), email.contains(".") else { return }
            try? await Task.sleep(nanoseconds: 800_000_000)
            
            isCheckingEmail = true
            let isTaken = await authViewModel.checkIfEmailInUse(email: email)
            isCheckingEmail = false
            
            if isTaken { withAnimation { emailError = "Email is already in use." } }
        }
        .task(id: username) {
            usernameError = nil
            guard username.count >= 3 else { return }
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8s debounce
            
            isCheckingUsername = true
            let isTaken = await userProfileViewModel.checkIfUsernameExists(username: username)
            isCheckingUsername = false
            
            if isTaken { withAnimation { usernameError = "Username is taken." } }
        }
    }
    
    // Validation
    private func canContinue() -> Bool {
        let isEmailValid = emailError == nil && !isCheckingEmail && email.contains("@") && email.contains(".")
        let isUsernameValid = usernameError == nil && !isCheckingUsername && username.count >= 3
        
        return isEmailValid &&
               isUsernameValid &&
               password.count >= 6 &&
               password == confirmPassword &&
               agreed
    }
}

// MARK: - Helper: Rich Social Button
struct SocialButton: View {
    let icon: String
    let text: String
    
    var body: some View {
        Button(action: { print("TODO: \(text) Sign Up") }) {
            HStack {
                Image(icon) 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text(text)
                    .font(.custom(appFont, size: 16).weight(.bold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.1)))
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(UserProfileViewModel())
    }
}
