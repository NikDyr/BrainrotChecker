import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity
import ScreenTime

struct FocusAdvice {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

let focusAdvices: [FocusAdvice] = [
    FocusAdvice(title: "Set Clear Goals", description: "Define what you want to achieve in each session. Break tasks into smaller steps and focus on one at a time.", icon: "target", color: .blue),
    FocusAdvice(title: "Remove Distractions", description: "Turn off notifications, put your phone away, and create a quiet workspace. Use apps or browser extensions to block distracting sites.", icon: "bell.slash", color: .purple),
    FocusAdvice(title: "Use the Pomodoro Technique", description: "Work for 25 minutes, then take a 5-minute break. Repeat. This helps maintain high concentration and prevents burnout.", icon: "timer", color: .orange),
    FocusAdvice(title: "Practice Mindfulness", description: "Take a few deep breaths before starting work. If your mind wanders, gently bring your attention back to the task.", icon: "leaf", color: .green),
    FocusAdvice(title: "Stay Hydrated & Eat Well", description: "Drink water and eat healthy snacks. Good nutrition supports brain function and focus.", icon: "drop", color: .cyan),
    FocusAdvice(title: "Get Enough Sleep", description: "Aim for 7-9 hours of sleep per night. Rested brains concentrate better and process information faster.", icon: "bed.double", color: .indigo),
    FocusAdvice(title: "Move Regularly", description: "Take short walks or stretch between work sessions. Physical activity boosts energy and attention.", icon: "figure.walk", color: .pink),
    FocusAdvice(title: "Celebrate Progress", description: "Reward yourself for completing tasks. Positive reinforcement helps build good habits.", icon: "star.fill", color: .yellow)
]

@available(iOS 16.0, *)
struct FocusAdviceScreen: View {
    @State private var isPresented = false
    @State private var authorizationStatus: FamilyControls.AuthorizationStatus = .notDetermined
    @State private var totalScreenTime: TimeInterval = 0

    func requestAuthorization() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                let status = AuthorizationCenter.shared.authorizationStatus
                DispatchQueue.main.async {
                    self.authorizationStatus = status
                }
            } catch {
                print("Authorization failed: \(error)")
            }
        }
    }
    @State private var selection = FamilyActivitySelection()
    @State private var showPicker = false

    



    func fetchScreenTime() {
        let defaults = UserDefaults(suiteName: "group.com.puplaplay.braincheck")
        let instagram = defaults?.integer(forKey: "instagramMinutes") ?? 0
        let tiktok = defaults?.integer(forKey: "tiktokMinutes") ?? 0
        let youtube = defaults?.integer(forKey: "youtubeMinutes") ?? 0
        totalScreenTime = TimeInterval(instagram + tiktok + youtube) * 60
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Focus & Concentration Tips")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                ForEach(Array(focusAdvices.enumerated()), id: \.offset) { idx, advice in
                    FocusAdviceCard(advice: advice, index: idx + 1)
                }
                Button("Select Apps to Track") {
                    showPicker = true
                }
                .familyActivityPicker(isPresented: $showPicker, selection: $selection)
                if !selection.applicationTokens.isEmpty {
                    Text("Selected apps: \(selection.applicationTokens.count)")
                }
            }
            .padding()
            if authorizationStatus == .notDetermined {
                Button("Enable ScreenTime Tracking") {
                    requestAuthorization()
                }
            } else if authorizationStatus == .approved {
                Text("ScreenTime access granted.")
                Text("Total screen time today: \(Int(totalScreenTime/60)) min")
                Button("Refresh Usage") {
                    fetchScreenTime()
                }
            } else {
                Text("ScreenTime access denied or restricted.")
            }
        }
    }
}

struct FocusAdviceCard: View {
    let advice: FocusAdvice
    let index: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(advice.color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: advice.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(advice.color)
                }
                Text("\(index). \(advice.title)")
                    .font(.title3)
                    .bold()
            }
            Text(advice.description)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(advice.color.opacity(0.08)))
        .shadow(color: advice.color.opacity(0.12), radius: 6, x: 0, y: 2)
    }
}

struct FocusAdviceScreen_Previews: PreviewProvider {
    static var previews: some View {
        FocusAdviceScreen()
    }
}
