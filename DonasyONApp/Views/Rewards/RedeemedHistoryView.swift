import SwiftUI

struct RedeemedHistoryView: View {
    @Environment(\.dismiss) var dismiss
    

    @EnvironmentObject var viewModel: RewardsViewModel
    

    
    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            // Header Background
            LinearGradient(gradient: Gradient(colors: [Color.appGreen, Color.appGreen.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .frame(height: 120)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Redemption History")
                        .font(.custom(appFont, size: 20).weight(.bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Balance Header
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // MARK: - List Content
                if viewModel.redeemedItems.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.3))
                        
                        Text("No Rewards Yet")
                            .font(.custom(appFont, size: 24).weight(.bold))
                            .foregroundColor(.gray)
                        
                        Text("Earn points by donating and redeem them for exclusive vouchers!")
                            .font(.custom(appFont, size: 16))
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach(viewModel.redeemedItems) { item in
                                TicketCouponView(redeemedItem: item)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .hideTabBar()
        .onAppear {
            
        }
    }
}

// MARK: - Rich Ticket Row View
struct TicketCouponView: View {
    let redeemedItem: RedeemedItem
    @State private var isCopied = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(alignment: .top, spacing: 15) {
                
                ZStack {
                    Color.gray.opacity(0.05)
                    Image(redeemedItem.item.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                }
                .frame(width: 80, height: 80)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(redeemedItem.item.title)
                        .font(.custom(appFont, size: 16).weight(.bold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    Text("\(redeemedItem.item.points.formatted()) PTS Used")
                        .font(.custom(appFont, size: 12).weight(.bold))
                        .foregroundColor(.appGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appGreen.opacity(0.1))
                        .cornerRadius(6)
                    
                    Spacer()
                }
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            
           
            ZStack {
                Color.white
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundColor(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                
              
                HStack {
                    Circle().fill(Color(UIColor.systemGroupedBackground)).frame(width: 20, height: 20).offset(x: -10)
                    Spacer()
                    Circle().fill(Color(UIColor.systemGroupedBackground)).frame(width: 20, height: 20).offset(x: 10)
                }
            }
            .frame(height: 20)
            
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Redeemed on")
                        .font(.caption).foregroundColor(.gray)
                    Text(redeemedItem.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.custom(appFont, size: 12).weight(.medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // Code Box
                Button(action: {
                    UIPasteboard.general.string = redeemedItem.code
                    withAnimation { isCopied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { isCopied = false }
                    }
                }) {
                    HStack(spacing: 8) {
                        if isCopied {
                            Image(systemName: "checkmark")
                            Text("Copied")
                        } else {
                            Text(redeemedItem.code)
                                .font(.system(.caption, design: .monospaced).weight(.bold))
                            Image(systemName: "doc.on.doc")
                        }
                    }
                    .font(.caption.weight(.bold))
                    .foregroundColor(isCopied ? .white : .black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(isCopied ? Color.appGreen : Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                            .foregroundColor(isCopied ? .clear : .gray.opacity(0.5))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// Dashed Line Shape Helper
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

// Preview
struct RedeemedHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemedHistoryView()
            .environmentObject(RewardsViewModel())
    }
}
