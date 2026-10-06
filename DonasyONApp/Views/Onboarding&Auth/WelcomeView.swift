import SwiftUI

struct WelcomeView: View {

    let password: String
    let firstName: String
    let lastName: String
    let middleName: String?
    

    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @EnvironmentObject var rewardsViewModel: RewardsViewModel // Add if needed globally
    
    @State private var isLoading = false
    @State private var showingAlert = false
    

    @State private var goToHome = false
    
    let appFont = "HelveticaNeue"
    let appGreen = Color.appGreen

    var body: some View {
        NavigationStack {
            VStack {
                
                // Title
                Text("Welcome")
                    .font(.custom(appFont, size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 50)

                Text("Mabuhay! You’re now part of DonasyON — where every donation, big or small, creates a ripple of kindness. Let’s work hand in hand to uplift lives and build a better tomorrow.")
                    .font(.custom(appFont, size: 16))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                Spacer()

                // Logo
                Image("help")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .padding(.bottom, 40)

                Spacer()
                
                //FINISH BUTTON UPDATED
                Button(action: {
                    Task {
                        isLoading = true
                        authViewModel.errorMessage = nil
                        userProfileViewModel.errorMessage = nil
                        
                        let newUser = await authViewModel.signUp(withEmail: userProfileViewModel.userEmail, password: password)
                        
                        if let userId = newUser?.uid {
                            await userProfileViewModel.saveUserProfile(
                                userId: userId,
                                firstName: firstName,
                                lastName: lastName,
                                middleName: middleName
                            )
                            
                            //If no save errors → go to home
                            if userProfileViewModel.errorMessage == nil {
                                isLoading = false
                                goToHome = true
                                return
                            }
                        }
                        
                        //If sign up failed or save fail
                        isLoading = false
                        showingAlert = true
                    }
                }) {
                    if isLoading {
                        ProgressView().tint(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(appGreen).cornerRadius(30)
                    } else {
                        Text("Finish")
                            .font(.custom(appFont, size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(appGreen)
                            .cornerRadius(30)
                    }
                }
                .disabled(isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            .navigationBarBackButtonHidden(true)
            
            //
            .navigationDestination(isPresented: $goToHome) {
                HomeView()
                    .environmentObject(authViewModel)
                    .environmentObject(userProfileViewModel)
                    .environmentObject(rewardsViewModel) 
            }
            
            // Alert for errors
            .alert("Sign Up Failed", isPresented: $showingAlert, actions: {
                 Button("OK") {
                     authViewModel.errorMessage = nil
                     userProfileViewModel.errorMessage = nil
                     showingAlert = false
                 }
            }, message: {
                 Text(authViewModel.errorMessage ?? userProfileViewModel.errorMessage ?? "An unknown error occurred. Please try again.")
            })
        }
    }
}

// Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(password: "123456", firstName: "Juan", lastName: "Dela Cruz", middleName: nil)
            .environmentObject(AuthenticationViewModel())
            .environmentObject(UserProfileViewModel())
            .environmentObject(RewardsViewModel())
    }
}
