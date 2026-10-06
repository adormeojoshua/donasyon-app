import SwiftUI

struct RewardsView: View {
    @Environment(\.dismiss) var dismiss
    
  
    @EnvironmentObject var rewardsViewModel: RewardsViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    

    @State private var showPointsInfo = false
    
    // Sample Rewards Data
    let rewards: [RewardItem] = [
        RewardItem(imageName: "Smart", title: "Smart eSim Load", points: 100000),
        RewardItem(imageName: "mcdo sundae", title: "Hot Fudge Sundae", points: 100000),
        RewardItem(imageName: "grab", title: "P100 GrabGifts", points: 300000),
        RewardItem(imageName: "mcdo chicken", title: "McDonald's 1pc", points: 250000),
        RewardItem(imageName: "gulp", title: "7-11 Gulp Drink", points: 25000)
    ]
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    

    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            // Background Header Decoration
            Circle()
                .fill(Color.appGreen.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -150)
            Circle()
                .fill(Color.appGreen.opacity(0.05))
                .frame(width: 200, height: 200)
                .offset(x: 150, y: -50)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // MARK: - 1. Custom Nav Bar
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
                        
                        Text("Rewards")
                            .font(.custom(appFont, size: 20).weight(.bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // History Button
                        NavigationLink(destination: RedeemedHistoryView()) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - 2. Rich Points Banner
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(LinearGradient(colors: [Color.appGreen, Color.appGreen.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: Color.appGreen.opacity(0.3), radius: 10, y: 5)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Available Points")
                                    .font(.custom(appFont, size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                // INFO BUTTON (Opens Sheet)
                                Button(action: { showPointsInfo = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "info.circle.fill")
                                        Text("How it works")
                                            .font(.custom(appFont, size: 12).weight(.bold))
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Capsule())
                                    .foregroundColor(.white)
                                }
                            }
                            
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                // Uses Spending Points
                                Text("\(userProfileViewModel.userPoints)")
                                    .font(.custom(appFont, size: 48).weight(.black))
                                    .foregroundColor(.white)
                                
                                Text("PTS")
                                    .font(.custom(appFont, size: 16).weight(.bold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.bottom, 6)
                            }
                            
                            Spacer().frame(height: 10)
                            
                            // Decorative Progress Bar
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Donating gives you spending power!")
                                    .font(.caption).foregroundColor(.white.opacity(0.7))
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color.black.opacity(0.1))
                                        Capsule().fill(Color.white)
                                            .frame(width: geo.size.width * 0.7) // Dummy visual
                                    }
                                }
                                .frame(height: 6)
                            }
                        }
                        .padding(25)
                    }
                    .frame(height: 180)
                    .padding(.horizontal)
                    
                    // MARK: - 3. Rewards Grid
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Redeem Items")
                            .font(.custom(appFont, size: 20).weight(.bold))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(rewards) { reward in
                                NavigationLink(destination: RewardDetailView(reward: reward)) {
                                    RichRewardCard(reward: reward)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
        .hideTabBar()
        .sheet(isPresented: $showPointsInfo) {
            PointsInfoView()
                .presentationDetents([.medium]) // Show as half sheet
        }
    }
}

// MARK: - Rich Reward Card Helper
struct RichRewardCard: View {
    let reward: RewardItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area
            ZStack {
                Color.gray.opacity(0.05)
                Image(reward.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            }
            .frame(height: 140)
            .clipped()
            
            // Info Area
            VStack(alignment: .leading, spacing: 8) {
                Text(reward.title)
                    .font(.custom(appFont, size: 14).weight(.bold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .frame(height: 35, alignment: .topLeading)
                
             
                Text("\(reward.points.formatted()) PTS")
                    .font(.custom(appFont, size: 14).weight(.heavy))
                    .foregroundColor(.appGreen)
             
                
                Text("Redeem >")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.gray.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(12)
            .background(Color.white)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

// Preview
struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
            .environmentObject(RewardsViewModel())
            .environmentObject(UserProfileViewModel())
    }
}
