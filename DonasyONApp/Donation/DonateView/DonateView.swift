import SwiftUI

struct DonateView: View {
    @Environment(\.dismiss) var dismiss
    
    // Connect to Tab Manager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    let charity: Charity
    
    @State private var selectedAmount: Int? = 1000
    @State private var customAmount: String = ""
    @State private var selectedPayment: String = "G-Cash"
    @State private var isShowingAddPaymentSheet = false
    @State private var navigateToProcessing = false
    
    @State private var showConfirmDonationAlert = false
    @State private var showLimitAlert = false
    
    let amounts = [1000, 2500, 5000, 10000]
    
    private var finalAmount: Int { selectedAmount ?? (Int(customAmount) ?? 0) }
    private var remainingNeeded: Double { max(0, charity.targetAmount - charity.currentAmount) }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Header
                ZStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left").font(.system(size: 18, weight: .bold)).foregroundColor(.black).padding(10).background(Color.white.opacity(0.85)).clipShape(Circle()).shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                        }
                        Spacer()
                    }
                    Text("Donate").font(.custom(appFont, size: 22)).fontWeight(.bold).foregroundColor(.appGreen)
                }.padding(.top, 10)
               
                // Charity card
                HStack {
                    charity.image.resizable().scaledToFill().frame(width: 100, height: 60).clipShape(RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(charity.title).font(.custom(appFont, size: 16)).fontWeight(.semibold).foregroundColor(.black).lineLimit(2)
                        Text("Needed: ₱\(Int(remainingNeeded))").font(.caption).fontWeight(.bold).foregroundColor(.orange)
                    }
                    Spacer()
                }.padding().background(Color.white).clipShape(RoundedRectangle(cornerRadius: 15)).shadow(color: .black.opacity(0.05), radius: 5)
               
                // Select amount
                Text("Select amount").font(.custom(appFont, size: 18)).fontWeight(.semibold).foregroundColor(.appGreen)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(amounts, id: \.self) { amount in
                        Button(action: { selectedAmount = amount; customAmount = "" }) {
                            AmountBox(title: "₱\(amount)", isSelected: selectedAmount == amount)
                        }.opacity(Double(amount) > remainingNeeded ? 0.5 : 1.0)
                    }
                }
               
                Text("or").font(.custom(appFont, size: 14)).foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .center)
               
                // Custom Amount Input
                TextField("Enter price manually", text: $customAmount).keyboardType(.numberPad).padding().background(Color(UIColor.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: customAmount) { oldVal, newVal in
                        let filtered = newVal.filter { "0123456789".contains($0) }
                        if filtered != newVal { self.customAmount = filtered }
                        if !filtered.isEmpty { selectedAmount = nil }
                    }
                    .font(.custom(appFont, size: 16))
               
                // Payment Method
                HStack { Text("Select payment").font(.custom(appFont, size: 18)).fontWeight(.semibold).foregroundColor(.appGreen); Spacer(); Button("+ Add Payment method") { isShowingAddPaymentSheet = true }.font(.custom(appFont, size: 14)).foregroundColor(.appGreen) }
                VStack(spacing: 12) {
                    Button(action: { selectedPayment = "G-Cash" }) { PaymentBox(title: "G-Cash", logo: "gcashlogo", isSelected: selectedPayment == "G-Cash") }
                    Button(action: { selectedPayment = "Card" }) { PaymentBox(title: "Card", logo: "mastercardlogo", isSelected: selectedPayment == "Card") }
                }
               
                Spacer(minLength: 15)
               
                // Donate Now Button
                Button(action: {
                    guard finalAmount > 0 else { return }
                    if Double(finalAmount) > remainingNeeded { showLimitAlert = true; return }
                    showConfirmDonationAlert = true
                }) {
                    Text("Donate Now").font(.custom(appFont, size: 18)).fontWeight(.bold).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.appGreen).clipShape(RoundedRectangle(cornerRadius: 30))
                }.disabled(finalAmount <= 0)
            }
            .padding().font(.custom(appFont, size: 16))
        }
        .sheet(isPresented: $isShowingAddPaymentSheet) { AddPaymentMethodView() }
        .navigationBarBackButtonHidden(true).toolbar(.hidden, for: .navigationBar)
        
        .navigationDestination(isPresented: $navigateToProcessing) {
            PaymentProcessingView(
                donationAmount: finalAmount,
                charity: charity,
                onDone: {
                    // --- THE FIX: Call resetHome() ---
                    print("Donation complete. Resetting home.")
                    tabBarManager.resetHome()
                    // ---------------------------------
                }
            )
        }
        .hideTabBar()
        
        // Alerts
        .alert("Confirm Donation", isPresented: $showConfirmDonationAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") { navigateToProcessing = true }
        } message: { Text("Are you sure you want to donate ₱\(finalAmount) to \(charity.title)?") }
        .alert("Amount Too High", isPresented: $showLimitAlert) { Button("OK", role: .cancel) { } } message: { Text("This campaign only needs ₱\(Int(remainingNeeded)) more.") }
    }
}

