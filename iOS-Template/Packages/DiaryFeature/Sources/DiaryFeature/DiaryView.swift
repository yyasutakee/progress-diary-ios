import SwiftUI
import UIKit

public struct DiaryView<Model: DiaryViewModel>: View {
    @ObservedObject public var model: Model
    @State private var addEntryHapticTrigger: Int = 0

    public init(model: Model) {
        self.model = model
        Self.configureRoundedNavigationTitleFont()
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
                presentAddEntrySheet()
            } label: {
                Image(systemName: "plus")
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .sensoryFeedback(.impact(weight: .light), trigger: addEntryHapticTrigger)
        }
    }

    private var addEntryBinding: Binding<Bool> {
        Binding(
            get: { model.isShowingAddEntry },
            set: { model.isShowingAddEntry = $0 }
        )
    }

    private func presentAddEntrySheet() {
        addEntryHapticTrigger += 1
        model.send(.addEntryTapped)
    }

    private static func configureRoundedNavigationTitleFont() {
        let navigationBarAppearance: UINavigationBar = UINavigationBar.appearance()
        navigationBarAppearance.titleTextAttributes = [
            .font: makeScaledRoundedFont(size: 17, weight: .semibold, textStyle: .headline)
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .font: makeScaledRoundedFont(size: 34, weight: .bold, textStyle: .largeTitle)
        ]
    }

    private static func makeScaledRoundedFont(
        size: CGFloat,
        weight: UIFont.Weight,
        textStyle: UIFont.TextStyle
    ) -> UIFont {
        let baseFont: UIFont = UIFont.systemFont(ofSize: size, weight: weight)
        let roundedDescriptor: UIFontDescriptor = baseFont.fontDescriptor.withDesign(.rounded) ?? baseFont.fontDescriptor
        let roundedFont: UIFont = UIFont(descriptor: roundedDescriptor, size: size)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: roundedFont)
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
    @FocusState private var isEntryFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What did you progress today?", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($isEntryFieldFocused)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelButton
                submitButton
            }
            .task {
                isEntryFieldFocused = true
            }
        }
    }

    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                model.isShowingAddEntry = false
            } label: {
                Text("Cancel")
                    .fixedSize()
                    .frame(minWidth: 60, minHeight: 44)
                    .contentShape(Rectangle())
            }
        }
    }

    private var submitButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                let trimmed: String = text.trimmingCharacters(in: .whitespaces)
                model.send(.entryTextSubmitted(trimmed))
            } label: {
                Text("Add")
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}
