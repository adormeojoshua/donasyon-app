import SwiftUI

// MARK: - Global Colors & Font
extension Color {
    static let appGreen = Color(red: 69/255, green: 143/255, blue: 90/255)
    static let addPayment_Background = Color(red: 0.94, green: 0.94, blue: 0.95)
    static let addPayment_ButtonColor = Color(red: 0.35, green: 0.42, blue: 0.33)
    static let addPayment_HandleColor = Color(red: 0.65, green: 0.76, blue: 0.65)
    static let addPayment_SubtitleGray = Color(white: 0.5)
}
let appFont = "Helvetica Neue"

// MARK: - Custom Input Style
struct CustomInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .font(.custom(appFont, size: 16))
    }
}

// MARK: - Reusable Components

struct SideMenuRow: View {
    let icon: String
    let title: String
    let titleColor = Color(red: 0.35, green: 0.42, blue: 0.33)

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.system(size: 20, weight: .medium)).frame(width: 25).foregroundColor(titleColor)
            Text(title).font(.custom(appFont, size: 18)).foregroundColor(.black)
        }
    }
}

// --- UPDATED DONATION POINTS CARD ---
struct DonationPointsCard: View {
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    
    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 30) {
                    HStack(spacing: 0) { Text("Rank Points").font(.custom(appFont, size: 18)).fontWeight(.bold) }
                    ZStack {
                        // Background Circle
                        Circle().stroke(lineWidth: 12).opacity(0.2).foregroundColor(Color.appGreen.opacity(0.4))
                        
                        // Foreground Progress Circle (Uses Rank Progress)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(userProfileViewModel.rankProgress))
                            .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Color.appGreen)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.linear(duration: 1.0), value: userProfileViewModel.rankProgress)
                        
                        VStack(spacing: 2) {
                            // --- SHOW RANK POINTS HERE ---
                            Text("\(userProfileViewModel.rankPoints)")
                                .font(.custom(appFont, size: 30)).fontWeight(.bold).minimumScaleFactor(0.5)
                            Text("Points").font(.custom(appFont, size: 12)).fontWeight(.medium)
                        }
                    }.frame(width: 140, height: 140)
                }.padding(.leading, 40)
                
                Spacer()
                
                VStack(spacing: 20) {
                    // Dynamic Image
                    Image(userProfileViewModel.currentRank.imageName)
                        .resizable().scaledToFit().frame(height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
                    
                    // Dynamic Rank Name
                    Text(userProfileViewModel.currentRank.name)
                        .font(.custom(appFont, size: 14)).fontWeight(.medium).multilineTextAlignment(.center)
                }.padding(.trailing, 20)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 35)
            .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.appGreen.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            NavigationLink(destination: RankingsInfoView().hideTabBar()) {
                Image(systemName: "info.circle").font(.system(size: 24, weight: .medium)).foregroundColor(.gray.opacity(0.8)).padding(15)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }
}

// --- CHARITY CARD ---
struct CharityCard: View {
    let charity: Charity
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                charity.image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                
                // Category Badge
                Text(charity.category.rawValue)
                    .font(.caption).fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                    .padding(10)
            }
            .clipShape(
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 16, bottomLeading: 0, bottomTrailing: 0, topTrailing: 16))
            )
            
            HStack {
                Text(charity.title).font(.custom(appFont, size: 16)).fontWeight(.medium).lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary.opacity(0.7))
                    .frame(width: 30, height: 30)
                    .background(Color(UIColor.systemGray5))
                    .clipShape(Circle())
            }
            .padding()
            .background(Color.white)
            .clipShape(
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 16, bottomTrailing: 16, topTrailing: 0))
            )
        }
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// --- Other Components ---
struct TimeframePicker: View {
    @Binding var selection: String
    let timeframes = ["Weekly", "All time"]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(timeframes, id: \.self) { timeframe in
                Text(timeframe).font(.custom(appFont, size: 16)).fontWeight(.bold).padding(.vertical, 14).frame(maxWidth: .infinity)
                    .background(ZStack { if selection == timeframe { Capsule().fill(Color(red: 0.84, green: 0.90, blue: 0.82)).shadow(color: .black.opacity(0.2), radius: 4, y: 2) } })
                    .foregroundColor(selection == timeframe ? .black : .white)
                    .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { selection = timeframe } }
            }
        }.padding(6).background(Color(red: 0.35, green: 0.42, blue: 0.33)).clipShape(Capsule()).padding(.horizontal)
    }
}

struct RewardCardView: View {
    let reward: RewardItem
    var body: some View {
        VStack(alignment: .leading) {
            Image(reward.imageName).resizable().scaledToFit().frame(height: 120).frame(maxWidth: .infinity).padding(.top)
            VStack(alignment: .leading, spacing: 6) {
                Text(reward.title).font(.custom(appFont, size: 16)).fontWeight(.bold).lineLimit(2).minimumScaleFactor(0.9).frame(height: 40, alignment: .top)
                HStack {
                    Text("\(reward.points.formatted()) points").font(.custom(appFont, size: 14)).foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(.primary.opacity(0.7)).frame(width: 28, height: 28).background(Color(UIColor.systemGray6)).clipShape(Circle())
                }
            }.padding([.horizontal, .bottom])
        }.background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.white)).shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct AmountBox: View {
    var title: String; var isSelected: Bool = false; var appGreen: Color = .appGreen
    var body: some View {
        Text(title).font(.custom(appFont, size: 18)).fontWeight(.bold).foregroundColor(isSelected ? .black : .gray).frame(maxWidth: .infinity, minHeight: 80).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(isSelected ? appGreen : Color.gray.opacity(0.3), lineWidth: 2)).shadow(color: isSelected ? appGreen.opacity(0.4) : .clear, radius: 5)
    }
}

