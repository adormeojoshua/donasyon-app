import SwiftUI

class TabBarManager: ObservableObject {
    @Published var isVisible: Bool = true
    @Published var selectedTab: Tab = .home
    
    
    @Published var homeViewID = UUID()
    
    func switchToHome() {
        self.selectedTab = .home
    }
    
    func resetHome() {
        
        self.selectedTab = .home
        
        self.homeViewID = UUID()
    }
}