// MARK: - Helper Views
struct PaymentProcessingView: View {
    enum PaymentState { case processing, successful }
    
    let donationAmount: Int
    let charity: Charity
    var onDone: () -> Void
    
    @State private var currentState: PaymentState = .processing
    @StateObject private var charityViewModel = CharityViewModel()
    // --- NEW: Need Auth VM to get User ID ---
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        ZStack {
            switch currentState {
            case .processing:
                ProcessingAnimationView().transition(.opacity)
            case .successful:
                PaymentSuccessView(donationAmount: donationAmount, onDone: onDone).transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    // PASS USER ID HERE 
                    if let userId = authViewModel.userSession?.uid {
                        charityViewModel.addDonation(to: charity, amount: Double(donationAmount), userId: userId)
                    }
                    currentState = .successful
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .hideTabBar()
    }
}

struct ProcessingAnimationView: View {
    @State private var isAnimating = false
    let count: Int = 8
    var body: some View {
        VStack(spacing: 20) {
            ZStack { ForEach(0..<count, id: \.self) { index in Capsule().trim(from: 0, to: 0.5).stroke(Color.appGreen, lineWidth: 4).frame(width: 50, height: 50).rotationEffect(.degrees(Double(index) / Double(count) * 360)).opacity(isAnimating ? 1 - Double(index) / Double(count) : 1) } }
            .rotationEffect(isAnimating ? .degrees(360) : .degrees(0))
            .onAppear { withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) { isAnimating = true } }
            Text("Your kindness is on its way!").font(.custom(appFont, size: 18)).foregroundColor(.gray)
        }
    }
}

struct PaymentSuccessView: View {
    let donationAmount: Int
    var onDone: () -> Void
    var body: some View {
        VStack {
            HStack { Spacer(); Button(action: { print("Print") }) { Image(systemName: "printer").font(.title2).foregroundColor(.black).frame(width: 44, height: 44) } }.padding()
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 70)).foregroundColor(.appGreen).padding(10).background(Color.appGreen.opacity(0.1)).clipShape(Circle())
                Text("Payment successful").font(.custom(appFont, size: 28)).fontWeight(.bold)
                Text("Successfully paid ₱\(donationAmount)").font(.custom(appFont, size: 16)).foregroundColor(.gray)
            }
            VStack(alignment: .leading, spacing: 16) {
                Text("Transaction Details").font(.custom(appFont, size: 20)).fontWeight(.bold)
                TransactionDetailRow(label: "Transaction ID", value: String(Int.random(in: 10000000...99999999)))
                TransactionDetailRow(label: "Date", value: Date().formatted(date: .abbreviated, time: .shortened))
                TransactionDetailRow(label: "Type of Transaction", value: "GCash")
                TransactionDetailRow(label: "Amount Donated", value: "₱\(donationAmount)")
            }.padding().background(Color.white).cornerRadius(15).padding()
            Spacer()
            
            // CONFIRM BUTTON
            Button(action: { onDone() }) {
                Text("Confirm").font(.custom(appFont, size: 18)).fontWeight(.bold).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.addPayment_ButtonColor).cornerRadius(25)
            }.buttonStyle(.plain).padding()
        }.background(Color(UIColor.systemGray6).ignoresSafeArea()).navigationBarBackButtonHidden(true).hideTabBar()
    }
}

struct TransactionDetailRow: View {
    let label: String; let value: String
    var body: some View { HStack { Text(label).font(.custom(appFont, size: 15)).foregroundColor(.gray); Spacer(); Text(value).font(.custom(appFont, size: 15)).fontWeight(.medium) } }
}

struct DonateView_Previews: PreviewProvider {
    static var previews: some View { NavigationStack { DonateView(charity: Charity(title: "Test", description: "", targetAmount: 10000, currentAmount: 5000, category: .health, organizerName: "Org")) } }
}
