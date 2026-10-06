//
//  AboutUsView.swift
//  DonasyONApp
//
//  Created by Yusei on 12/8/25.
//


import SwiftUI

// MARK: - 1. About Us View
struct AboutUsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        SimpleDetailLayout(title: "About Us") {
            VStack(spacing: 20) {
                Image("applogo")
                    .resizable().scaledToFit().frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 10)
                
                Text("DonasyON")
                    .font(.custom(appFont, size: 28)).fontWeight(.bold)
                    .foregroundColor(.appGreen)
                
                Text("Version 1.0.0")
                    .font(.caption).foregroundColor(.gray)
                
                Text("DonasyON is a Philippine-based platform dedicated to connecting generous hearts with those in need. Our mission is to make donating simple, transparent, and impactful through the power of technology and community spirit (Bayanihan).")
                    .font(.custom(appFont, size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.top, 10)
                    .lineSpacing(5)
                
                Spacer()
                
                Text("© 2025 DonasyON Philippines.\nAll rights reserved.")
                    .font(.caption).multilineTextAlignment(.center).foregroundColor(.gray)
            }
            .padding()
        }
    }
}

// MARK: - 2. Terms & Conditions View
struct TermsView: View {
    var body: some View {
        SimpleDetailLayout(title: "Terms and Conditions") {
            ScrollView {
                Text("""
                1. Introduction
                Welcome to DonasyON. By using our app, you agree to these terms.

                2. Donations
                All donations made through the app are voluntary. We ensure that funds reach the verified organizations listed on our platform.

                3. User Conduct
                Users must provide accurate information and avoid fraudulent activities. DonasyON reserves the right to ban accounts violating these rules.

                4. Limitation of Liability
                DonasyON acts as a bridge between donors and beneficiaries. We are not liable for the operational management of the third-party charities listed.
                
                (This is a placeholder for the full legal text.)
                """)
                .font(.custom(appFont, size: 15))
                .lineSpacing(6)
                .padding()
            }
        }
    }
}

// MARK: - 3. Privacy Statement View
struct PrivacyView: View {
    var body: some View {
        SimpleDetailLayout(title: "Privacy Statement") {
            ScrollView {
                Text("""
                Data Protection
                We take your privacy seriously. This policy explains how we collect, use, and protect your personal information.

                Information We Collect
                - Profile information (Name, Email, Photo)
                - Transaction history (for transparency)
                
                How We Use Data
                Your data is used solely to facilitate donations, verify identity, and improve app experience. We do not sell your data to third parties.
                
                Security
                We use industry-standard encryption to protect your payment and personal details.
                """)
                .font(.custom(appFont, size: 15))
                .lineSpacing(6)
                .padding()
            }
        }
    }
}

// MARK: - 4. FAQs View
struct FAQsView: View {
    var body: some View {
        SimpleDetailLayout(title: "FAQs") {
            ScrollView {
                VStack(spacing: 15) {
                    FAQRow(question: "How do I donate?", answer: "Select a charity from the Home screen, click 'Donate Now', choose your amount, and select a payment method.")
                    FAQRow(question: "Is my payment secure?", answer: "Yes. We use secure payment gateways (GCash, PayMaya, Cards) to ensure your financial safety.")
                    FAQRow(question: "Are the charities verified?", answer: "Absolutely. Every organization listed on DonasyON goes through a strict verification process.")
                    FAQRow(question: "Can I donate anonymously?", answer: "Yes, you can choose to hide your name from the public leaderboard in your settings.")
                }
                .padding()
            }
        }
    }
}

struct FAQRow: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(question).font(.custom(appFont, size: 16)).fontWeight(.semibold).foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(.gray)
                }
            }
            if isExpanded {
                Text(answer)
                    .font(.custom(appFont, size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
            Divider().padding(.top, 10)
        }
    }
}

// MARK: - 5. Help & Support View
struct HelpSupportView: View {
    var body: some View {
        SimpleDetailLayout(title: "Help & Support") {
            VStack(spacing: 20) {
                SupportOption(icon: "envelope.fill", title: "Email Us", subtitle: "support@donasyon.ph")
                SupportOption(icon: "phone.fill", title: "Call Us", subtitle: "(02) 8-7000-HELP")
                SupportOption(icon: "message.fill", title: "Live Chat", subtitle: "Available 8am - 5pm")
                Spacer()
            }
            .padding()
        }
    }
}

struct SupportOption: View {
    let icon: String, title: String, subtitle: String
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.appGreen)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(title).font(.custom(appFont, size: 16)).fontWeight(.bold)
                Text(subtitle).font(.custom(appFont, size: 14)).foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "arrow.up.right").foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - 6. Region & Language View
struct RegionLanguageView: View {
    @State private var selectedLanguage = "English"
    
    var body: some View {
        SimpleDetailLayout(title: "Region & Language") {
            List {
                Section(header: Text("Language")) {
                    LanguageRow(name: "English", selected: $selectedLanguage)
                    LanguageRow(name: "Filipino (Tagalog)", selected: $selectedLanguage)
                    LanguageRow(name: "Cebuano (Bisaya)", selected: $selectedLanguage)
                }
                
                Section(header: Text("Region")) {
                    HStack {
                        Text("Country")
                        Spacer()
                        Text("Philippines 🇵🇭").foregroundColor(.gray)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

struct LanguageRow: View {
    let name: String
    @Binding var selected: String
    var body: some View {
        Button(action: { selected = name }) {
            HStack {
                Text(name).foregroundColor(.black)
                Spacer()
                if selected == name {
                    Image(systemName: "checkmark").foregroundColor(.appGreen)
                }
            }
        }
    }
}

// MARK: - Generic Layout Wrapper

struct SimpleDetailLayout<Content: View>: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.bold)).foregroundColor(.black)
                            .padding(10).background(Color.white).clipShape(Circle())
                    }
                    Spacer()
                    Text(title).font(.custom(appFont, size: 20)).fontWeight(.bold)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                content
            }
        }
        .navigationBarHidden(true)
        .hideTabBar() 
    }
}
