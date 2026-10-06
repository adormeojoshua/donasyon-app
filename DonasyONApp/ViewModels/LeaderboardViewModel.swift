import SwiftUI
import FirebaseFirestore

class LeaderboardViewModel: ObservableObject {
    @Published var topThree: [LeaderboardUser] = []
    @Published var otherUsers: [LeaderboardUser] = []
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    
    func fetchLeaderboard() {
        isLoading = true
        
        // Fetch all users, order by Rank Points (High to Low)
        db.collection("users")
            .order(by: "rankPoints", descending: true)
            .limit(to: 50)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No users found")
                    self.isLoading = false
                    return
                }
                
                var allUsers: [LeaderboardUser] = []
                
                for (index, doc) in documents.enumerated() {
                    let data = doc.data()
                    let name = data["userName"] as? String ?? "Unknown"
                    let points = data["rankPoints"] as? Int ?? 0
                    let imageString = data["profileImage"] as? String
                    
                    let user = LeaderboardUser(
                        id: doc.documentID,
                        name: name,
                        points: points,
                        rank: index + 1,
                        change: .same, 
                        base64Image: imageString
                    )
                    allUsers.append(user)
                }
                
                DispatchQueue.main.async {
                    if allUsers.count >= 3 {
                        self.topThree = Array(allUsers.prefix(3))
                        self.otherUsers = Array(allUsers.dropFirst(3))
                    } else {
                        self.topThree = allUsers
                        self.otherUsers = []
                    }
                    self.isLoading = false
                }
            }
    }
}
