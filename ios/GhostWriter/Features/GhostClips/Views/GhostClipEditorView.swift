import SwiftUI

struct GhostClipEditorView: View {
    let clipId: UUID
    @State private var viewModel = GhostClipEditorViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                videoPreview
                trimControls
                metadataFields
                overlayControls
                exportButton
            }
            .padding()
        }
        .background(Color.ghostBackground.ignoresSafeArea())
        .navigationTitle("Edit Clip")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadClip(id: clipId) }
    }

    private var videoPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 220)

            Image(systemName: "play.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.ghostCyan)
        }
        .liquidGlass(cornerRadius: 16)
    }

    private var trimControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trim")
                .font(.headline)
                .foregroundColor(.ghostText)

            HStack {
                Text(String(format: "%.1fs", viewModel.trimStart))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.ghostCyan)

                Slider(
                    value: $viewModel.trimEnd,
                    in: viewModel.trimStart...(viewModel.clip?.duration ?? 30)
                )
                .tint(.ghostCyan)

                Text(String(format: "%.1fs", viewModel.trimEnd))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.ghostCyan)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private var metadataFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .foregroundColor(.ghostText)

            TextField("Title", text: $viewModel.title)
                .textFieldStyle(.plain)
                .padding(10)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .foregroundColor(.ghostText)

            TextField("Description", text: $viewModel.clipDescription, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(3...6)
                .padding(10)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .foregroundColor(.ghostText)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private var overlayControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overlay")
                .font(.headline)
                .foregroundColor(.ghostText)

            TextField("Text overlay...", text: Binding(
                get: { viewModel.selectedOverlayText ?? "" },
                set: { viewModel.addTextOverlay($0) }
            ))
            .textFieldStyle(.plain)
            .padding(10)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .foregroundColor(.ghostText)

            if let clip = viewModel.clip {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.ghostMagenta)
                    Text(clip.personalityUsed)
                        .font(.caption)
                        .foregroundColor(.ghostText)
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private var exportButton: some View {
        Button {
            Task { _ = try? await viewModel.exportClip() }
        } label: {
            HStack {
                if viewModel.isExporting {
                    ProgressView().tint(.black)
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text(viewModel.isExporting ? "Exporting..." : "Export Clip")
            }
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.ghostCyan)
            .cornerRadius(14)
        }
        .disabled(viewModel.isExporting)
        .hapticFeedback(.medium)
    }
}

#Preview {
    NavigationStack {
        GhostClipEditorView(clipId: UUID())
    }
}
