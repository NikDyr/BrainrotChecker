
import SwiftUI
import FamilyControls


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



import DeviceActivity
import ManagedSettings

struct BrainRotScreen: View {
    @Binding var selection: FamilyActivitySelection
    @Binding var authorizationStatus: FamilyControls.AuthorizationStatus
    @State private var appScreenTimes: [String: Int] = [:] // token identifier: minutes
    @State private var showFocusAdvice = false
    @State private var showGoals = false

    let appGroupID = "group.com.puplaplay.braincheck"

    func fetchScreenTimes() {
        let defaults = UserDefaults(suiteName: appGroupID)
        var result: [String: Int] = [:]
        for token in selection.applicationTokens {
            let key = String(describing: token)
            let minutes = defaults?.integer(forKey: key) ?? 0
            result[key] = minutes
        }
        appScreenTimes = result
    }

    var totalWasted: Int {
        appScreenTimes.values.reduce(0, +)
    }

    var level: BrainRotLevel {
        getBrainRotLevel(for: totalWasted)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Brain Rot Calculator")
                .font(.largeTitle)
                .bold()
            if !selection.applicationTokens.isEmpty {
                Button("Изменить приложения") {
                    // showPicker теперь управляется из ContentView
                }
                List(Array(selection.applicationTokens), id: \.self) { (token: ApplicationToken) in
                    HStack {
                        Text(String(describing: token))
                        Spacer()
                        Text("\(appScreenTimes[String(describing: token)] ?? 0) min")
                    }
                }
                .frame(height: 200)
                Button("Обновить статистику") {
                    fetchScreenTimes()
                }
            }
            VStack(spacing: 12) {
                Text(level.name)
                    .font(.title2)
                    .foregroundColor(level.color)
                Text(level.description)
                    .multilineTextAlignment(.center)
                ProgressView(value: min(max(Double(totalWasted), 0), 180), total: 180)
                    .accentColor(level.color)
                    .frame(height: 20)
                    .scaleEffect(1.1)
                Text("Advice: \(level.advice)")
                    .italic()
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 16) {
                Button(action: { showFocusAdvice = true }) {
                    Text("Focus Tips")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(12)
                }
                Button(action: { showGoals = true }) {
                    Text("Personal Goals")
                        .font(.headline)
                        .padding()
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .onAppear {
            fetchScreenTimes()
        }
        .onChange(of: selection) { _ in
            fetchScreenTimes()
        }
        .sheet(isPresented: $showFocusAdvice) {
            FocusAdviceScreen()
        }
        .sheet(isPresented: $showGoals) {
            PersonalGoalsScreen(
                instagramMinutes: .constant(0),
                tiktokMinutes: .constant(0),
                youtubeMinutes: .constant(0)
            )
        }
    }

    // ...authorization теперь в ContentView...
}

// ...existing code removed: duplicate and broken blocks...


struct BrainRotScreen_Previews: PreviewProvider {
    @State static var selection = FamilyActivitySelection()
    @State static var authorizationStatus: FamilyControls.AuthorizationStatus = .notDetermined
    static var previews: some View {
        BrainRotScreen(selection: $selection, authorizationStatus: $authorizationStatus)
    }
}
