import SwiftUI
import PhotosUI

// MARK: - 1. Verification Intro
struct VerificationIntroView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "shield.check.fill")
                .font(.system(size: 80))
                .foregroundColor(.appGreen)
                .padding()
                .background(Color.appGreen.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 10) {
                Text("Let's Verify Your Identity")
                    .font(.custom(appFont, size: 28))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("To ensure the safety of our donors and beneficiaries, we need to verify your identity before you can start a fundraising campaign.")
                    .font(.custom(appFont, size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            NavigationLink(destination: IDUploadView()) {
                Text("Verify Now")
                    .font(.custom(appFont, size: 18).weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appGreen)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - 2. ID Upload View
struct IDUploadView: View {
    @State private var selectedIDType = "Passport"
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    
    let idTypes = ["Passport", "Driver's License", "National ID (PhilSys)", "UMID"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Upload proof of identity")
                .font(.custom(appFont, size: 24).weight(.bold))
            
            Text("Please select the type of ID you want to upload.")
                .font(.custom(appFont, size: 16)).foregroundColor(.gray)
            
            // ID Type Picker
            VStack(alignment: .leading) {
                Text("ID Type").font(.caption).foregroundColor(.gray)
                Picker("ID Type", selection: $selectedIDType) {
                    ForEach(idTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .accentColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
            }
            
            // Image Picker
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.gray)
                        .frame(height: 200)
                        .background(Color.white)
                    
                    if let selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(10)
                    } else {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .foregroundColor(.appGreen)
                            Text("Tap to take a photo or upload")
                                .font(.custom(appFont, size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = Image(uiImage: uiImage)
                    }
                }
            }
            
            Spacer()
            
            NavigationLink(destination: SelfieCameraView()) {
                Text("Next")
                    .font(.custom(appFont, size: 18).weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedImage == nil ? Color.gray : Color.appGreen)
                    .cornerRadius(30)
            }
            .disabled(selectedImage == nil)
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .hideTabBar() // Hide bottom bar during process
    }
}

// MARK: - 3. Selfie Camera Stub
struct SelfieCameraView: View {
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @State private var isCaptured = false
    
    var body: some View {
        VStack {
            Text("Take a Selfie")
                .font(.custom(appFont, size: 24).weight(.bold))
                .padding(.top, 20)
            
            Text("Make sure your face is clearly visible.")
                .font(.custom(appFont, size: 16)).foregroundColor(.gray)
            
            Spacer()
            
            // Mock Camera View
            ZStack {
                Color.black
                if isCaptured {
                    Image(systemName: "face.smiling.fill") // Placeholder for captured photo
                        .resizable().scaledToFit().foregroundColor(.white).padding(50)
                } else {
                    Image(systemName: "face.dashed") // Placeholder for camera overlay
                        .resizable().scaledToFit().foregroundColor(.white.opacity(0.5)).padding(50)
                }
            }
            .frame(width: 300, height: 400)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appGreen, lineWidth: 4)
            )
            
            Spacer()
            
            if isCaptured {
                Button(action: {
                    userProfileViewModel.submitVerification()
                }) {
                    Text("Submit for Verification")
                        .font(.custom(appFont, size: 18).weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appGreen)
                        .cornerRadius(30)
                }
            } else {
                Button(action: {
                    withAnimation { isCaptured = true } // Simulate capture
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(Circle().stroke(Color.appGreen, lineWidth: 4))
                }
            }
        }
        .padding(.bottom, 30)
        .padding(.horizontal)
        .background(Color(UIColor.systemGroupedBackground))
        .hideTabBar()
    }
}

// MARK: - 4. Pending View
struct VerificationPendingView: View {
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            Image(systemName: "hourglass.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Verification Pending")
                .font(.custom(appFont, size: 28).weight(.bold))
            
            Text("We are currently reviewing your documents. We will notify you once your account has been verified. You cannot upload campaigns until this process is complete.")
                .font(.custom(appFont, size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            
        }
        .padding(.bottom, 100)
    }
}
