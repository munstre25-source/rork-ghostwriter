import SwiftUI

struct CollaborationIndicator: View {
    let score: Double
    let localWordCount: Int
    let remoteWordCount: Int

    private var overlap: CGFloat {
        CGFloat(score / 100.0) * 20
    }

    var body: some View {
        HStack(spacing: -overlap) {
            Circle()
                .fill(Color.ghostCyan.opacity(0.6))
                .frame(width: 24, height: 24)
                .overlay(
                    Text("\(localWordCount)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                )

            Circle()
                .fill(Color.ghostMagenta.opacity(0.6))
                .frame(width: 24, height: 24)
                .overlay(
                    Text("\(remoteWordCount)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .overlay(
            Text("\(Int(score))%")
                .font(.system(size: 7, weight: .bold))
                .foregroundColor(.ghostGold)
                .offset(y: 18)
        )
        .animation(.spring(duration: 0.4), value: score)
    }
}

#Preview("High Score") {
    CollaborationIndicator(score: 85, localWordCount: 120, remoteWordCount: 105)
        .padding()
        .background(Color.ghostBackground)
}

#Preview("Low Score") {
    CollaborationIndicator(score: 25, localWordCount: 200, remoteWordCount: 30)
        .padding()
        .background(Color.ghostBackground)
}
