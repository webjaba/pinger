import AppKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var timerManager: TimerManager

    @State private var minutesText: String
    @State private var secondsText: String

    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        _minutesText = State(initialValue: String(timerManager.intervalSeconds / 60))
        _secondsText = State(initialValue: String(timerManager.intervalSeconds % 60))
    }

    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 2) {
                Text(timerManager.formattedRemainingTime())
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .monospacedDigit()

                Text("Interval: \(timerManager.formattedIntervalTime())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                TextField("Min", text: $minutesText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 28)

                Text("min")
                    .foregroundStyle(.secondary)

                TextField("Sec", text: $secondsText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 28)

                Text("sec")
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                .buttonStyle(LiquidGlassButtonStyle())

                Button("Change Time") {
                    applyInterval()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(LiquidGlassButtonStyle(isProminent: true))
            }
        }
        .padding(12)
        .frame(width: 210, height: 164)
        .background(.ultraThinMaterial.opacity(0.22), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.24), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 14, y: 6)
        .onChange(of: timerManager.intervalSeconds) { _, newValue in
            minutesText = String(newValue / 60)
            secondsText = String(newValue % 60)
        }
    }

    private func applyInterval() {
        let minutes = Int(minutesText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let seconds = Int(secondsText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        timerManager.updateInterval(minutes: max(0, minutes), seconds: max(0, min(59, seconds)))
    }
}

private struct LiquidGlassButtonStyle: ButtonStyle {
    var isProminent = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(.primary.opacity(configuration.isPressed ? 0.78 : 0.9))
            .padding(.horizontal, isProminent ? 13 : 12)
            .padding(.vertical, 6)
            .background(
                .ultraThinMaterial.opacity(configuration.isPressed ? 0.42 : (isProminent ? 0.3 : 0.22)),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(.white.opacity(configuration.isPressed ? 0.42 : (isProminent ? 0.32 : 0.24)), lineWidth: 1)
            )
            .shadow(color: .white.opacity(isProminent ? 0.1 : 0.06), radius: 5, y: -1)
            .shadow(color: .black.opacity(configuration.isPressed ? 0.08 : 0.14), radius: 9, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.smooth(duration: 0.14), value: configuration.isPressed)
            .contentShape(Capsule())
    }
}
