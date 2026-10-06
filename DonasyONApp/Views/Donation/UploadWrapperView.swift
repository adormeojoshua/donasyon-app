import SwiftUI

struct UploadWrapperView: View {
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                switch userProfileViewModel.verificationStatus {
                case .unverified:
                    VerificationIntroView()
                    
                case .pending:
                    VerificationPendingView()
                    
                case .verified:
                    CreateCharityView()
                }
            }
            .showTabBar() 
        }
    }
}
