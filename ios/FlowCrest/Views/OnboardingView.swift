import SwiftUI
import HealthKit
import EventKit

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isAnalyzing = false
    @State private var analysisComplete = false
    @State private var animateWelcome = false
    let healthService: HealthKitService
    let eventKitService: EventKitService
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            backgroundGradient
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                healthKitPage.tag(1)
                calendarPage.tag(2)
                analysisPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.smooth(duration: 0.4), value: currentPage)

            VStack {
                Spacer()
                pageIndicator
                    .padding(.bottom, 20)
            }
        }
        .ignoresSafeArea()
    }

    private var backgroundGradient: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .black, Color(red: 0.05, green: 0.05, blue: 0.15), .black,
                Color(red: 0.0, green: 0.08, blue: 0.12), Color(red: 0.0, green: 0.15, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15),
                .black, Color(red: 0.0, green: 0.06, blue: 0.1), .black
            ]
        )
        .ignoresSafeArea()
    }

    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "brain.head.profile.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.teal, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.breathe, isActive: animateWelcome)
                .scaleEffect(animateWelcome ? 1.0 : 0.8)
                .opacity(animateWelcome ? 1 : 0)

            VStack(spacing: 12) {
                Text("FlowCrest")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                Text("Work with your biology,\nnot against it.")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .opacity(animateWelcome ? 1 : 0)
            .offset(y: animateWelcome ? 0 : 20)

            Spacer()

            VStack(spacing: 16) {
                featurePill(icon: "waveform.path.ecg", text: "Bio-adaptive scheduling")
                featurePill(icon: "lock.shield.fill", text: "100% on-device, private")
                featurePill(icon: "sparkles", text: "AI-powered optimization")
            }
            .opacity(animateWelcome ? 1 : 0)
            .offset(y: animateWelcome ? 0 : 30)

            Spacer()

            Button {
                withAnimation(.snappy) { currentPage = 1 }
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.teal, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.capsule)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateWelcome = true
            }
        }
    }

    private func featurePill(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.teal)
                .frame(width: 32)
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal, 32)
    }

    private var healthKitPage: some View {
        permissionPage(
            icon: "heart.fill",
            iconColor: .pink,
            title: "Health Data",
            subtitle: "Heart rate variability, sleep quality, and resting heart rate help us understand your cognitive readiness.",
            privacyNote: "Your health data never leaves this device. All processing happens locally using on-device intelligence.",
            buttonTitle: healthService.authorizationStatus == .sharingAuthorized ? "Enabled" : "Enable HealthKit",
            isEnabled: healthService.authorizationStatus == .sharingAuthorized,
            action: {
                Task {
                    await healthService.requestAuthorization()
                    try? await Task.sleep(for: .milliseconds(500))
                    withAnimation(.snappy) { currentPage = 2 }
                }
            },
            skipAction: { withAnimation(.snappy) { currentPage = 2 } }
        )
    }

    private var calendarPage: some View {
        permissionPage(
            icon: "calendar",
            iconColor: .red,
            title: "Calendar Access",
            subtitle: "We sync your calendar events to analyze task alignment with your energy levels throughout the day.",
            privacyNote: "Calendar data is processed entirely on your device. We never upload or share your schedule.",
            buttonTitle: eventKitService.authorizationStatus == .fullAccess ? "Enabled" : "Enable Calendar",
            isEnabled: eventKitService.authorizationStatus == .fullAccess,
            action: {
                Task {
                    await eventKitService.requestAuthorization()
                    try? await Task.sleep(for: .milliseconds(500))
                    withAnimation(.snappy) { currentPage = 3 }
                    startAnalysis()
                }
            },
            skipAction: {
                withAnimation(.snappy) { currentPage = 3 }
                startAnalysis()
            }
        )
    }

    private func permissionPage(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        privacyNote: String,
        buttonTitle: String,
        isEnabled: Bool,
        action: @escaping () -> Void,
        skipAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(iconColor)

            VStack(spacing: 12) {
                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            HStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .font(.caption)
                    .foregroundStyle(.teal)
                Text(privacyNote)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(14)
            .background(.white.opacity(0.04))
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal, 16)

            Spacer()

            VStack(spacing: 12) {
                Button(action: action) {
                    HStack {
                        if isEnabled {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        Text(buttonTitle)
                    }
                    .font(.headline)
                    .foregroundStyle(isEnabled ? .white : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isEnabled ? Color.green : Color.teal)
                    .clipShape(.capsule)
                }
                .disabled(isEnabled)

                Button("Skip for now", action: skipAction)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
    }

    private var analysisPage: some View {
        VStack(spacing: 32) {
            Spacer()

            if analysisComplete {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.green)
                        .symbolEffect(.bounce, value: analysisComplete)

                    Text("You're All Set!")
                        .font(.title.bold())
                        .foregroundStyle(.white)

                    Text("FlowCrest has analyzed your schedule and bio data. Let's optimize your day.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                VStack(spacing: 20) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(.teal)

                    Text("Analyzing Your Data")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("Scanning calendar events and bio metrics...")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()

            if analysisComplete {
                Button {
                    onComplete()
                } label: {
                    Text("Start Using FlowCrest")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.teal, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.capsule)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? .teal : .white.opacity(0.2))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.snappy, value: currentPage)
            }
        }
    }

    private func startAnalysis() {
        isAnalyzing = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.spring(response: 0.5)) {
                analysisComplete = true
            }
        }
    }
}
