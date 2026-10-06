import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Charity Categories
enum CharityCategory: String, CaseIterable, Codable, Hashable {
    case health = "Health"
    case clothes = "Clothes"
    case study = "Study"
    case food = "Food"
    
    var iconName: String {
        switch self {
        case .health: return "healthicon"
        case .clothes: return "clothesicon"
        case .study: return "study icon"
        case .food: return "foodicon"
        }
    }
}

// MARK: - Data Models

struct Charity: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let targetAmount: Double
    let currentAmount: Double
    let category: CharityCategory
    let organizerName: String
    var organizerUID: String?
    var base64Image: String?
    
    private var internalID: String = UUID().uuidString
    var uniqueID: String { return id ?? internalID }
    
    init(id: String? = nil, title: String, description: String, targetAmount: Double, currentAmount: Double, category: CharityCategory, organizerName: String, organizerUID: String? = nil, base64Image: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.category = category
        self.organizerName = organizerName
        self.organizerUID = organizerUID
        self.base64Image = base64Image
    }
    
    var image: Image {
        if let base64 = base64Image,
           let data = Data(base64Encoded: base64),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return Image(category.iconName)
    }
    
    static func == (lhs: Charity, rhs: Charity) -> Bool { return lhs.uniqueID == rhs.uniqueID }
    func hash(into hasher: inout Hasher) { hasher.combine(uniqueID) }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, targetAmount, currentAmount, category, organizerName, organizerUID, base64Image
    }
}

// --- NEW: WALLET TRANSACTION MODEL ---
struct WalletTransaction: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let title: String
    let subtitle: String
    let amount: Double
    let date: Date
    let type: TransactionType
    
    enum TransactionType: String, Codable {
        case donation
        case cashIn
    }
}
// -------------------------------------

struct LeaderboardUser: Identifiable, Hashable {
    let id: String
    let name: String
    let points: Int
    let rank: Int
    var change: RankChange
    var base64Image: String?
    
    enum RankChange { case up, down, same }
    
    var image: Image {
        if let base64 = base64Image, let data = Data(base64Encoded: base64), let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "person.crop.circle.fill")
    }
}

struct RankItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let pointsRange: String
    let imageName: String
    let threshold: Int
    
    static let allRanks: [RankItem] = [
        RankItem(name: "Bronze Donor", pointsRange: "0 - 99", imageName: "bronzet", threshold: 0),
        RankItem(name: "Silver Donor", pointsRange: "100 - 199", imageName: "silvert", threshold: 100),
        RankItem(name: "Gold Donor", pointsRange: "200 - 399", imageName: "goldt", threshold: 200),
        RankItem(name: "Diamond Donor", pointsRange: "400 - 599", imageName: "diamondt", threshold: 400),
        RankItem(name: "Platinum Donor", pointsRange: "600+ points", imageName: "platinumt", threshold: 600)
    ]
    
    static func getRank(for points: Int) -> RankItem {
        return allRanks.reversed().first { points >= $0.threshold } ?? allRanks[0]
    }
    
    static func getNextRankThreshold(for currentRank: RankItem) -> Int? {
        if let index = allRanks.firstIndex(of: currentRank), index + 1 < allRanks.count {
            return allRanks[index + 1].threshold
        }
        return nil
    }
}

struct RewardItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let points: Int
}

struct RedeemedItem: Identifiable {
    let id: UUID = UUID()
    let item: RewardItem
    let code: String
    let date: Date
}

struct Country: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String
}
