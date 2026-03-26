import SwiftUI

struct GhostClipPreviewView: View {
    let clip: GhostClip

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.ghostCyan.opacity(0.2), .ghostMagenta.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.9))

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(String(format: "%.0fs", clip.duration))
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.black.opacity(0.6))
                            .cornerRadius(4)
                            .padding(6)
                    }
                }
            }
            .cornerRadius(12)

            Text(clip.title ?? "Untitled Clip")
                .font(.subheadline.bold())
                .foregroundColor(.ghostText)
                .lineLimit(1)

            HStack(spacing: 12) {
                Label("\(clip.viewCount)", systemImage: "eye")
                Label("\(clip.likeCount)", systemImage: "heart")
                Label("\(clip.shareCount)", systemImage: "arrowshape.turn.up.right")
            }
            .font(.caption2)
            .foregroundColor(.gray)
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }
}

#Preview {
    let clip = GhostClip(
        sessionId: UUID(),
        creatorId: UUID(),
        videoURL: URL(string: "https://example.com/clip")!,
        duration: 28
    )
    return GhostClipPreviewView(clip: clip)
        .frame(width: 180)
        .padding()
        .background(Color.ghostBackground)
}
