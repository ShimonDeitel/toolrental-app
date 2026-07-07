import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [RentalItem] = []
    @Published var isPro: Bool = false

    static let freeLimit = 15

    private let fileName = "toolrental_items.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([RentalItem].self, from: data) else {
            items = [
        RentalItem(toolName: "Pressure Washer", vendor: "Home Depot Rental", cost: 45.0, returnDate: "2026-07-10"),
        RentalItem(toolName: "Tile Saw", vendor: "Sunbelt Rentals", cost: 65.0, returnDate: "2026-07-12"),
        RentalItem(toolName: "Ladder 24ft", vendor: "Local Hardware", cost: 20.0, returnDate: "2026-07-09")
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    @discardableResult
    func add(_ item: RentalItem) -> Bool {
        guard canAddMore else { return false }
        items.append(item)
        save()
        return true
    }

    func update(_ item: RentalItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: RentalItem) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }
}
