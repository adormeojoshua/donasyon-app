import SwiftUI

struct MyProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    
   
    @State private var navigateToEdit = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - Top Navigation Area
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // MARK: - Profile Image & Info
                    VStack(spacing: 15) {
                        // Profile Image
                        ZStack {
                            if let image = userProfileViewModel.selectedImage {
                                image
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                        }
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                       
                        .overlay(Circle().stroke(Color.appGreen, lineWidth: 3))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        
                        VStack(spacing: 8) {
                            Text(userProfileViewModel.userName)
                                .font(.custom(appFont, size: 28))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            HStack {
                                Image("goldt")
                                    .resizable().scaledToFit().frame(height: 18)
                                Text("Gold Donor")
                                    .font(.custom(appFont, size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(.appGreen)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.05), radius: 2)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                    
                    // MARK: - Details Cards
                    VStack(spacing: 20) {
                        
                       
                        VStack(alignment: .leading, spacing: 10) {
                            Text("About Me")
                                .font(.custom(appFont, size: 18)).fontWeight(.bold).foregroundColor(.gray)
                            
                            Text(userProfileViewModel.bio.isEmpty ? "No bio yet." : userProfileViewModel.bio)
                                .font(.custom(appFont, size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                        }
                        
                        // Personal Details
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Personal Details")
                                .font(.custom(appFont, size: 18)).fontWeight(.bold).foregroundColor(.gray)
                            
                            VStack(spacing: 0) {
                                InfoRow(icon: "envelope.fill", label: "Email", value: userProfileViewModel.userEmail)
                                Divider().padding(.leading, 50)
                                InfoRow(icon: "figure.stand", label: "Gender", value: userProfileViewModel.gender)
                                Divider().padding(.leading, 50)
                                InfoRow(icon: "calendar", label: "Birthday", value: userProfileViewModel.birthDate.formatted(date: .long, time: .omitted))
                            }
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100) // Space for button
                }
            }
            
            // MARK: - Edit Button (Floating Bottom)
            VStack {
                Spacer()
                Button(action: { navigateToEdit = true }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Profile")
                    }
                    .font(.custom(appFont, size: 18).weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appGreen)
                    .cornerRadius(30)
                    .shadow(color: Color.appGreen.opacity(0.4), radius: 10, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .hideTabBar()
        
        // Navigate to the Editable ProfileView
        .navigationDestination(isPresented: $navigateToEdit) {
            ProfileView() //existing editable view
        }
    }
}

// Helper Row View
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.appGreen)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption).foregroundColor(.gray)
                Text(value.isEmpty ? "Not set" : value)
                    .font(.custom(appFont, size: 16)).foregroundColor(.black)
            }
            Spacer()
        }
        .padding()
    }
}

struct MyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MyProfileView()
            .environmentObject(UserProfileViewModel())
    }
}
