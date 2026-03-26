import SwiftUI

struct AddFocusBlockSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ScheduleViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("What are you working on?", text: $viewModel.newTaskDescription)
                }

                Section("Energy Level") {
                    Picker("Energy Demand", selection: $viewModel.newEnergyLevel) {
                        ForEach(EnergyLevel.allCases, id: \.self) { level in
                            Label(level.displayName, systemImage: level.icon)
                                .tag(level)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Time") {
                    DatePicker("Start", selection: $viewModel.newStartTime, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $viewModel.newEndTime, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("New Focus Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetForm()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addFocusBlock(modelContext: modelContext)
                        dismiss()
                    }
                    .disabled(viewModel.newTaskDescription.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
