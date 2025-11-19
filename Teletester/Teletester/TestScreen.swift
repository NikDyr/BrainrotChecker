class SocialTimeManager: ObservableObject {
    @Published var instagramMinutes: Int {
        didSet { saveTimes() }
    }
    @Published var tiktokMinutes: Int {
        didSet { saveTimes() }
    }
    @Published var youtubeMinutes: Int {
        didSet { saveTimes() }
    }
    private let instagramKey = "instagramMinutes"
    private let tiktokKey = "tiktokMinutes"
    private let youtubeKey = "youtubeMinutes"
    private let lastResetKey = "lastResetDate"

    init() {
        let defaults = UserDefaults.standard
        let today = Self.dateString(Date())
        let lastReset = defaults.string(forKey: lastResetKey)
        if lastReset != today {
            instagramMinutes = 0
            tiktokMinutes = 0
            youtubeMinutes = 0
            defaults.set(today, forKey: lastResetKey)
            saveTimes()
        } else {
            instagramMinutes = defaults.integer(forKey: instagramKey)
            tiktokMinutes = defaults.integer(forKey: tiktokKey)
            youtubeMinutes = defaults.integer(forKey: youtubeKey)
        }
    }

    private func saveTimes() {
        let defaults = UserDefaults.standard
        defaults.set(instagramMinutes, forKey: instagramKey)
        defaults.set(tiktokMinutes, forKey: tiktokKey)
        defaults.set(youtubeMinutes, forKey: youtubeKey)
    }

    static func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
import SwiftUI

struct BrainRotLevel {
    let name: String
    let description: String
    let color: Color
    let advice: String
}

let brainRotLevels: [BrainRotLevel] = [
    BrainRotLevel(
        name: "🌟 Absolute Freedom!",
        description: "You master your time! Social media doesn't interfere with your goals and dreams.",
        color: .green,
        advice: "Keep inspiring others with your example! 💪"
    ),
    BrainRotLevel(
        name: "😊 Mild Addiction",
        description: "Sometimes social media distracts you, but you quickly get back to what matters.",
        color: .yellow,
        advice: "Take a short walk, write a to-do list, and don't forget your hobbies! 🌈"
    ),
    BrainRotLevel(
        name: "😬 Moderate Addiction",
        description: "Time slips away, and social media becomes a habit.",
        color: .orange,
        advice: "Set a timer, try a phone-free day, and do some sports! 🚴‍♂️"
    ),
    BrainRotLevel(
        name: "🔥 Severe Addiction",
        description: "Social media drains your energy and mood. It's time to change your habits!",
        color: .red,
        advice: "Ask friends for support, try a digital detox, and discover new hobbies! 🌅"
    ),
]

func getBrainRotLevel(for wastedMinutes: Int) -> BrainRotLevel {
    switch wastedMinutes {
    case 0..<30:
        return brainRotLevels[0]
    case 30..<90:
        return brainRotLevels[1]
    case 90..<180:
        return brainRotLevels[2]
    default:
        return brainRotLevels[3]
    }
}

struct BrainRotScreen: View {
    @StateObject private var timeManager = SocialTimeManager()
    @State private var showLevelPopup: Bool = false
    @State private var lastLevelIndex: Int = 0
    @State private var showFocusAdvice: Bool = false
    @State private var showGoals: Bool = false

    var body: some View {
        let totalWasted = timeManager.instagramMinutes + timeManager.tiktokMinutes + timeManager.youtubeMinutes
        let level = getBrainRotLevel(for: totalWasted)
        let currentLevelIndex: Int = {
            switch totalWasted {
            case 0..<30: return 0
            case 30..<90: return 1
            case 90..<180: return 2
            default: return 3
            }
        }()
    VStack(spacing: 24) {
            Text("Brain Rot Calculator")
                .font(.largeTitle)
                .bold()
                .transition(.opacity.combined(with: .scale))
                .animation(.spring(), value: currentLevelIndex)
            Text("Enter the time spent today in social media:")
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: currentLevelIndex)
            HStack(spacing: 16) {
                VStack {
                    Text("Instagram")
                    TextField("minutes", value: $timeManager.instagramMinutes, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                VStack {
                    Text("TikTok")
                    TextField("minutes", value: $timeManager.tiktokMinutes, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                VStack {
                    Text("YouTube")
                    TextField("minutes", value: $timeManager.youtubeMinutes, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            ZStack {
                if !showLevelPopup {
                    VStack(spacing: 12) {
                        Text(level.name)
                            .font(.title2)
                            .foregroundColor(level.color)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(), value: currentLevelIndex)
                        Text(level.description)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                            .animation(.easeInOut, value: currentLevelIndex)
                        ProgressView(value: min(max(Double(totalWasted), 0), 180), total: 180)
                            .accentColor(level.color)
                            .frame(height: 20)
                            .scaleEffect(1.1)
                            .animation(.easeInOut, value: currentLevelIndex)
                        Text("Advice: \(level.advice)")
                            .italic()
                            .foregroundColor(.secondary)
                            .transition(.opacity)
                            .animation(.easeInOut, value: currentLevelIndex)
                    }
                }
                if showLevelPopup {
                    VStack(spacing: 20) {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .foregroundColor(level.color)
                                .rotationEffect(.degrees(showLevelPopup ? 360 : 0))
                                .animation(.easeInOut(duration: 0.8), value: showLevelPopup)
                            Text(level.name)
                                .font(.title)
                                .bold()
                                .foregroundColor(level.color)
                            Text(level.description)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Text(level.advice)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 24).fill(level.color.opacity(0.15)))
                        .shadow(radius: 10)
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(), value: showLevelPopup)
                }
            }
            Spacer()
            HStack(spacing: 16) {
                Button(action: {
                    showFocusAdvice = true
                }) {
                    Text("Focus Tips")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(12)
                }
                Button(action: {
                    showGoals = true
                }) {
                    Text("Personal Goals")
                        .font(.headline)
                        .padding()
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(12)
                }
            }
            .sheet(isPresented: $showFocusAdvice) {
                FocusAdviceScreen()
            }
            .sheet(isPresented: $showGoals) {
                PersonalGoalsScreen(
                    instagramMinutes: $timeManager.instagramMinutes,
                    tiktokMinutes: $timeManager.tiktokMinutes,
                    youtubeMinutes: $timeManager.youtubeMinutes
                )
            }
        }
        .padding()
        .onChange(of: currentLevelIndex) { newValue in
            if newValue != lastLevelIndex {
                showLevelPopup = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showLevelPopup = false
                }
                lastLevelIndex = newValue
            }
        }
    }
}

struct BrainRotScreen_Previews: PreviewProvider {
    static var previews: some View {
        BrainRotScreen()
    }
}
