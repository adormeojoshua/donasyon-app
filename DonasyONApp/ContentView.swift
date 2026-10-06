import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    // Connect other ViewModels so we can clear them on logout
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @EnvironmentObject var rewardsViewModel: RewardsViewModel
    
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // 1. Main App Logic
            Group {
                if authViewModel.userSession != nil {
                    MainTabView() // Go to App if logged in
                } else {
                    LoginView()   // Go to Login if logged out
                }
            }
            .opacity(showSplash ? 0 : 1)
            
            // 2. Splash Screen Overlay
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.8)) { showSplash = false }
            }
        }
        
        .onChange(of: authViewModel.userSession) { user in
            if user == nil {
                // User just logged out. Wipe everything.
                print("Logout detected in ContentView. Clearing all data.")
                userProfileViewModel.clearData()
                rewardsViewModel.clearData()
            }
        }
     
    }
}
