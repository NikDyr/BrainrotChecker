import SwiftUI

struct ContentView: View {
    @State private var selectedScreen: String? = nil
    @State private var fcmToken: String? = nil

    @ObservedObject private var conversionStore = ConversionDataStore.shared

    @State private var animate = false

    // ...existing code...

    var body: some View {
        Group {
            if let screen = selectedScreen {
                WebViewScreen()
                    .onAppear {
                        // Load the web view URL when the screen appears
                        if conversionStore.webViewURL == nil {
                            conversionStore.fetchWebViewURL { url in
                                if let url = url {
                                    print("Loaded WebView URL: \(url)")
                                } else {
                                    print("Failed to load WebView URL")
                                }
                            }
                        }
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

    // ...existing code...

    // ...existing code...
}
