import SwiftUI
import PhotosUI

struct SetupAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel

    //RECEIVES PASSWORD
    let password: String
    //LOCAL STATE
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var middleName: String = ""
    
    //Navigation
    @State private var goToAddPhone = false
    
    //Data Arrays
    let genders = ["Male", "Female", "Other", "Prefer not to say"]
    
    //Focus State for smooth UX
    @FocusState private var focusedField: Field?
    enum Field { case first, last, middle, username, bio }

  
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    
                    // MARK: - 1. Rich Header
                    VStack(spacing: 8) {
                        Text("Step 1 of 2")
                            .font(.custom(appFont, size: 14).weight(.bold))
                            .foregroundColor(.appGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.appGreen.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Text("Let's Get to Know You")
                            .font(.custom(appFont, size: 28).weight(.bold))
                            .foregroundColor(.black)
                        
                        Text("Fill in your details to create your donor profile.")
                            .font(.custom(appFont, size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // MARK: - 2. Profile Picture
                    VStack {
                        PhotosPicker(selection: $userProfileViewModel.selectedPhotoItem, matching: .images) {
                            ZStack {
                                if let image = userProfileViewModel.selectedImage {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(.gray.opacity(0.3))
                                        )
                                }
                                
                                //Camera Badge
                                Image(systemName: "camera.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.appGreen)
                                    .background(Circle().fill(Color.white))
                                    .offset(x: 40, y: 40)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                            }
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        }
                        
                        Text("Upload Profile Photo")
                            .font(.custom(appFont, size: 14).weight(.medium))
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                    
                    // MARK: - 3. Personal Info Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Personal Information")
                            .font(.custom(appFont, size: 18).weight(.bold))
                            .foregroundColor(.black.opacity(0.7))
                        
                        // Names
                        HStack(spacing: 12) {
                            SetupTextField(icon: "person", placeholder: "First Name", text: $firstName)
                                .focused($focusedField, equals: .first)
                            
                            SetupTextField(icon: "", placeholder: "Last Name", text: $lastName)
                                .focused($focusedField, equals: .last)
                        }
                        
                        SetupTextField(icon: "person.text.rectangle", placeholder: "Middle Name (Optional)", text: $middleName)
                            .focused($focusedField, equals: .middle)
                        
                        // Username & Bio
                        SetupTextField(icon: "at", placeholder: "Username", text: $userProfileViewModel.userName)
                            .focused($focusedField, equals: .username)
                            .autocapitalization(.none)
                        
                        // Bio Field
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "text.quote")
                                .foregroundColor(.appGreen)
                                .frame(width: 24, height: 24)
                                .padding(.top, 4)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if userProfileViewModel.bio.isEmpty {
                                    Text("Tell us about yourself...")
                                        .font(.custom(appFont, size: 16))
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 4)
                                }
                                TextEditor(text: $userProfileViewModel.bio)
                                    .font(.custom(appFont, size: 16))
                                    .frame(height: 80)
                                    .scrollContentBackground(.hidden)
                                    .focused($focusedField, equals: .bio)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        .overlay(
                            ZStack(alignment: .topLeading) {
                                if userProfileViewModel.bio.isEmpty {
                                    Text("Tell us about yourself...")
                                        .font(.custom(appFont, size: 16))
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.leading, 52) // Align with text editor
                                        .padding(.top, 20)
                                        .allowsHitTesting(false)
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                    // MARK: - 4. Details Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Details")
                            .font(.custom(appFont, size: 18).weight(.bold))
                            .foregroundColor(.black.opacity(0.7))
                        
                        HStack(spacing: 12) {
                            // Date Picker
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.appGreen)
                                DatePicker("", selection: $userProfileViewModel.birthDate, in: ...Date(), displayedComponents: .date)
                                    .labelsHidden()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                            
                            // Gender Picker
                            HStack {
                                Image(systemName: "figure.stand")
                                    .foregroundColor(.appGreen)
                                Picker("", selection: $userProfileViewModel.gender) {
                                    ForEach(genders, id: \.self) { Text($0) }
                                }
                                .labelsHidden()
                                .accentColor(.black)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 100) // Space for bottom button
                }
            }
            .scrollDismissesKeyboard(.interactively)
            
            // MARK: - 5. Continue Button
            VStack {
                Button(action: {
                    // Validate
                    if firstName.isEmpty || lastName.isEmpty || userProfileViewModel.userName.isEmpty {
                        userProfileViewModel.errorMessage = "Please fill in your Name and Username."
                        return
                    }
                    goToAddPhone = true
                }) {
                    Text("Continue")
                        .font(.custom(appFont, size: 18).weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appGreen)
                        .cornerRadius(30)
                        .shadow(color: Color.appGreen.opacity(0.4), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemGroupedBackground).opacity(0), Color(UIColor.systemGroupedBackground)]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 100)
            )
        }
        .navigationBarBackButtonHidden(true)
        .alert("Missing Info", isPresented: .constant(userProfileViewModel.errorMessage != nil), actions: {
            Button("OK") { userProfileViewModel.errorMessage = nil }
        }, message: {
            Text(userProfileViewModel.errorMessage ?? "Please check your inputs.")
        })
        .onAppear {
            if userProfileViewModel.userEmail.isEmpty {
                userProfileViewModel.userEmail = authViewModel.userSession?.email ?? ""
            }
        }
        // Navigation
        .navigationDestination(isPresented: $goToAddPhone) {
            AddPhoneView(password: password, firstName: firstName, lastName: lastName, middleName: middleName)
                .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Helper: Rich Text Field
struct SetupTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .foregroundColor(.appGreen)
                    .frame(width: 24)
            }
            
            TextField(placeholder, text: $text)
                .font(.custom(appFont, size: 16))
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// Preview
struct SetupAccountView_Previews: PreviewProvider {
    static var previews: some View {
        SetupAccountView(password: "password123")
            .environmentObject(AuthenticationViewModel())
            .environmentObject(UserProfileViewModel())
    }
}
