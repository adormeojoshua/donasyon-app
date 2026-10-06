import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    // Connect to ViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
 
    @State private var showSuccessAlert = false
    @State private var isSaving = false
  
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - Top Header Background
                    ZStack(alignment: .topLeading) {
                        LinearGradient(gradient: Gradient(colors: [Color.appGreen, Color.appGreen.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(height: 220)
                            .clipShape(
                                UnevenRoundedRectangle(cornerRadii: .init(
                                    topLeading: 0,
                                    bottomLeading: 40,
                                    bottomTrailing: 40,
                                    topTrailing: 0
                                ))
                            )
                            .ignoresSafeArea()
                        
                        // Back Button
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                        .padding(.top, 10)
                    }
                    
                    // MARK: - Profile Image & Rank
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $userProfileViewModel.selectedPhotoItem, matching: .images) {
                            ZStack {
                                if let image = userProfileViewModel.selectedImage {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 140, height: 140)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 140, height: 140)
                                        .foregroundColor(.white)
                                        .background(Color.gray.opacity(0.3))
                                        .clipShape(Circle())
                                }
                                
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.appGreen)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                                    .offset(x: 50, y: 50)
                            }
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                        
                        VStack(spacing: 5) {
                            Text(userProfileViewModel.userName)
                                .font(.custom(appFont, size: 28))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            HStack {
                                Image("goldt")
                                    .resizable().scaledToFit().frame(height: 20)
                                Text("Gold Donor")
                                    .font(.custom(appFont, size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(.appGreen)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.appGreen.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                    .offset(y: -70)
                    .padding(.bottom, -50)
                    
                    // MARK: - Form Fields
                    VStack(alignment: .leading, spacing: 20) {
                        
                        ProfileSectionHeader(title: "Personal Information")
                        
                        ProfileTextField(icon: "person", title: "Username", text: $userProfileViewModel.userName)
                        
                        ProfileTextField(icon: "envelope", title: "Email", text: $userProfileViewModel.userEmail)
                            .disabled(true)
                            .opacity(0.7)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio")
                                .font(.custom(appFont, size: 14))
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            TextEditor(text: $userProfileViewModel.bio)
                                .font(.custom(appFont, size: 16))
                                .frame(height: 80)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                        }
                        
                        ProfileSectionHeader(title: "Details")
                        
                        HStack(spacing: 15) {
                            HStack {
                                Image(systemName: "figure.stand")
                                    .foregroundColor(.appGreen)
                                Picker("Gender", selection: $userProfileViewModel.gender) {
                                    Text("Male").tag("Male")
                                    Text("Female").tag("Female")
                                    Text("Other").tag("Other")
                                }
                                .labelsHidden()
                                .accentColor(.black)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.appGreen)
                                DatePicker("", selection: $userProfileViewModel.birthDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                        }
                        
                        ProfileSectionHeader(title: "Security")
                        
                        NavigationLink(destination: ChangePasswordView()) {
                            HStack {
                                Image(systemName: "lock.rotation")
                                    .foregroundColor(.appGreen)
                                Text("Change Password")
                                    .font(.custom(appFont, size: 16).weight(.medium))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                        }
                        
                        // Save Button
                        Button(action: {
                            isSaving = true
                            Task {
                                if let userId = authViewModel.userSession?.uid {
                                    // Save the profile
                                    await userProfileViewModel.saveUserProfile(userId: userId, firstName: "", lastName: "", middleName: nil)
                                    
                                    await MainActor.run {
                                        isSaving = false
                                        // Trigger Alert if successful
                                        if userProfileViewModel.errorMessage == nil {
                                            showSuccessAlert = true
                                        }
                                    }
                                }
                            }
                        }) {
                            ZStack {
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Save Changes")
                                        .font(.custom(appFont, size: 18).weight(.bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appGreen)
                            .cornerRadius(20)
                            .shadow(color: Color.appGreen.opacity(0.4), radius: 8, y: 4)
                        }
                        .padding(.top, 10)
                        .disabled(isSaving)
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .hideTabBar()
        
      
        .alert("Success!", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                
                dismiss()
            }
        } message: {
            Text("Your profile has been updated successfully.")
        }
     
    }
}

// MARK: - Local Helper Components

struct ProfileSectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.custom(appFont, size: 18))
            .fontWeight(.bold)
            .foregroundColor(.black.opacity(0.7))
            .padding(.top, 10)
    }
}

struct ProfileTextField: View {
    let icon: String
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom(appFont, size: 14))
                .foregroundColor(.gray)
                .padding(.leading, 4)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.appGreen)
                    .frame(width: 20)
                TextField(title, text: $text)
                    .font(.custom(appFont, size: 16))
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserProfileViewModel())
            .environmentObject(AuthenticationViewModel())
    }
}
