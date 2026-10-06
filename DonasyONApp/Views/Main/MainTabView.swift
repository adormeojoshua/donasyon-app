import SwiftUI

// 1. Define the available tabs
enum Tab: String, CaseIterable {
    case home, leaderboard, upload, wallet, more
}

struct MainTabView: View {
    //Connect to Manager
    @StateObject private var tabBarManager = TabBarManager()
    
    init() { UITabBar.appearance().isHidden = true }

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: - Main Content Switcher
            TabView(selection: $tabBarManager.selectedTab) {
                
                
                HomeView()
                    .tag(Tab.home)
                   
                    .id(tabBarManager.homeViewID)
            
                
                LeaderboardView().tag(Tab.leaderboard)
                
                UploadWrapperView().tag(Tab.upload)
                
                WalletView().tag(Tab.wallet)
                    
                MoreView().tag(Tab.more)
            }
            .environmentObject(tabBarManager)
            
            // MARK: - Custom Tab Bar Overlay
            if tabBarManager.isVisible {
                CustomTabBar(selectedTab: $tabBarManager.selectedTab)
                    .padding(.bottom, -20)
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}


struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var body: some View {
        HStack {
            TabItemView(tab: .home, selectedTab: $selectedTab, iconName: "list.bullet.rectangle.portrait")
            Spacer()
            TabItemView(tab: .leaderboard, selectedTab: $selectedTab, iconName: "trophy.fill")
            Spacer()
            Spacer().frame(width: 60)
            Spacer()
            TabItemView(tab: .wallet, selectedTab: $selectedTab, iconName: "wallet.pass.fill")
            Spacer()
            TabItemView(tab: .more, selectedTab: $selectedTab, iconName: "ellipsis.circle.fill")
        }
        .padding(.vertical, 18).padding(.horizontal, 25)
        .background(Color.white).clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .overlay(
            Button(action: { withAnimation(.spring()) { selectedTab = .upload } }) {
                ZStack {
                    Circle().fill(Color(red: 69/255, green: 143/255, blue: 90/255)).stroke(Color.white, lineWidth: 4).frame(width: 70, height: 70).shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    Image(systemName: "leaf.fill").resizable().scaledToFit().frame(width: 30, height: 30).foregroundColor(.white)
                }
            }.offset(y: -30), alignment: .top
        )
    }
}

struct TabItemView: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    let iconName: String
    let themeGreen = Color(red: 69/255, green: 143/255, blue: 90/255)
    var isSelected: Bool { selectedTab == tab }
    var body: some View {
        Button(action: { withAnimation(.easeInOut) { selectedTab = tab } }) {
            VStack(spacing: 4) {
                Image(systemName: iconName).resizable().scaledToFit().frame(width: 24, height: 24).foregroundColor(isSelected ? themeGreen : Color.gray.opacity(0.5))
                 if isSelected { Circle().fill(themeGreen).frame(width: 5, height: 5) } else { Circle().fill(Color.clear).frame(width: 5, height: 5) }
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(RewardsViewModel())
            .environmentObject(UserProfileViewModel())
    }
}
