import SwiftUI
import PhotosUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class UserProfileViewModel: ObservableObject {

    @Published var userName: String = "User"
    @Published var userEmail: String = ""
    @Published var selectedImage: Image?
    @Published var bio: String = "Digital Good Samaritan 🫶"
    @Published var birthDate: Date = Date()
    @Published var gender: String = "Male"
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet { Task { await loadImage(from: selectedPhotoItem) } }
    }
    @Published var errorMessage: String?
    
    @Published var userPoints: Int = 0
    @Published var rankPoints: Int = 0
    
    // NEW: Transactions List
    @Published var transactions: [WalletTransaction] = []
    
    
    private var selectedUIImage: UIImage?
    private var db = Firestore.firestore()

    // MARK: - Rank Logic
    var currentRank: RankItem { return RankItem.getRank(for: rankPoints) }
    
    var rankProgress: Double {
        let rank = currentRank
        guard let nextThreshold = RankItem.getNextRankThreshold(for: rank) else { return 1.0 }
        let currentLevelStart = rank.threshold
        let pointsInCurrentLevel = rankPoints - currentLevelStart
        let pointsNeededForNextLevel = nextThreshold - currentLevelStart
        if pointsNeededForNextLevel == 0 { return 1.0 }
        return Double(pointsInCurrentLevel) / Double(pointsNeededForNextLevel)
    }

    enum VerificationStatus: String, Codable { case unverified, pending, verified }
    @Published var verificationStatus: VerificationStatus = .unverified
    func submitVerification() { self.verificationStatus = .pending }
    func debugForceVerify() { self.verificationStatus = .verified }

    @MainActor
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                self.selectedImage = Image(uiImage: uiImage)
                self.selectedUIImage = uiImage
            }
        } catch { print("Error loading image: \(error.localizedDescription)") }
    }

    @MainActor
    func fetchUserProfile(userId: String) async {
        let docRef = db.collection("users").document(userId)
        self.errorMessage = nil
        self.selectedImage = nil
        self.selectedUIImage = nil
        
        print("Fetching profile for user: \(userId)")
        
        //NEW: Fetch Transactions
        fetchTransactions(userId: userId)
       
        
        do {
            let documentSnapshot = try await docRef.getDocument()
            if documentSnapshot.exists, let data = documentSnapshot.data() {
                self.userName = data["userName"] as? String ?? "User"
                self.userEmail = data["email"] as? String ?? ""
                self.bio = data["bio"] as? String ?? "Digital Good Samaritan 🫶"
                self.birthDate = (data["birthDate"] as? Timestamp)?.dateValue() ?? Date()
                self.gender = data["gender"] as? String ?? "Male"
                self.userPoints = data["points"] as? Int ?? 0
                self.rankPoints = data["rankPoints"] as? Int ?? 0
                
                if let base64Image = data["profileImage"] as? String,
                   let imageData = Data(base64Encoded: base64Image),
                   let uiImage = UIImage(data: imageData) {
                    self.selectedImage = Image(uiImage: uiImage)
                }
                if let statusString = data["verificationStatus"] as? String,
                   let status = VerificationStatus(rawValue: statusString) {
                    self.verificationStatus = status
                }
            } else {
                self.userName = "User"
                self.userEmail = Auth.auth().currentUser?.email ?? ""
                self.selectedImage = nil
                self.userPoints = 0
                self.rankPoints = 0
                self.verificationStatus = .unverified
            }
        } catch {
            print("Error fetching user profile: \(error.localizedDescription)")
        }
    }
    
    //NEW: Fetch Transactions Listener ---
    func fetchTransactions(userId: String) {
        db.collection("users").document(userId).collection("transactions")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.transactions = documents.compactMap { try? $0.data(as: WalletTransaction.self) }
            }
    }
    

    @MainActor
    func saveUserProfile(userId: String, firstName: String, lastName: String, middleName: String?) async {
        let docRef = db.collection("users").document(userId)
        self.errorMessage = nil
        var profileData: [String: Any] = [
            "userId": userId, "userName": self.userName, "email": self.userEmail,
            "firstName": firstName, "lastName": lastName, "middleName": middleName ?? "",
            "bio": self.bio, "birthDate": Timestamp(date: self.birthDate),
            "gender": self.gender, "verificationStatus": self.verificationStatus.rawValue
        ]
        if let image = selectedUIImage, let imageData = image.jpegData(compressionQuality: 0.3) {
            profileData["profileImage"] = imageData.base64EncodedString()
        }
        do { try await docRef.setData(profileData, merge: true) } catch { self.errorMessage = "Error saving: \(error.localizedDescription)" }
    }

    @MainActor
    func clearData() {
        self.userName = "User"; self.userEmail = ""; self.selectedImage = nil; self.selectedUIImage = nil
        self.bio = ""; self.userPoints = 0; self.rankPoints = 0; self.birthDate = Date(); self.gender = "Male"
        self.selectedPhotoItem = nil; self.errorMessage = nil; self.verificationStatus = .unverified
        self.transactions = [] // Clear transactions
    }
    
    @MainActor
    func checkIfUsernameExists(username: String) async -> Bool {
        guard !username.isEmpty else { return false }
        do {
            let querySnapshot = try await db.collection("users").whereField("userName", isEqualTo: username).getDocuments()
            return !querySnapshot.documents.isEmpty
        } catch { return false }
    }
}
