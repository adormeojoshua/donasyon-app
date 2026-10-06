import SwiftUI

struct RankingsInfoView: View {
    @Environment(\.dismiss) var dismiss

    // Use the shared source of truth
    let rankings: [RankItem] = RankItem.allRanks.reversed()
    
    // let appFont = "Helvetica Neue" // Defined globally

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // Header
                    ZStack(alignment: .bottomLeading) {
                        Image("hider2")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .overlay(LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Donor Rankings")
                                .font(.custom(appFont, size: 36)).fontWeight(.bold).foregroundColor(.white).shadow(radius: 5)
                            
                           
                            Text("Rank up by donating! Every donation attempt earns you 15 Rank Points, regardless of amount.")
                                .font(.custom(appFont, size: 16)).foregroundColor(.white.opacity(0.9)).lineLimit(3).shadow(radius: 5)
                            // ---------------------------
                        }
                        .padding(.horizontal, 24).padding(.bottom, 40)
                    }
                    .frame(height: 300)
                    
                    // Ranks List
                    VStack(spacing: 16) {
                        ForEach(rankings) { rank in
                            RankTierRow(rank: rank)
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, -20).padding(.bottom, 50)
                }
            }
            .ignoresSafeArea()
            
            // Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left").font(.system(size: 20, weight: .bold)).foregroundColor(.black).padding(12).background(Color.white).clipShape(Circle()).shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
            }
            .padding(.leading, 20).padding(.top, 50)
        }
        .navigationBarHidden(true)
        .hideTabBar()
    }
}

// Helper Row View
struct RankTierRow: View {
    let rank: RankItem
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle().fill(Color(UIColor.systemGray6)).frame(width: 80, height: 80)
                Image(rank.imageName).resizable().scaledToFit().frame(width: 60, height: 60).shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(rank.name).font(.custom(appFont, size: 20)).fontWeight(.bold).foregroundColor(Color.appGreen)
                Text("Required Points:").font(.caption).foregroundColor(.gray).textCase(.uppercase)
                Text(rank.pointsRange).font(.custom(appFont, size: 16)).fontWeight(.medium).foregroundColor(.black)
            }
            Spacer()
            Image(systemName: "seal.fill").font(.title2).foregroundColor(Color.appGreen.opacity(0.2))
        }
        .padding(16).background(Color.white).cornerRadius(20).shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct RankingsInfoView_Previews: PreviewProvider {
    static var previews: some View { RankingsInfoView() }
}
