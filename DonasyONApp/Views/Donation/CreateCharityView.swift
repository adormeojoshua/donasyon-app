import SwiftUI
import PhotosUI

struct CreateCharityView: View {
    // CONNECTED MANAGERS
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    //AuthViewModel to get the UID
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    @StateObject private var charityViewModel = CharityViewModel()
    
    //FORM STATE
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var targetAmount: String = ""
    @State private var selectedCategory: CharityCategory = .health
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var selectedUIImage: UIImage?
    
    @FocusState private var focusedField: Field?
    enum Field { case title, amount, description }
    
    let appFont = "Helvetica Neue"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { withAnimation { tabBarManager.switchToHome() } }) {
                    Image(systemName: "xmark").font(.system(size: 18, weight: .bold)).foregroundColor(.black).padding(10).background(Color.white).clipShape(Circle()).shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                Spacer()
                Text("Create Campaign").font(.custom(appFont, size: 20)).fontWeight(.bold).foregroundColor(.black)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }.padding(.horizontal, 20).padding(.top, 15).padding(.bottom, 15).background(Color(UIColor.systemGroupedBackground))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Photo Upload
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Campaign Cover").font(.custom(appFont, size: 16).weight(.bold)).foregroundColor(.gray)
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack {
                                if let selectedImage {
                                    selectedImage.resizable().scaledToFill().frame(height: 220).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 15))
                                } else {
                                    RoundedRectangle(cornerRadius: 15).fill(Color.white).frame(height: 220).frame(maxWidth: .infinity).overlay(RoundedRectangle(cornerRadius: 15).stroke(style: StrokeStyle(lineWidth: 2, dash: [5])).foregroundColor(Color.gray.opacity(0.4))).overlay(VStack(spacing: 10) { Image(systemName: "photo.badge.plus").font(.system(size: 40)).foregroundColor(.appGreen); Text("Add a cover photo").font(.custom(appFont, size: 16)).foregroundColor(.gray) })
                                }
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task { if let data = try? await newItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) { selectedImage = Image(uiImage: uiImage); selectedUIImage = uiImage } }
                        }
                    }
                    
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Campaign Title").font(.custom(appFont, size: 16).weight(.bold)).foregroundColor(.gray)
                        TextField("What are you raising funds for?", text: $title).font(.custom(appFont, size: 22).weight(.semibold)).padding().background(Color.white).cornerRadius(12).shadow(color: .black.opacity(0.03), radius: 5, y: 2).focused($focusedField, equals: .title)
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category").font(.custom(appFont, size: 16).weight(.bold)).foregroundColor(.gray)
                        HStack {
                            Image(selectedCategory.iconName).resizable().scaledToFit().frame(width: 30, height: 30).padding(5).background(Color.appGreen.opacity(0.1)).clipShape(Circle())
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(CharityCategory.allCases, id: \.self) { category in Text(category.rawValue).tag(category) }
                            }.pickerStyle(.menu).accentColor(.black)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundColor(.gray)
                        }.padding().background(Color.white).cornerRadius(12).shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                    }
                    
                    // Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Amount").font(.custom(appFont, size: 16).weight(.bold)).foregroundColor(.gray)
                        HStack {
                            Text("₱").font(.custom(appFont, size: 24).weight(.bold)).foregroundColor(Color.appGreen)
                            TextField("0.00", text: $targetAmount).font(.custom(appFont, size: 24).weight(.bold)).keyboardType(.decimalPad).focused($focusedField, equals: .amount)
                        }.padding().background(Color.white).cornerRadius(12).shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description").font(.custom(appFont, size: 16).weight(.bold)).foregroundColor(.gray)
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty { Text("Tell your story...").font(.custom(appFont, size: 16)).foregroundColor(.gray.opacity(0.5)).padding(16) }
                            TextEditor(text: $description).font(.custom(appFont, size: 16)).frame(height: 150).scrollContentBackground(.hidden).padding(8).focused($focusedField, equals: .description)
                        }.background(Color.white).cornerRadius(12).shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                    }
                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 20).padding(.top, 10)
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Submit Button
            VStack {
                Button(action: {
                    //CHECK IF USER IS LOGGED IN
                    guard let target = Double(targetAmount), !title.isEmpty, !description.isEmpty,
                          let userId = authViewModel.userSession?.uid // <--- GET USER ID
                    else { return }
                    
                    //PASS UID TO VIEWMODEL
                    charityViewModel.uploadCharity(
                        title: title,
                        description: description,
                        targetAmount: target,
                        category: selectedCategory,
                        organizer: userProfileViewModel.userName,
                        organizerUID: userId, // <--- SAVED HERE
                        image: selectedUIImage
                    )
                    
                    // Reset
                    title = ""; description = ""; targetAmount = ""; selectedImage = nil; selectedUIImage = nil
                    withAnimation { tabBarManager.switchToHome() }
                }) {
                    Text("Publish Campaign").font(.custom(appFont, size: 18).weight(.bold)).foregroundColor(.white).frame(maxWidth: .infinity).padding().background((title.isEmpty || targetAmount.isEmpty) ? Color.gray : Color.appGreen).cornerRadius(30).shadow(color: (title.isEmpty ? Color.clear : Color.appGreen.opacity(0.4)), radius: 8, y: 4)
                }
                .disabled(title.isEmpty || targetAmount.isEmpty)
                .padding(.horizontal, 24).padding(.bottom, 20)
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemGroupedBackground).opacity(0), Color(UIColor.systemGroupedBackground)]), startPoint: .top, endPoint: .bottom).padding(.top, -40))
        }
        .background(Color(UIColor.systemGroupedBackground))
        .hideTabBar()
    }
}
