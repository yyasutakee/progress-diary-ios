import SwiftUI

public struct DiaryView<Model: DiaryViewModel>: View {
    @ObservedObject public var model: Model

    public init(model: Model) {
        self.model = model
    }

    public var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("Progress Diary")
                .toolbar { addEntryButton }
                .sheet(isPresented: addEntryBinding) {
                    AddEntrySheet(model: model)
                }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            heatmapSection
            entryList
        }
    }

    private var heatmapSection: some View {
        HeatmapView(activeDayKeys: model.activeDayKeys)
            .padding(.horizontal)
            .padding(.vertical, 8)
    }

    private var entryList: some View {
        List {
            ForEach(model.entries) { entry in
                DiaryEntryRow(item: entry)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
            .onDelete { indexSet in
                for index in indexSet {
                    model.send(.deleteEntry(model.entries[index].id))
                }
            }
        }
        .listStyle(.plain)
    }

    private var addEntryButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                model.send(.addEntryTapped)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
    }

    private var addEntryBinding: Binding<Bool> {
        Binding(
            get: { model.isShowingAddEntry },
            set: { model.isShowingAddEntry = $0 }
        )
    }
}

private struct DiaryEntryRow: View {
    let item: DiaryEntryItem

    var body: some View {
        HStack(alignment: .top) {
            Text(item.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(item.dateLabel)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct AddEntrySheet<Model: DiaryViewModel>: View {
    @ObservedObject var model: Model
    @State private var text: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What did you progress today?", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelButton
                submitButton
            }
        }
    }

    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                model.isShowingAddEntry = false
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        }
    }

    private var submitButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Add") {
                let trimmed: String = text.trimmingCharacters(in: .whitespaces)
                model.send(.entryTextSubmitted(trimmed))
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        }
    }
}
