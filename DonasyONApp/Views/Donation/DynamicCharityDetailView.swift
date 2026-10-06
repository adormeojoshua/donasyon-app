import SwiftUI
import FirebaseFirestore

struct DynamicCharityDetailView: View {
    @Environment(\.dismiss) var dismiss
    let charity: Charity
    @State private var goDonate = false
    
    //CONNECTED MANAGERS
    @StateObject private var charityViewModel = CharityViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    //STATE FOR ORGANIZER PROFILE
    @State private var organizerImage: Image?
    @State private var showDeleteAlert = false
    
    private var progress: Double {
        return charity.currentAmount / charity.targetAmount
    }
    
    //Check ownership
    private var isOwner: Bool {
        guard let currentUID = authViewModel.userSession?.uid else { return false }
        return currentUID == charity.organizerUID
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                //Header Image
                ZStack(alignment: .topLeading) {
                    ZStack {
                        Color.gray.opacity(0.1)
                        charity.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 15))

                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white.opacity(0.85))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.leading, 15)
                    .padding(.top, 15)
                }

                Text(charity.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.primary)

                //Progress Bar
                VStack(alignment: .leading, spacing: 10) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .appGreen))
                        .scaleEffect(x: 1, y: 3.5, anchor: .center)
                        .clipShape(Capsule())
                        .frame(height: 8)

                    HStack {
                        Text("₱\(Int(charity.currentAmount))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appGreen)
                        Spacer()
                        Text("₱\(Int(charity.targetAmount))")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }

                Divider().padding(.vertical, 8)

                //ORGANIZER SECTION (UPDATED)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Organizer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        //Dynamic Profile Picture
                        if let organizerImage = organizerImage {
                            organizerImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        } else {
                            //Fallback Placeholder
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(charity.organizerName)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 4) {
                                Text("Verified User")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                // -----------------------------------

                Divider().padding(.vertical, 8)

                //Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(charity.description)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 90)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .overlay(alignment: .bottom) {
            Button(action: { goDonate = true }) {
                Text("Donate now")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.appGreen)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goDonate) {
            DonateView(charity: charity)
        }
        .hideTabBar()
        
        //FETCH IMAGE ON APPEAR
        .onAppear {
            fetchOrganizerImage()
        }
        
        //DELETE TOOLBAR
        .toolbar {
            if isOwner {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .red)
                            .font(.system(size: 30))
                            .shadow(radius: 2)
                    }
                }
            }
        }
        .alert("Delete Campaign?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                charityViewModel.deleteCharity(charity)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    //FUNCTION TO FETCH ORGANIZER IMAGE
    private func fetchOrganizerImage() {
        guard let uid = charity.organizerUID else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let base64String = data["profileImage"] as? String,
               let imageData = Data(base64Encoded: base64String),
               let uiImage = UIImage(data: imageData) {
                
                //Update UI on Main Thread
                DispatchQueue.main.async {
                    self.organizerImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}
