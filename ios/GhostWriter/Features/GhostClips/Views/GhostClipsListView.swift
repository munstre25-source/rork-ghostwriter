import SwiftUI

struct GhostClipsListView: View {
    @State private var selectedSegment = 0
    @State private var clips: [GhostClip] = []
    @State private var isLoading = false
    @State private var showShareSheet = false
    @State private var selectedClip: GhostClip?

    private let segments = ["My Clips", "Trending", "Saved"]
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ghostBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    segmentPicker

                    if clips.isEmpty && !isLoading {
                        emptyState
                    } else {
                        clipGrid
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        createButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Clips")
            .navigationBarTitleDisplayMode(.large)
            .task { await loadClips() }
            .refreshable { await loadClips() }
            .sheet(item: $selectedClip) { clip in
                GhostClipShareSheet(clip: clip)
            }
        }
    }

    private var segmentPicker: some View {
        Picker("", selection: $selectedSegment) {
            ForEach(0..<segments.count, id: \.self) { index in
                Text(segments[index]).tag(index)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .onChange(of: selectedSegment) {
            Task { await loadClips() }
        }
    }

    private var clipGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(clips) { clip in
                    GhostClipPreviewView(clip: clip)
                        .onTapGesture {
                            selectedClip = clip
                        }
                        .hapticFeedback(.light)
                }
            }
            .padding(.horizontal)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "film.stack")
                .font(.system(size: 50))
                .foregroundColor(.ghostCyan.opacity(0.4))

            Text("No Clips Yet")
                .font(.title2.bold())
                .foregroundColor(.ghostText)

            Text("Capture your creative moments\nduring a session.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    private var createButton: some View {
        Button {
            // Navigate to create clip flow
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundColor(.black)
                .frame(width: 56, height: 56)
                .background(Color.ghostCyan)
                .cornerRadius(28)
                .shadow(color: .ghostCyan.opacity(0.4), radius: 8)
        }
        .hapticFeedback(.medium)
    }

    private func loadClips() async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .seconds(0.5))

        clips = (0..<6).map { i in
            let clip = GhostClip(
                sessionId: UUID(),
                creatorId: UUID(),
                videoURL: URL(string: "https://ghostwriter.app/clip/\(i)")!,
                duration: Double.random(in: 10...30)
            )
            clip.title = ["Brainstorm Flow", "Late Night Ideas", "Creative Burst", "Code Jam", "Design Sprint", "Free Write"][ i ]
            clip.viewCount = Int.random(in: 50...5000)
            clip.likeCount = Int.random(in: 5...500)
            clip.shareCount = Int.random(in: 1...100)
            return clip
        }
    }
}

#Preview {
    GhostClipsListView()
}
