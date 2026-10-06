import SwiftUI

// --- Shape for curved bottom ---
struct BottomRoundedShape: Shape {
    var radius: CGFloat = 40
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var goToSignup = false
    @State private var isLoading = false

    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel



    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // MARK: - 1. Rich Header Image
                        ZStack(alignment: .bottomLeading) {
                            Image("hawak bag")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 350)
                                .clipShape(BottomRoundedShape(radius: 60))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            // Text Overlay
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Welcome, Hero")
                                    .font(.custom(appFont, size: 36).weight(.bold))
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                                
                                Text("Ready to change a life today?.")
                                    .font(.custom(appFont, size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                        }
                        .ignoresSafeArea(.all, edges: .top)
                        
                        // MARK: - 2. Login Form
                        VStack(spacing: 25) {
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.appGreen)
                                        .frame(width: 20)
                                    TextField("Enter your email", text: $email)
                                        .font(.custom(appFont, size: 16))
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.appGreen)
                                        .frame(width: 20)
                                    SecureField("Enter your password", text: $password)
                                        .font(.custom(appFont, size: 16))
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                                
                                // Forgot Password Link
                                Button(action: { print("Forgot Password tapped") }) {
                                    Text("Forgot Password?")
                                        .font(.custom(appFont, size: 14))
                                        .foregroundColor(.appGreen)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.top, 5)
                            }
                            
                            // MARK: - 3. Login Button
                            Button(action: {
                                guard !email.isEmpty, !password.isEmpty else {
                                    authViewModel.errorMessage = "Please enter both email and password."
                                    return
                                }
                                
                                isLoading = true
                                Task {
                                    await authViewModel.signIn(withEmail: email, password: password)
                                    isLoading = false
                                    if authViewModel.userSession != nil {
                                        userProfileViewModel.userEmail = email
                                    }
                                }
                            }) {
                                ZStack {
                                    if isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Log In")
                                            .font(.custom(appFont, size: 18).weight(.bold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appGreen)
                                .cornerRadius(30)
                                .shadow(color: Color.appGreen.opacity(0.4), radius: 10, y: 5)
                            }
                            .disabled(isLoading)
                            
                            // MARK: - 4. Social & Signup
                            HStack {
                                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                                Text("or login with").font(.caption).foregroundColor(.gray)
                                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                            }
                            .padding(.vertical, 10)
                            
                            HStack(spacing: 20) {
                                LoginSocialButton(icon: "google", text: "Google")
                                LoginSocialButton(icon: "fb", text: "Facebook")
                            }
                            
                            // Sign Up Link
                            HStack {
                                Text("Don't have an account?")
                                    .font(.custom(appFont, size: 16))
                                    .foregroundColor(.gray)
                                
                                Button(action: { goToSignup = true }) {
                                    Text("Sign Up")
                                        .font(.custom(appFont, size: 16))
                                        .fontWeight(.bold)
                                        .foregroundColor(.appGreen)
                                }
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 50)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
            
            
            .navigationDestination(isPresented: $goToSignup) {
                SignUpView()
            }
            
          
            .alert("Login Error", isPresented: .constant(authViewModel.errorMessage != nil), actions: {
                Button("OK") { authViewModel.errorMessage = nil }
            }, message: {
                Text(authViewModel.errorMessage ?? "An unknown error occurred.")
            })
        }
    }
}

// MARK: - Helper: Social Button
struct LoginSocialButton: View {
    let icon: String
    let text: String
    
    var body: some View {
        Button(action: { print("TODO: \(text) Login") }) {
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

// Preview Provider
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(UserProfileViewModel())
    }
}
