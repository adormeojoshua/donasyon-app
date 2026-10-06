import SwiftUI

struct MoreView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Header
                    HStack(alignment: .center) {
                        Text("More")
                            .font(.custom(appFont, size: 40))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image(systemName: "gearshape.2.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .foregroundColor(Color.appGreen.opacity(0.8))
                            .rotationEffect(.degrees(15))
                            .offset(y: 10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    
                    // MARK: - Options List
                    VStack(spacing: 0) {
                        
                        // Group 1: Account
                        NavigationLink(destination: MyProfileView()) {
                            MoreOptionRow(icon: "person", title: "My Account")
                        }
                        
                        CustomDivider()
                        
                        // Group 2: Info (LINKED TO NEW VIEWS)
                        NavigationLink(destination: AboutUsView()) {
                            MoreOptionRow(icon: "info.circle", title: "About Us")
                        }
                        CustomDivider()
                        
                        NavigationLink(destination: TermsView()) {
                            MoreOptionRow(icon: "doc.text", title: "Terms and Conditions")
                        }
                        CustomDivider()
                        
                        NavigationLink(destination: PrivacyView()) {
                            MoreOptionRow(icon: "lock", title: "Privacy Statement")
                        }
                        CustomDivider()
                        
                        // Group 3: Support (LINKED TO NEW VIEWS)
                        NavigationLink(destination: FAQsView()) {
                            MoreOptionRow(icon: "questionmark.circle", title: "FAQs")
                        }
                        CustomDivider()
                        
                        NavigationLink(destination: HelpSupportView()) {
                            MoreOptionRow(icon: "headphones", title: "Help & Support")
                        }
                        CustomDivider()
                        
                        // Group 4: Settings (LINKED TO NEW VIEWS)
                        NavigationLink(destination: RegionLanguageView()) {
                            MoreOptionRow(icon: "globe", title: "Region & Language")
                        }
                        
                        CustomDivider()
                        
                        // Log Out
                        Button(action: {
                            authViewModel.signOut()
                        }) {
                            HStack(spacing: 20) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 20))
                                    .frame(width: 24)
                                    .foregroundColor(.red.opacity(0.8))
                                
                                Text("Log Out")
                                    .font(.custom(appFont, size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 18)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color.white)
                }
                .padding(.bottom, 100)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .showTabBar()
        }
    }
}

// MARK: - Helper Components

struct MoreOptionRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .frame(width: 24)
                .foregroundColor(.black.opacity(0.7))
            
            Text(title)
                .font(.custom(appFont, size: 16))
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.gray.opacity(0.5))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}

struct CustomDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 68)
            .padding(.trailing, 24)
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
            .environmentObject(UserProfileViewModel())
            .environmentObject(AuthenticationViewModel())
    }
}
