import SwiftUI

struct RankRowView: View {
    let user: LeaderboardUser
   

    var body: some View {
        HStack(spacing: 15) {
            // Rank Number
            Text(String(format: "%02d", user.rank))
                .font(.custom(appFont, size: 16))
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .frame(width: 30)

            // User Profile Image
            user.image
                .resizable()
                .scaledToFill()
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))

            // User Name and Points
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.custom(appFont, size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                // Show Trophy Points (Rank Points)
                Text("\(user.points) Rank Points")
                    .font(.custom(appFont, size: 13))
                    .foregroundColor(.appGreen)
                    .fontWeight(.medium)
            }

            Spacer()

            // Rank Change Indicator
            switch user.change {
            case .up:
                Image(systemName: "arrowtriangle.up.fill")
                    .foregroundColor(.appGreen)
                    .font(.caption)
            case .down:
                Image(systemName: "arrowtriangle.down.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            case .same:
                Image(systemName: "minus")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

// Preview Provider
struct RankRowView_Previews: PreviewProvider {
    static var previews: some View {
        //
        let dummyUser = LeaderboardUser(
            id: "123",
            name: "Test User",
            points: 1500,
            rank: 4,
            change: .up,
            base64Image: nil
        )
        
        RankRowView(user: dummyUser)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
