import SwiftUI


struct AddPhoneView: View {
    @Environment(\.dismiss) private var dismiss
    
    
    let password: String
    let firstName: String
    let lastName: String
    let middleName: String?

    @State private var phoneNumber: String = ""
    @State private var selectedCountry: Country = Country(name: "Philippines", code: "+63", flag: "🇵🇭") // Use Country from DataModels
    @State private var showCountryPicker = false
    @State private var searchText = ""
    @State private var goToVerify = false

    // Use Country from DataModels
    let countries: [Country] = [
        Country(name: "Philippines", code: "+63", flag: "🇵🇭"),
        Country(name: "United States", code: "+1", flag: "🇺🇸"),
        Country(name: "United Kingdom", code: "+44", flag: "🇬🇧"),
    ]

    let appFont = "Helvetica Neue"
    let appGreen = Color.appGreen // Use global color

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium)).foregroundColor(.black)
                    .padding().background(Color(white: 0.9)).clipShape(Circle())
            }

            // Title
            Text("Add Phone Number")
                .font(.custom(appFont, size: 28)).fontWeight(.bold)
                .foregroundColor(.black)

            Text("We will send an OTP Verification to you")
                .font(.custom(appFont, size: 16))
                .foregroundColor(.black.opacity(0.7))
                .padding(.top, -15)

            // Phone Input HStack
            HStack {
                Button(action: { showCountryPicker = true }) {
                    HStack {
                        Text(selectedCountry.flag)
                        Text(selectedCountry.code)
                            .font(.system(size: 18, weight: .semibold)).foregroundColor(.black)
                    }
                }
                Divider().frame(height: 25)
                TextField("Enter your Phone Number", text: $phoneNumber)
                    .keyboardType(.numberPad).font(.system(size: 18)).foregroundColor(.black)
                    .padding(.vertical, 12)
            }
            .padding(.horizontal, 16)
            .background(RoundedRectangle(cornerRadius: 30).stroke(Color.gray, lineWidth: 1))
            .padding(.top, 10)

            Spacer()

            // Send Code Button
            Button(action: {
                
                print("Pretending to send code to \(selectedCountry.code)\(phoneNumber)")
                goToVerify = true
            }) {
                Text("Send Code")
                    .font(.custom(appFont, size: 18)).fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(appGreen)
                    .cornerRadius(30)
            }
            .disabled(phoneNumber.isEmpty)
            .padding(.bottom, 30)

        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .sheet(isPresented: $showCountryPicker) {
            countryPicker // Show sheet for country selection
        }
        .navigationBarHidden(true) // Hide default nav bar
        
        //FIX: Replaced NavigationLink with navigationDestination 
        .navigationDestination(isPresented: $goToVerify) {
            VerifyPhoneView(
                fullPhoneNumber: "\(selectedCountry.code)\(phoneNumber)",
                password: password,
                firstName: firstName,
                lastName: lastName,
                middleName: middleName
            )
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // Country Picker View (as a sheet)
    var countryPicker: some View {
        NavigationStack {
            List {
                ForEach(filteredCountries) { country in
                    Button(action: {
                        selectedCountry = country
                        showCountryPicker = false
                    }) {
                        HStack {
                            Text(country.flag)
                            Text(country.name).foregroundColor(.primary)
                            Spacer()
                            Text(country.code).foregroundColor(.gray)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search country")
            .navigationTitle("Select Country")
            .navigationBarItems(leading: Button("Cancel") { showCountryPicker = false })
        }
    }

    // Filtered countries for search
    var filteredCountries: [Country] {
        searchText.isEmpty ? countries : countries.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.code.contains(searchText)
        }
    }
}
