import SwiftUI

struct RewardDetailView: View {
    @Environment(\.dismiss) var dismiss
    let reward: RewardItem


    @EnvironmentObject var viewModel: RewardsViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel

    @State private var showCode = false
    @State private var redemptionCode = ""
    @State private var isProcessing = false


    private var canAfford: Bool {
        return userProfileViewModel.userPoints >= reward.points
    }
    
   
    private var affordabilityProgress: Double {
        if canAfford { return 1.0 }
        if reward.points == 0 { return 1.0 }
        return Double(userProfileViewModel.userPoints) / Double(reward.points)
    }
    


    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - 1. Rich Header Image
                    ZStack(alignment: .topLeading) {
                        ZStack {
                            Color.gray.opacity(0.1) // Placeholder background
                            Image(reward.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(40)
                        }
                        .frame(height: 300)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                        
                        // Back Button
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        .padding(.leading, 20)
                        .padding(.top, 50)
                    }
                    
                    // MARK: - 2. Content Body
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Title & Points
                        VStack(alignment: .leading, spacing: 8) {
                            Text(reward.title)
                                .font(.custom(appFont, size: 28).weight(.bold))
                                .foregroundColor(.black)
                                .lineLimit(2)
                            
                            HStack {
                                
                                
                                Text("\(reward.points.formatted()) PTS")
                                    .font(.custom(appFont, size: 22).weight(.heavy))
                                    .foregroundColor(.appGreen)
                                
                                Spacer()
                                
                                // Status Badge
                                if canAfford {
                                    Text("Redeemable")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.appGreen)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.appGreen.opacity(0.1))
                                        .cornerRadius(8)
                                } else {
                                    Text("Locked")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Description")
                                .font(.custom(appFont, size: 18).weight(.bold))
                                .foregroundColor(.gray)
                            
                            Text("Redeem this item to receive a unique voucher code. This code can be presented at participating branches or entered in the partner app to claim your reward. Make sure to screenshot your code!")
                                .font(.custom(appFont, size: 16))
                                .foregroundColor(.black.opacity(0.8))
                                .lineSpacing(5)
                        }
                        
                        // MARK: - Balance Checker UI
                        if !showCode {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Your Balance")
                                        .font(.caption).foregroundColor(.gray)
                                    Spacer()
                                    Text("\(userProfileViewModel.userPoints) / \(reward.points)")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(canAfford ? .appGreen : .red)
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color.gray.opacity(0.2))
                                            .frame(height: 8)
                                        
                                        Capsule().fill(canAfford ? Color.appGreen : Color.orange)
                                            .frame(width: geo.size.width * CGFloat(affordabilityProgress), height: 8)
                                    }
                                }
                                .frame(height: 8)
                                
                                if !canAfford {
                                    Text("You need \(reward.points - userProfileViewModel.userPoints) more points to claim this.")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // MARK: - 3. Sticky Bottom Button / Code View
            VStack {
                Spacer()
                
                Group {
                    if showCode {
                        // VOUCHER CODE DISPLAY (Success State)
                        VStack(spacing: 15) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.appGreen)
                            
                            Text("Successfully Redeemed!")
                                .font(.custom(appFont, size: 20).weight(.bold))
                            
                            VStack(spacing: 5) {
                                Text("YOUR CODE")
                                    .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                                Text(redemptionCode)
                                    .font(.system(size: 24, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 1, dash: [5])).foregroundColor(.gray))
                            }
                            
                            Text("A copy has been saved to your History.")
                                .font(.caption).foregroundColor(.gray)
                            
                            Button(action: { dismiss() }) {
                                Text("Done")
                                    .font(.custom(appFont, size: 16).weight(.bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black)
                                    .cornerRadius(25)
                            }
                        }
                        .padding(25)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                        .padding()
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // REDEEM BUTTON (Normal State)
                        Button(action: {
                            isProcessing = true
                            Task {
                                // Generate Code
                                let newCode = "VOUCHER-\(String(UUID().uuidString.prefix(8)).uppercased())"
                                redemptionCode = newCode
                                
                                await viewModel.redeem(item: reward, code: newCode)
                                
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                
                                isProcessing = false
                                if viewModel.errorMessage == nil {
                                    withAnimation(.spring()) {
                                        showCode = true
                                    }
                                }
                            }
                        }) {
                            HStack {
                                if isProcessing {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(canAfford ? "Redeem Now" : "Insufficient Points")
                                        .font(.custom(appFont, size: 18).weight(.bold))
                                    if !canAfford {
                                        Image(systemName: "lock.fill")
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canAfford ? Color.appGreen : Color.gray)
                            .cornerRadius(30)
                            .shadow(color: (canAfford ? Color.appGreen : Color.gray).opacity(0.4), radius: 10, y: 5)
                        }
                        .disabled(!canAfford || isProcessing)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .hideTabBar()
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "Could not redeem item.")
        })
    }
}

// Preview
struct RewardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RewardDetailView(reward: RewardItem(imageName: "mcdo sundae", title: "McDonald's Sundae", points: 5000))
            .environmentObject(RewardsViewModel())
            .environmentObject(UserProfileViewModel())
    }
}
