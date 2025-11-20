import SwiftUI
import FirebaseRemoteConfig

struct ContentView: View {
    @State private var selectedScreen: String? = nil
    @State private var fcmToken: String? = nil

    @ObservedObject private var conversionStore = ConversionDataStore.shared

    @State private var animate = false

    var body: some View {
        Group {
            if let screen = selectedScreen {
                if screen == "webview" {
                    WebViewScreen()
                } else {
                    BrainRotScreen()
                }
            } else {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(animate ? 360 : 0))
                            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: animate)
                    }
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .onAppear {
                    animate = true
                    waitForAppsFlyerAndFetchScreen()
                }
            }
        }
        .onAppear {
            // Observe FCM token notifications for debugging
            NotificationCenter.default.addObserver(forName: .didReceiveFCMToken, object: nil, queue: .main) { note in
                let token = note.object as? String
                fcmToken = token
                print("Received FCM token in ContentView: \(token ?? "(nil)")")
            }
        }
    }

    // Ожидание запуска AppsFlyer (conversion data) не более 3 секунд
    func waitForAppsFlyerAndFetchScreen() {
        let start = Date()
        let timeout: TimeInterval = 3.0
        func checkConversionData() {
            if conversionStore.conversionData != nil {
                fetchABTestScreen()
            } else if Date().timeIntervalSince(start) > timeout {
                print("[ContentView] AppsFlyer conversion data timeout, продолжаем...")
                fetchABTestScreen()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    checkConversionData()
                }
            }
        }
        checkConversionData()
    }

    func fetchABTestScreen() {
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.fetchAndActivate { status, error in
            let value = remoteConfig["ab_test_screen"].stringValue
            print(value)
            DispatchQueue.main.async {
                selectedScreen = value
            }
        }
    }
}
