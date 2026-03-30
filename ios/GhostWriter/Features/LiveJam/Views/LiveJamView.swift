import SwiftUI

struct LiveJamView: View {
    @State private var viewModel = LiveJamViewModel()

    var body: some View {
        ZStack {
            Color.ghostBackground.ignoresSafeArea()

            if viewModel.isConnected {
                connectedView
            } else {
                emptyStateView
            }
        }
        .navigationTitle("Live Jam")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var connectedView: some View {
        VStack(spacing: 0) {
            headerBar

            VStack(spacing: 12) {
                localSection
                suggestionsSection
                remoteSection
            }
            .padding(.horizontal)

            Spacer()

            bottomBar
        }
    }

    private var headerBar: some View {
        HStack {
            Circle()
                .fill(Color.ghostEmerald)
                .frame(width: 8, height: 8)
            Text("Connected")
                .font(.caption)
                .foregroundColor(.ghostEmerald)

            Spacer()

            CollaborationIndicator(
                score: viewModel.collaborationScore,
                localWordCount: viewModel.localText.split(separator: " ").count,
                remoteWordCount: viewModel.remoteText.split(separator: " ").count
            )
            .frame(height: 30)

            Spacer()

            if let name = viewModel.collaboratorName {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.ghostMagenta)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private var localSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("You", systemImage: "person.fill")
                .font(.caption.bold())
                .foregroundColor(.ghostCyan)

            TextEditor(text: $viewModel.localText)
                .scrollContentBackground(.hidden)
                .foregroundColor(.ghostText)
                .font(.body)
                .frame(minHeight: 120, maxHeight: 180)
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.ghostCyan.opacity(0.3), lineWidth: 1)
                )
        }
    }

    private var suggestionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(viewModel.sharedSuggestions) { suggestion in
                    sharedSuggestionCard(suggestion)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: viewModel.sharedSuggestions.isEmpty ? 0 : 100)
    }

    private func sharedSuggestionCard(_ suggestion: GhostSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(suggestion.content)
                .font(.caption)
                .foregroundColor(.ghostText)
                .lineLimit(3)

            HStack {
                Button {
                    Task { await viewModel.voteSuggestion(suggestion, accept: true) }
                } label: {
                    Image(systemName: "hand.thumbsup")
                        .foregroundColor(.ghostEmerald)
                }
                .hapticFeedback(.light)

                Button {
                    Task { await viewModel.voteSuggestion(suggestion, accept: false) }
                } label: {
                    Image(systemName: "hand.thumbsdown")
                        .foregroundColor(.ghostMagenta)
                }
                .hapticFeedback(.light)
            }
            .font(.caption)
        }
        .padding(10)
        .frame(width: 200)
        .background(.regularMaterial)
        .cornerRadius(10)
    }

    private var remoteSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(viewModel.collaboratorName ?? "Collaborator", systemImage: "person.2.fill")
                .font(.caption.bold())
                .foregroundColor(.ghostMagenta)

            ScrollView {
                Text(viewModel.remoteText.isEmpty ? "Waiting for input..." : viewModel.remoteText)
                    .font(.body)
                    .foregroundColor(viewModel.remoteText.isEmpty ? .gray : .ghostText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
            .frame(minHeight: 120, maxHeight: 180)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.ghostMagenta.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 20) {
            Button {
                Task { await viewModel.endLiveJam() }
            } label: {
                Label("End Jam", systemImage: "stop.circle.fill")
                    .foregroundColor(.red)
            }
            .hapticFeedback(.medium)

            Spacer()

            Button {
                // Capture clip action
            } label: {
                Label("Capture", systemImage: "record.circle")
                    .foregroundColor(.ghostGold)
            }
            .hapticFeedback(.medium)
        }
        .padding()
        .background(.regularMaterial)
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.2.wave.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.ghostCyan.opacity(0.5))

            Text("Live Jam")
                .font(.title.bold())
                .foregroundColor(.ghostText)

            Text("Collaborate in real-time with another creator.\nBoth inputs feed the Ghost AI for shared suggestions.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button {
                Task { try? await viewModel.startLiveJam(with: UUID()) }
            } label: {
                Label("Start Live Jam", systemImage: "play.circle.fill")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.ghostCyan)
                    .cornerRadius(25)
            }
            .hapticFeedback(.medium)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        LiveJamView()
    }
}
