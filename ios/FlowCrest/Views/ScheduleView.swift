import SwiftUI
import SwiftData

struct ScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: ScheduleViewModel
    @Query(sort: \FocusBlock.startTime) private var allBlocks: [FocusBlock]

    var body: some View {
        List {
            if todayBlocks.isEmpty && !viewModel.showingAddBlock {
                ContentUnavailableView(
                    "No Focus Blocks",
                    systemImage: "calendar.badge.plus",
                    description: Text("Tap + to add a focus block or sync your calendar.")
                )
            } else {
                if !overdueBlocks.isEmpty {
                    Section("Overdue") {
                        ForEach(overdueBlocks) { block in
                            blockRow(block)
                        }
                    }
                }

                if !currentBlocks.isEmpty {
                    Section {
                        ForEach(currentBlocks) { block in
                            blockRow(block)
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.green)
                                .frame(width: 6, height: 6)
                            Text("Now")
                        }
                    }
                }

                if !laterBlocks.isEmpty {
                    Section("Later Today") {
                        ForEach(laterBlocks) { block in
                            blockRow(block)
                        }
                    }
                }

                if !completedBlocks.isEmpty {
                    Section("Completed") {
                        ForEach(completedBlocks) { block in
                            blockRow(block)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Schedule")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showingAddBlock = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddBlock) {
            AddFocusBlockSheet(viewModel: viewModel)
        }
    }

    private func blockRow(_ block: FocusBlock) -> some View {
        FocusBlockRow(block: block)
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    viewModel.deleteFocusBlock(block, modelContext: modelContext)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .swipeActions(edge: .leading) {
                Button {
                    viewModel.toggleCompletion(block)
                } label: {
                    Label(
                        block.isCompleted ? "Undo" : "Done",
                        systemImage: block.isCompleted ? "arrow.uturn.backward" : "checkmark"
                    )
                }
                .tint(.green)
            }
    }

    private var todayBlocks: [FocusBlock] {
        let calendar = Calendar.current
        return allBlocks.filter { calendar.isDateInToday($0.startTime) }
    }

    private var overdueBlocks: [FocusBlock] {
        todayBlocks.filter { !$0.isCompleted && $0.endTime < Date() }
    }

    private var currentBlocks: [FocusBlock] {
        let now = Date()
        return todayBlocks.filter { !$0.isCompleted && $0.startTime <= now && $0.endTime >= now }
    }

    private var laterBlocks: [FocusBlock] {
        todayBlocks.filter { !$0.isCompleted && $0.startTime > Date() }
    }

    private var completedBlocks: [FocusBlock] {
        todayBlocks.filter { $0.isCompleted }
    }
}
