import SwiftUI


struct VerifyPhoneView: View {
 
    var fullPhoneNumber: String
    let password: String
    let firstName: String
    let lastName: String
    let middleName: String?

    @Environment(\.dismiss) private var dismiss
    
    
    @State private var pin: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    
    @State private var goToWelcome = false
    
    let appFont = "Helvetica Neue"
    let appGreen = Color.appGreen

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {

            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium)).foregroundColor(.black)
                    .padding().background(Color(white: 0.9)).clipShape(Circle())
            }

            Text("Verify Phone Number")
                .font(.custom(appFont, size: 28)).fontWeight(.bold)
                .foregroundColor(.black)

            Text("Enter the 6-digit code sent to \n\(fullPhoneNumber)")
                .font(.custom(appFont, size: 16))
                .foregroundColor(.black.opacity(0.7))
                .padding(.top, -10)

         
            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $pin[index])
                        .keyboardType(.numberPad)
                        .frame(width: 50, height: 60)
                        .background(Color.white)
                        .cornerRadius(12)
                        .multilineTextAlignment(.center)
                        .font(.custom(appFont, size: 22).weight(.semibold))
                        .focused($focusedField, equals: index)
                        .tag(index)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == index ? appGreen : Color.gray.opacity(0.6), lineWidth: 1.5)
                        )
                        .onChange(of: pin[index]) { oldVal, newVal in
                            if newVal.count > 1 { pin[index] = String(newVal.prefix(1)) }
                            if !newVal.isEmpty && index < 5 { focusedField = index + 1 }
                            if newVal.isEmpty && oldVal.count == 1 && index > 0 { focusedField = index - 1 }
                            if index == 5 && !newVal.isEmpty && pin.allSatisfy({ !$0.isEmpty }) {
                                verifyCode()
                            }
                        }
                }
            }
            .padding(.top, 20)

            HStack {                 Text("Didn’t receive code?")
                    .font(.custom(appFont, size: 15))
                    .foregroundColor(.black.opacity(0.6))
                Button(action: { print("Pretending to resend code...") }) {
                    Text("Resend")
                        .font(.custom(appFont, size: 15))
                        .fontWeight(.semibold)
                        .foregroundColor(appGreen)
                }
            }
            .padding(.top, 10)

            Spacer()

            
            Button(action: verifyCode) {
                Text("Verify")
                    .font(.custom(appFont, size: 18)).fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(appGreen)
                    .cornerRadius(30)
            }
            .disabled(!isPinComplete())
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = 0
            }
        }
        
       
        .navigationDestination(isPresented: $goToWelcome) {
            WelcomeView(
                password: password,
                firstName: firstName,
                lastName: lastName,
                middleName: middleName
            )
            .navigationBarBackButtonHidden(true)
        }
    }

    func isPinComplete() -> Bool {
        return pin.joined().count == 6
    }

    func verifyCode() {
        guard isPinComplete() else { return }
        print("Pretending to verify code: \(pin.joined())")
        
        goToWelcome = true
    }
}
