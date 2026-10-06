import Foundation
import Combine
import FirebaseFirestore // Firestore needed
// import FirebaseFirestoreSwift // Removed
import FirebaseAuth      // Auth needed

class RewardsViewModel: ObservableObject {
    @Published var redeemedItems: [RedeemedItem] = []
    @Published var errorMessage: String?
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    @MainActor
    func redeem(item: RewardItem, code: String) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Error: No user logged in."
            return
        }
        self.errorMessage = nil
        // RedeemedItem initializer works because it now has a default ID
        let newItem = RedeemedItem(item: item, code: code, date: Date())

        // Optimistic UI update: Add locally first
        if !redeemedItems.contains(where: { $0.code == code && $0.item.title == item.title }) {
             redeemedItems.insert(newItem, at: 0)
        } else {
             print("Item already redeemed locally (or rapid tap). Firestore will handle consistency.")
        }


        // Save to Firestore
        let collectionRef = db.collection("users").document(userId).collection("redeemedItems")
        do {
            let data: [String: Any] = [
                "imageName": item.imageName,
                "title": item.title,
                "points": item.points,
                "code": code,
                "date": Timestamp(date: newItem.date) // Use Firestore Timestamp
            ]
            // Add the document to Firestore
            try await collectionRef.addDocument(data: data)
            print("Successfully saved redeemed item to Firestore for user \(userId)")
        } catch {
            // Handle Firestore save error
            self.errorMessage = "Error saving redeemed item: \(error.localizedDescription)"
            print(self.errorMessage!)
            // Revert the optimistic UI update if saving failed
            redeemedItems.removeAll { $0.id == newItem.id }
        }
    }

    // Fetch Redeemed Items Function
    @MainActor
    func fetchRedeemedItems(userId: String) {
        self.errorMessage = nil // Clear previous errors
        stopListening() // Ensure no lingering listeners
        print("Starting to fetch/listen for redeemed items for user \(userId)")

        // Reference the subcollection, ordered by date descending
        let collectionRef = db.collection("users").document(userId).collection("redeemedItems")
                                 .order(by: "date", descending: true)

        // Attach a snapshot listener for real-time updates
        listenerRegistration = collectionRef.addSnapshotListener { [weak self] (querySnapshot, error) in
             guard let self = self else { return } // Safely unwrap self

             // Handle listener errors
             if let error = error {
                 self.errorMessage = "Error fetching redeemed items: \(error.localizedDescription)"
                 print(self.errorMessage!)
                 // Optionally clear local items on persistent error?
                 // self.redeemedItems = []
                 return
             }

             // Check if documents snapshot exists
             guard let documents = querySnapshot?.documents else {
                 print("No redeemed item documents found for user \(userId)")
                 self.redeemedItems = [] // Clear local array if Firestore collection is empty
                 return
             }

             // Map Firestore documents to RedeemedItem array
             self.redeemedItems = documents.compactMap { doc -> RedeemedItem? in
                 let data = doc.data()
                 // Safely extract data using type casting
                 guard
                     let imageName = data["imageName"] as? String,
                     let title = data["title"] as? String,
                     let points = data["points"] as? Int,
                     let code = data["code"] as? String,
                     let timestamp = data["date"] as? Timestamp
                 else {
                     // Log error if decoding fails for a document
                     print("Error decoding redeemed item document \(doc.documentID): \(data)")
                     return nil
                 }
                 
                 
                 let rewardItemPart = RewardItem(imageName: imageName, title: title, points: points)
                 

                 // Create the RedeemedItem, using Firestore document ID
                 let docIdUUID = UUID(uuidString: doc.documentID) ?? UUID()
                 // ID is set automatically by RedeemedItem struct default
                 return RedeemedItem(item: rewardItemPart, code: code, date: timestamp.dateValue())
             }
             print("Successfully fetched/updated \(self.redeemedItems.count) redeemed items.") // Log success
         }
    }

    // Function to detach the Firestore listener
    func stopListening() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
            print("Stopped listening for redeemed items.")
        }
    }

     // Function to clear local data and stop listener (used on logout)
     @MainActor
     func clearData() {
         stopListening()
         self.redeemedItems = []
         self.errorMessage = nil 
         print("Redeemed items data cleared.")
     }
}

