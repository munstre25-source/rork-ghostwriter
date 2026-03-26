import SwiftUI

struct GhostClipShareSheet: View {
    let clip: GhostClip
    @State private var viewModel = GhostClipShareViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    clipPreview
                    platformButtons
                    captionField
                    copyLinkButton
                }
                .padding()
            }
            .background(Color.ghostBackground.ignoresSafeArea())
            .navigationTitle("Share Clip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.ghostCyan)
                }
            }
            .task {
                viewModel.clip = clip
                viewModel.caption = "Check out this creative moment! ✨ #GhostWriter #CreativeAI"
                _ = try? await viewModel.generateShareURL()
            }
        }
    }

    private var clipPreview: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.ghostCyan.opacity(0.2), .ghostMagenta.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .cornerRadius(12)

            Text(clip.title ?? "Untitled Clip")
                .font(.headline)
                .foregroundColor(.ghostText)
        }
    }

    private var platformButtons: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Share to")
                .font(.headline)
                .foregroundColor(.ghostText)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(SharePlatform.allCases) { platform in
                    Button {
                        Task { try? await viewModel.shareToExternal(platform: platform) }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: platform.icon)
                                .font(.title2)
                                .foregroundColor(platform.color)
                                .frame(width: 50, height: 50)
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)

                            Text(platform.displayName)
                                .font(.caption2)
                                .foregroundColor(.ghostText)
                        }
                    }
                    .hapticFeedback(.light)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }

    private var captionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Caption")
                .font(.headline)
                .foregroundColor(.ghostText)

            TextEditor(text: $viewModel.caption)
                .scrollContentBackground(.hidden)
                .foregroundColor(.ghostText)
                .frame(height: 80)
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
        }
    }

    private var copyLinkButton: some View {
        Button {
            viewModel.copyLink()
        } label: {
            Label("Copy Link", systemImage: "link")
                .font(.headline)
                .foregroundColor(.ghostCyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .cornerRadius(14)
        }
        .hapticFeedback(.light)
    }
}

#Preview {
    let clip = GhostClip(
        sessionId: UUID(),
        creatorId: UUID(),
        videoURL: URL(string: "https://example.com")!,
        duration: 25
    )
    return GhostClipShareSheet(clip: clip)
}
