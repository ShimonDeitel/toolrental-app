import XCTest
@testable import Toolrental

final class ToolrentalTests: XCTestCase {
    @MainActor
    func makeEmptyStore() -> Store {
        let store = Store()
        store.items = []
        return store
    }

    @MainActor
    func testAddIncreasesCount() {
        let store = makeEmptyStore()
        let item = RentalItem(toolName: "Test", vendor: "Test", cost: 1.0, returnDate: "Test")
        _ = store.add(item)
        XCTAssertEqual(store.items.count, 1)
    }

    @MainActor
    func testFreeLimitBlocksAdd() {
        let store = makeEmptyStore()
        for _ in 0..<Store.freeLimit {
            _ = store.add(RentalItem(toolName: "Test", vendor: "Test", cost: 1.0, returnDate: "Test"))
        }
        let result = store.add(RentalItem(toolName: "Test", vendor: "Test", cost: 1.0, returnDate: "Test"))
        XCTAssertFalse(result)
        XCTAssertEqual(store.items.count, Store.freeLimit)
    }

    @MainActor
    func testProBypassesFreeLimit() {
        let store = makeEmptyStore()
        store.isPro = true
        for _ in 0..<(Store.freeLimit + 5) {
            _ = store.add(RentalItem(toolName: "Test", vendor: "Test", cost: 1.0, returnDate: "Test"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit + 5)
    }

    @MainActor
    func testDeleteRemovesItem() {
        let store = makeEmptyStore()
        let item = RentalItem(toolName: "Test", vendor: "Test", cost: 1.0, returnDate: "Test")
        _ = store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    @MainActor
    func testDeleteAtOffsets() {
        let store = makeEmptyStore()
        _ = store.add(RentalItem(toolName: "Test", vendor: "Test", cost: 1.0, returnDate: "Test"))
        _ = store.add(RentalItem(toolName: "Test", vendor: "Test", cost: 1.0, returnDate: "Test"))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    @MainActor
    func testUpdateModifiesItem() {
        let store = makeEmptyStore()
        let item = RentalItem(toolName: "Test", vendor: "Test", cost: 1.0, returnDate: "Test")
        _ = store.add(item)
        var updated = item
        updated.toolName = "Updated"
        store.update(updated)
        XCTAssertEqual(store.items.first?.toolName, "Updated")
    }

    @MainActor
    func testCanAddMoreTrueWhenUnderLimit() {
        let store = makeEmptyStore()
        XCTAssertTrue(store.canAddMore)
    }
}
