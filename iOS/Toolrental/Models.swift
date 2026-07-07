import Foundation

struct RentalItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var toolName: String
    var vendor: String
    var cost: Double
    var returnDate: String
    var dateAdded: Date = Date()
}
