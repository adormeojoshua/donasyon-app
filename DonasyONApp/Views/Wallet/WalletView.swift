import SwiftUI

struct WalletView: View {

    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
   
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 25) {
                
                // Header
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your Balance")
                        .font(.custom(appFont, size: 18))
                        .foregroundColor(.gray)
                    
                    // Hardcoded muna ang pera
                    Text("₱4,945.32")
                        .font(.custom(appFont, size: 42))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        WalletCardView(balance: "4,945.32", cardNumber: "8019", expiry: "10/28", cardColor: Color.appGreen)
                        WalletCardView(balance: "300.00", cardNumber: "1122", expiry: "12/29", cardColor: Color(red: 0.35, green: 0.35, blue: 0.45))
                    }
                    .padding(.horizontal)
                }
                
                // Actions
                HStack(spacing: 15) {
                    WalletActionButton(text: "Cash In")
                    WalletActionButton(text: "Send")
                    WalletActionButton(text: "Withdraw")
                }
                .padding(.horizontal)
                
                // MARK: - Transactions List (LIVE)
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Transactions").font(.custom(appFont, size: 22)).fontWeight(.bold)
                        Spacer()
                        Button("See All") { }.font(.custom(appFont, size: 16)).foregroundColor(.appGreen)
                    }
                    
                    if userProfileViewModel.transactions.isEmpty {
                        Text("No transactions yet.")
                            .font(.custom(appFont, size: 16))
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        VStack(spacing: 20) {
                            ForEach(userProfileViewModel.transactions) { transaction in
                                LiveTransactionRow(transaction: transaction)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .showTabBar()
    }
}

// MARK: - Helper: Live Transaction Row
struct LiveTransactionRow: View {
    let transaction: WalletTransaction
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon Logic
            Image(systemName: transaction.type == .donation ? "heart.circle.fill" : "arrow.down.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .foregroundColor(transaction.type == .donation ? .red : .green)
                .background((transaction.type == .donation ? Color.red : Color.green).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.custom(appFont, size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.custom(appFont, size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Negative for donation, Positive for cash in
            Text("\(transaction.amount < 0 ? "-" : "+")₱\(abs(Int(transaction.amount)))")
                .font(.custom(appFont, size: 16))
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}


struct WalletCardView: View {
    let balance: String; let cardNumber: String; let expiry: String; let cardColor: Color
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 25).fill(cardColor)
            Circle().fill(Color.white.opacity(0.1)).frame(width: 200, height: 200).offset(x: 120, y: 80)
            VStack(alignment: .leading) {
                HStack { VStack(alignment: .leading, spacing: 4) { Text("Card Balance").font(.custom(appFont, size: 14)).opacity(0.8); Text("₱\(balance)").font(.custom(appFont, size: 24)).fontWeight(.bold) }; Spacer(); Text("DonasyON").font(.custom(appFont, size: 18)).fontWeight(.heavy).italic() }
                Spacer()
                HStack(alignment: .bottom) { VStack(alignment: .leading, spacing: 6) { Text("**** **** **** \(cardNumber)").font(.custom("CourierNewPS-BoldMT", size: 18)).opacity(0.9); VStack(alignment: .leading, spacing: 2) { Text("Expiration Date").font(.caption).opacity(0.7); Text(expiry).font(.custom(appFont, size: 16)).fontWeight(.semibold) } }; Spacer(); Text("Active").font(.custom(appFont, size: 12)).fontWeight(.semibold).padding(.vertical, 6).padding(.horizontal, 12).background(Color.white.opacity(0.2)).clipShape(Capsule()) }
            }.padding(25).foregroundColor(.white)
        }.frame(width: 320, height: 200).shadow(color: cardColor.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

struct WalletActionButton: View {
    let text: String
    var body: some View {
        Button(action: {}) {
            Text(text).font(.custom(appFont, size: 16)).fontWeight(.semibold).foregroundColor(.black).frame(maxWidth: .infinity).padding(.vertical, 16).background(Color.white).cornerRadius(15).shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView().environmentObject(UserProfileViewModel())
    }
}
