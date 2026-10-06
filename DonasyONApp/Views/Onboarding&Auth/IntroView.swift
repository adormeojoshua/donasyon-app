import SwiftUI

struct IntroView: View {
    @State private var showOnboarding = false
    @State private var goToLogin = false

    var body: some View {
        NavigationStack {
            Group {
                if showOnboarding {
                    
                    OnboardingView(goToLogin: {
                        goToLogin = true
                    })
                    .navigationDestination(isPresented: $goToLogin) {
                        LoginView()
                    }
                } else {
                    
                    splashScreen
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showOnboarding) // smooth fade
            .onAppear {
                // seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showOnboarding = true
                }
            }
        }
    }

    // MARK: - Splash Screen View
    private var splashScreen: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color(red: 0.6, green: 0.75, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Image("applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                
                Text("Small Acts Big Bayanihan")
                    .font(.headline)
                    .foregroundColor(.black)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.5)
            }
        }
    }
}
