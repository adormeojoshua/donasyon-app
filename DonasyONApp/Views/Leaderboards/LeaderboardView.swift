import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) var dismiss
    
    // CONNECTED VIEW MODEL
    @StateObject private var viewModel = LeaderboardViewModel()
    
    // Global font
    let appFont = "Helvetica Neue"

    @State private var selectedTab: String = "All time"

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 1. Background (Green Theme)
                LinearGradient(gradient: Gradient(colors: [Color.appGreen, Color.appGreen.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Header
                    HStack {
                        // Spacer to balance
                        Spacer().frame(width: 44)
                        
                        Spacer()
                        
                        Text("Leaderboard")
                            .font(.custom(appFont, size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Info Button
                        NavigationLink(destination: RankingsInfoView().hideTabBar()) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .frame(width: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // MARK: - Tabs
                    HStack(spacing: 0) {
                        TabButton(title: "Weekly", selectedTab: $selectedTab)
                        TabButton(title: "All time", selectedTab: $selectedTab)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 25)
                    
                    // MARK: - Podium Section
                    HStack(alignment: .bottom, spacing: 15) {
                        // 2nd Place
                        if viewModel.topThree.count > 1 {
                            PodiumColumnView(user: viewModel.topThree[1], rank: 2, height: 160, rankColor: .silver)
                        }
                        
                        // 1st Place
                        if let first = viewModel.topThree.first {
                            PodiumColumnView(user: first, rank: 1, height: 200, isCenter: true, rankColor: .gold)
                                .zIndex(1)
                                .offset(y: -10)
                        }
                        
                        // 3rd Place
                        if viewModel.topThree.count > 2 {
                            PodiumColumnView(user: viewModel.topThree[2], rank: 3, height: 130, rankColor: .bronze)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                    // MARK: - List (4th onwards)
                    ZStack(alignment: .top) {
                        Color.white
                            .clipShape(
                                UnevenRoundedRectangle(cornerRadii: .init(
                                    topLeading: 30,
                                    bottomLeading: 0,
                                    bottomTrailing: 0,
                                    topTrailing: 30
                                ))
                            )
                            .ignoresSafeArea(edges: .bottom)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                if viewModel.otherUsers.isEmpty {
                                    VStack(spacing: 10) {
                                        Image(systemName: "list.number")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.3))
                                        Text("No other donors yet.")
                                            .font(.custom(appFont, size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.top, 50)
                                } else {
                                    ForEach(viewModel.otherUsers) { user in
                                        LeaderboardListRow(user: user)
                                            .padding(.horizontal, 25)
                                            .padding(.vertical, 15)
                                        
                                        if user.id != viewModel.otherUsers.last?.id {
                                            Divider()
                                                .padding(.leading, 70)
                                                .padding(.trailing, 25)
                                        }
                                    }
                                }
                                Spacer().frame(height: 100)
                            }
                            .padding(.top, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchLeaderboard()
            }
            .showTabBar()
        }
    }
}

// MARK: - 1. Podium Column View (Updated Size)
struct PodiumColumnView: View {
    let user: LeaderboardUser
    let rank: Int
    let height: CGFloat
    var isCenter: Bool = false
    let rankColor: Color
    let appFont = "Helvetica Neue"

    var body: some View {
        VStack(spacing: 8) {
            
            // 1. Name & Points (Floating Above)
            VStack(spacing: 2) {
                //UPDATED FONT SIZE
                Text(user.name)
                    .font(.custom(appFont, size: isCenter ? 18 : 15)) // Bigger Name
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: 110) 
                
                
                HStack(spacing: 4) {
                    Text("\(user.points)")
                        .font(.custom(appFont, size: 12))
                        .fontWeight(.heavy)
                        .foregroundColor(.white.opacity(0.9))
                    Text("pts")
                        .font(.custom(appFont, size: 10))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.2))
                .clipShape(Capsule())
            }
            
            // 2. Profile Picture
            user.image
                .resizable()
                .scaledToFill()
                .frame(width: isCenter ? 65 : 55, height: isCenter ? 65 : 55)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
                .offset(y: 25)
                .zIndex(1)
            
            // 3. The Column
            ZStack(alignment: .top) {
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 15,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 15
                ))
                .fill(Color.white)
                .frame(height: height)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                
                Text("\(rank)")
                    .font(.custom(appFont, size: 50))
                    .fontWeight(.black)
                    .foregroundColor(rankColor.opacity(0.8))
                    .padding(.top, 40)
            }
        }
    }
}

// MARK: - 2. List Row View
struct LeaderboardListRow: View {
    let user: LeaderboardUser
    let appFont = "Helvetica Neue"

    var body: some View {
        HStack(spacing: 15) {
            Text(String(format: "%02d", user.rank))
                .font(.custom(appFont, size: 16))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(width: 30)

            user.image
                .resizable()
                .scaledToFill()
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.custom(appFont, size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("\(user.points) pts")
                    .font(.custom(appFont, size: 14))
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
            }

            Spacer()

            switch user.change {
            case .up:
                Image(systemName: "arrowtriangle.up.fill").foregroundColor(.appGreen).font(.caption)
            case .down:
                Image(systemName: "arrowtriangle.down.fill").foregroundColor(.red).font(.caption)
            case .same:
                Image(systemName: "minus").foregroundColor(.gray).font(.caption)
            }
        }
    }
}

// MARK: - 3. Tab Button Helper
struct TabButton: View {
    let title: String
    @Binding var selectedTab: String
    let appFont = "Helvetica Neue"
    @Namespace private var namespace

    var body: some View {
        Button(action: { withAnimation { selectedTab = title } }) {
            Text(title)
                .font(.custom(appFont, size: 14))
                .fontWeight(.bold)
                .foregroundColor(selectedTab == title ? .appGreen : .white.opacity(0.8))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        if selectedTab == title {
                            Capsule()
                                .fill(Color.white)
                                .matchedGeometryEffect(id: "TAB", in: namespace)
                        }
                    }
                )
        }
    }
}

// Colors for Podium
extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let silver = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let bronze = Color(red: 0.80, green: 0.50, blue: 0.20)
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
