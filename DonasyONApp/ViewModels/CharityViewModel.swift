import SwiftUI
import FirebaseFirestore

class CharityViewModel: ObservableObject {
    @Published var charities: [Charity] = []
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    func fetchCharities() {
        db.collection("charities").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            self.charities = documents.compactMap { try? $0.data(as: Charity.self) }
        }
    }
    
    func uploadCharity(title: String, description: String, targetAmount: Double, category: CharityCategory, organizer: String, organizerUID: String, image: UIImage?) {
        var imageString: String? = nil
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.3) {
            imageString = imageData.base64EncodedString()
        }
        
        let newCharity = Charity(
            id: nil, title: title, description: description, targetAmount: targetAmount, currentAmount: 0,
            category: category, organizerName: organizer, organizerUID: organizerUID, base64Image: imageString
        )
        
        do {
            try db.collection("charities").addDocument(from: newCharity)
        } catch {
            self.errorMessage = "Failed to upload."
        }
    }
    
    func deleteCharity(_ charity: Charity) {
        guard let id = charity.id else { return }
        db.collection("charities").document(id).delete()
    }
    
    //UPDATED: Save Transaction History
    func addDonation(to charity: Charity, amount: Double, userId: String) {
        guard let id = charity.id else { return }
        
        // Update Charity Amount
        db.collection("charities").document(id).updateData([
            "currentAmount": FieldValue.increment(amount)
        ])
        
        // Calculate Points
        let rewardPoints = Int((amount / 100) * 25)
        let baseRankPoints = 15
        let bonusRankPoints = Int(amount / 1500) * 15
        let totalRankPoints = baseRankPoints + bonusRankPoints
        
        // Update User Points
        if rewardPoints > 0 || totalRankPoints > 0 {
            db.collection("users").document(userId).updateData([
                "points": FieldValue.increment(Int64(rewardPoints)),
                "rankPoints": FieldValue.increment(Int64(totalRankPoints))
            ])
        }
        
        // NEW: Save Transaction Record ---
        let transaction = WalletTransaction(
            id: nil,
            title: "Donation to \(charity.title)",
            subtitle: charity.category.rawValue,
            amount: -amount, // Negative because money left wallet
            date: Date(),
            type: .donation
        )
        
        do {
            try db.collection("users").document(userId).collection("transactions").addDocument(from: transaction)
            print("Transaction saved!")
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
}
