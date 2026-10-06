import SwiftUI

struct PointsInfoView: View {
    @Environment(\.dismiss) var dismiss
  
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                HStack {
                    Spacer()
                    Text("How to Earn Points")
                        .font(.custom(appFont, size: 20).weight(.bold))
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 20)
                
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.appGreen)
                    .padding(.vertical, 10)
                
                // Rules
                VStack(spacing: 15) {
                    PointRuleRow(points: "10", label: "Points per Donation", desc: "Earn a flat bonus every time you donate, regardless of the amount.")
                    
                    Divider()
                    
                    PointRuleRow(points: "25", label: "Points per ₱100", desc: "For every 100 pesos you give, you earn huge points to climb the leaderboard.")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct PointRuleRow: View {
    let points: String
    let label: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text("+\(points)")
                .font(.custom(appFont, size: 24).weight(.black))
                .foregroundColor(.appGreen)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.custom(appFont, size: 16).weight(.bold))
                Text(desc)
                    .font(.custom(appFont, size: 14))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}
