import SwiftUI

struct SplashScreenView: View {
  
    
    var body: some View {
        ZStack {
            // Background Color
            Color.appGreen
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // MARK: - YOUR LOGO HERE
               
                Image("logonga")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    
                    .padding(20)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // App Name
                Text("DonasyON")
                    .font(.custom(appFont, size: 40))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Tagline
                Text("Small Acts, Big Bayanihan")
                    .font(.custom(appFont, size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 30)
                
                // Loading Spinner
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
