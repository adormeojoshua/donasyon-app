import SwiftUI

// MARK: - Home View (Root View)
struct HomeView: View {
    //STATE VARIABLES
    @State private var selectedCategory: CharityCategory? = nil
    @State private var selectedCharity: Charity? = nil
    
    //NEW: Search Text State
    @State private var searchText: String = ""

    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var rewardsViewModel: RewardsViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    
    @StateObject private var charityViewModel = CharityViewModel()

    //UPDATED FILTERING LOGIC
    private var displayedCharities: [Charity] {
        // 1. Start with all charities
        var charities = charityViewModel.charities
        
        // 2. Filter by Category (if selected)
        if let category = selectedCategory {
            charities = charities.filter { $0.category == category }
        }
        
        // 3. Filter by Search Text (if typed)
        if !searchText.isEmpty {
            charities = charities.filter { charity in
                // Check if title OR organizer contains the text (case insensitive)
                charity.title.localizedCaseInsensitiveContains(searchText) ||
                charity.organizerName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return charities
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                LinearGradient(gradient: Gradient(colors: [Color.appGreen.opacity(0.6), Color.appGreen.opacity(0.2), Color.clear]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 250)
                    .ignoresSafeArea(edges: .top)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: - Header
                        HStack(spacing: 12) {
                            if let image = userProfileViewModel.selectedImage {
                                image.resizable().scaledToFill().frame(width: 44, height: 44).clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill").font(.system(size: 44)).foregroundColor(.gray.opacity(0.8))
                            }
                            
                            Text("Hello \(userProfileViewModel.userName)")
                                .font(.custom(appFont, size: 32)).fontWeight(.bold)
                                .lineLimit(1).minimumScaleFactor(0.8)
                            
                            Spacer()
                            
                            NavigationLink(destination: RewardsView()){
                                Image(systemName: "gift.fill").font(.system(size: 22, weight: .medium)).foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)

                        // MARK: - Donation Points
                        DonationPointsCard().padding(.horizontal).padding(.top, 10)
                        
                        // MARK: - Search Bar (WORKING)
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            
                            //BINDING TO SEARCH TEXT
                            TextField("Find charities...", text: $searchText)
                                .font(.custom(appFont, size: 16))
                                .autocorrectionDisabled(true)
                            
                            //Clear Button
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    //Hide keyboard
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding().background(Color.white).clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.05), radius: 5)
                        .padding(.horizontal).padding(.top, 25)

                        // MARK: - Categories Section
                        Text("Categories")
                            .font(.custom(appFont, size: 22))
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 25)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                CategoryItemView(
                                    title: "All",
                                    icon: "square.grid.2x2.fill",
                                    isSystemIcon: true,
                                    isSelected: selectedCategory == nil
                                )
                                .onTapGesture { withAnimation { selectedCategory = nil } }
                                
                                ForEach(CharityCategory.allCases, id: \.self) { category in
                                    CategoryItemView(
                                        title: category.rawValue,
                                        icon: category.iconName,
                                        isSystemIcon: false,
                                        isSelected: selectedCategory == category
                                    )
                                    .onTapGesture { withAnimation { selectedCategory = category } }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                        .zIndex(1)

                        // MARK: - Live Charity List
                        VStack(spacing: 16) {
                            if displayedCharities.isEmpty {
                                //Improved Empty State for Search
                                VStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.5))
                                    
                                    if !searchText.isEmpty {
                                        Text("No results for \"\(searchText)\"")
                                            .font(.custom(appFont, size: 16))
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("No campaigns found.")
                                            .font(.custom(appFont, size: 16))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            } else {
                                ForEach(displayedCharities, id: \.uniqueID) { charity in
                                    CharityCard(charity: charity)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedCharity = charity
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
            .task {
                charityViewModel.fetchCharities()
                if let userId = authViewModel.userSession?.uid {
                    await userProfileViewModel.fetchUserProfile(userId: userId)
                    rewardsViewModel.fetchRedeemedItems(userId: userId)
                }
            }
            .showTabBar()
            
            .navigationDestination(item: $selectedCharity) { charity in
                DynamicCharityDetailView(charity: charity)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helper: Plain View
struct CategoryItemView: View {
    let title: String
    let icon: String
    let isSystemIcon: Bool
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if isSystemIcon {
                    Image(systemName: icon).resizable().scaledToFit().padding(20)
                } else {
                    Image(icon).resizable().scaledToFit().padding(18)
                }
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color.appGreen : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: isSelected ? Color.appGreen.opacity(0.4) : Color.black.opacity(0.05), radius: 5, y: 3)
            .foregroundColor(isSelected ? .white : .appGreen)
            
            Text(title)
                .font(.custom(appFont, size: 13))
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundColor(isSelected ? .appGreen : .gray)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(RewardsViewModel())
        .environmentObject(UserProfileViewModel())
        .environmentObject(TabBarManager())
}
