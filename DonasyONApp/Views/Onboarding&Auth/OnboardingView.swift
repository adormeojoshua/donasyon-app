import SwiftUI

struct OnboardingView: View {
    var goToLogin: () -> Void

    var body: some View {
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
            
            VStack(alignment: .leading) {
                Spacer().frame(height: 90)
                
                Text("Fundraising")
                    .font(.custom("HelveticaNeue-Bold", size: 52))
                    .foregroundColor(.black)
                    .padding(.horizontal, 23)
                
                Text("Shouldn’t\nbe this\nHard")
                    .font(.custom("HelveticaNeue-Thin", size: 52))
                    .foregroundColor(.black)
                    .padding(.horizontal, 23)
                    .padding(.top, -30)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Fundraising")
                    Text("Charity")
                    Text("Health")
                }
                .font(.custom("HelveticaNeue-Bold", size: 26))
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                
                HStack {
                    Spacer()
                    Button(action: {
                        goToLogin() 
                    }) {
                        HStack {
                            Text("Get started")
                                .font(.custom("HelveticaNeue-Medium", size: 18))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Color.white.opacity(0.5)
                                .clipShape(Capsule())
                        )
                    }
                    .padding(.trailing, 23)
                    .padding(.top, 2)
                }
                
                Spacer().frame(height: 4)
            }
        }
    }
}
