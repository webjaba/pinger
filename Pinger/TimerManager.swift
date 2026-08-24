import Foundation

@MainActor
final class TimerManager: ObservableObject {
    @Published private(set) var intervalSeconds: Int
    @Published private(set) var remainingSeconds: Int

    var onTimerFinished: (() -> Void)?

    private var timer: Timer?
    private let defaultsKey = "timerIntervalSeconds"
    private let defaultIntervalSeconds = 15 * 60

    init() {
        let savedInterval = UserDefaults.standard.integer(forKey: defaultsKey)
        let interval = savedInterval > 0 ? savedInterval : defaultIntervalSeconds
        intervalSeconds = interval
        remainingSeconds = interval
    }

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func updateInterval(minutes: Int, seconds: Int = 0) {
        let newInterval = max(1, minutes * 60 + seconds)
        intervalSeconds = newInterval
        remainingSeconds = newInterval
        UserDefaults.standard.set(newInterval, forKey: defaultsKey)
        start()
    }

    func formattedRemainingTime() -> String {
        Self.format(seconds: remainingSeconds)
    }

    func formattedIntervalTime() -> String {
        Self.format(seconds: intervalSeconds)
    }

    static func format(seconds totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            restartAfterCompletion()
            return
        }

        remainingSeconds -= 1

        if remainingSeconds == 0 {
            restartAfterCompletion()
        }
    }

    private func restartAfterCompletion() {
        onTimerFinished?()
        remainingSeconds = intervalSeconds
    }
}
