import SwiftUI

struct ShareScoreSheet: View {
    let score: Double
    let insight: String
    let hourlyReadiness: [Double]
    let blocks: [FocusBlock]
    @Environment(\.dismiss) private var dismiss
    @State private var shareImage: UIImage?
    @State private var isGenerating = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let image = shareImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                            .padding(.horizontal)

                        ShareLink(
                            item: Image(uiImage: image),
                            preview: SharePreview(
                                "My FlowCrest Score: \(Int(score))/100",
                                image: Image(uiImage: image)
                            )
                        ) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Heatmap")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.teal)
                        .padding(.horizontal, 32)
                    } else {
                        VStack(spacing: 16) {
                            ProgressView()
                                .controlSize(.large)
                            Text("Generating heatmap...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 300)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Focus Heatmap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            shareImage = HeatmapGenerator.shared.generateHeatmapImage(
                score: score,
                insight: insight,
                hourlyReadiness: hourlyReadiness,
                blocks: blocks
            )
            isGenerating = false
        }
    }
}
