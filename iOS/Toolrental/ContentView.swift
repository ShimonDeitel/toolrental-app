import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: RentalItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.toolName)
                                    .font(Theme.bodyFont.weight(.semibold))
                                Text("\(item.vendor)")
                                    .font(Theme.captionFont)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityIdentifier("item_row_\(item.id.uuidString)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Toolrental")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settings_gear_button")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("add_item_button")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddItemView { item in
                    store.add(item)
                }
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item, onSave: { updated in
                    store.update(updated)
                }, onDelete: {
                    store.delete(item)
                })
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var toolName: String = ""
    @State private var vendor: String = ""
    @State private var costText: String = ""
    @State private var returnDate: String = ""
    var onSave: (RentalItem) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("New Rental") {
                    TextField("Toolname", text: $toolName)
                        .accessibilityIdentifier("add_toolName_field")
                    TextField("Vendor", text: $vendor)
                        .accessibilityIdentifier("add_vendor_field")
                    TextField("Cost", text: $costText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("add_cost_field")
                    TextField("Returndate", text: $returnDate)
                        .accessibilityIdentifier("add_returnDate_field")
                }
            }
            .background(
                Color.clear.contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
            .navigationTitle("Add Rental")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("add_cancel_button")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = RentalItem(
                        toolName: toolName,
                        vendor: vendor,
                        cost: Double(costText) ?? 0,
                        returnDate: returnDate
                        )
                        onSave(item)
                        dismiss()
                    }
                    .accessibilityIdentifier("add_save_button")
                }
            }
        }
    }
}

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State var item: RentalItem
    var onSave: (RentalItem) -> Void
    var onDelete: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Rental") {
                    Text(item.toolName)
                }
                Section {
                    Button("Delete", role: .destructive) {
                        onDelete()
                        dismiss()
                    }
                    .accessibilityIdentifier("edit_delete_button")
                }
            }
            .navigationTitle("Edit Rental")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("edit_close_button")
                }
            }
        }
    }
}