struct PaymentBox: View {
    var title: String; var logo: String; var isSelected: Bool = false; var appGreen: Color = .appGreen
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "circle.inset.filled" : "circle").foregroundColor(appGreen)
            Text(title).font(.custom(appFont, size: 16)).fontWeight(.semibold).foregroundColor(.primary)
            Spacer()
            Image(logo).resizable().scaledToFit().frame(width: 32, height: 22)
        }.padding().background(Color.white).clipShape(RoundedRectangle(cornerRadius: 15)).overlay(RoundedRectangle(cornerRadius: 15).stroke(isSelected ? appGreen : Color.clear, lineWidth: 2)).shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct AddPaymentHeaderView: View {
    var dismissAction: () -> Void
    var body: some View {
        HStack {
            Button(action: dismissAction) { Image(systemName: "chevron.left").font(.body.weight(.bold)).foregroundColor(.black).frame(width: 44, height: 44).background(Color.white).clipShape(Circle()) }
            Spacer(); Text("Add Payment").font(.custom(appFont, size: 20)).fontWeight(.bold).foregroundColor(Color.addPayment_ButtonColor); Spacer(); Color.clear.frame(width: 44, height: 44)
        }
    }
}

struct AddPaymentOptionsListView: View {
    @Binding var selectedPaymentMethod: String
    var body: some View {
        VStack(spacing: 12) {
            PaymentMethodRow(logo: AnyView(MastercardLogo()), title: "Mastercard", subtitle: "**** **** **** 323", isSelected: selectedPaymentMethod == "Mastercard").onTapGesture { selectedPaymentMethod = "Mastercard" }
            PaymentMethodRow(logo: AnyView(VisaLogo()), title: "Visa", subtitle: "Not registered", isSelected: selectedPaymentMethod == "Visa").onTapGesture { selectedPaymentMethod = "Visa" }
            PaymentMethodRow(logo: AnyView(PaypalLogo()), title: "Paypal", subtitle: "Not registered", isSelected: selectedPaymentMethod == "Paypal").onTapGesture { selectedPaymentMethod = "Paypal" }
        }.padding([.horizontal, .bottom])
    }
}

struct PaymentMethodRow: View {
    let logo: AnyView; let title: String; let subtitle: String; let isSelected: Bool
    var body: some View {
        HStack(spacing: 15) {
            logo.scaledToFit().frame(width: 45, height: 30, alignment: .leading)
            VStack(alignment: .leading) { Text(title).font(.custom(appFont, size: 17)).fontWeight(.semibold); Text(subtitle).font(.custom(appFont, size: 14)).foregroundColor(.addPayment_SubtitleGray) }
            Spacer(); CheckboxView(isSelected: isSelected)
        }.padding().background(Color.white).cornerRadius(15).overlay(RoundedRectangle(cornerRadius: 15).stroke(isSelected ? Color.addPayment_ButtonColor.opacity(0.5) : Color.clear, lineWidth: 1.5)).contentShape(Rectangle())
    }
}

struct CheckboxView: View {
    let isSelected: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(isSelected ? Color.clear : Color.gray.opacity(0.4), lineWidth: 2).background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(isSelected ? Color.addPayment_ButtonColor : Color.clear))
            if isSelected { Image(systemName: "checkmark").font(.caption.weight(.bold)).foregroundColor(.white) }
        }.frame(width: 28, height: 28)
    }
}

struct AddPaymentAddNewButton: View {
    var body: some View {
        Button(action: { print("Add New Payment Tapped") }) {
            Text("Add new").font(.custom(appFont, size: 18)).fontWeight(.bold).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.addPayment_ButtonColor).cornerRadius(25)
        }.padding(.horizontal).padding(.bottom, 10)
    }
}

struct AddPaymentMethodView: View {
    @State private var selectedPaymentMethod: String = "Visa"
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.addPayment_Background.ignoresSafeArea()
            VStack(spacing: 20) {
                AddPaymentHeaderView(dismissAction: { dismiss() })
                VStack(spacing: 16) { Capsule().fill(Color.addPayment_HandleColor).frame(width: 40, height: 5).padding(.top, 10); AddPaymentOptionsListView(selectedPaymentMethod: $selectedPaymentMethod) }.background(Color.white).cornerRadius(30).shadow(color: Color.black.opacity(0.08), radius: 15, y: 5)
                Spacer()
            }.padding(.horizontal)
        }.safeAreaInset(edge: .bottom) { AddPaymentAddNewButton() }
    }
}

struct MastercardLogo: View { var body: some View { ZStack { Circle().fill(Color.red.opacity(0.8)).frame(width: 25); Circle().fill(Color.orange.opacity(0.8)).frame(width: 25).offset(x: 15) } } }
struct VisaLogo: View { var body: some View { Text("VISA").font(.custom("HelveticaNeue-Bold", size: 20)).foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.7)) } }
struct PaypalLogo: View { var body: some View { Text("PayPal").font(.custom("HelveticaNeue-Bold", size: 18)).italic().foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.7)) } }

// MARK: - Tab Bar Visibility Helpers
struct HideTabBarModifier: ViewModifier {
    @EnvironmentObject var tabBarManager: TabBarManager
    func body(content: Content) -> some View { content.onAppear { withAnimation { tabBarManager.isVisible = false } } }
}
struct ShowTabBarModifier: ViewModifier {
    @EnvironmentObject var tabBarManager: TabBarManager
    func body(content: Content) -> some View { content.onAppear { withAnimation { tabBarManager.isVisible = true } } }
}
extension View {
    func hideTabBar() -> some View { self.modifier(HideTabBarModifier()) }
    func showTabBar() -> some View { self.modifier(ShowTabBarModifier()) }
}
