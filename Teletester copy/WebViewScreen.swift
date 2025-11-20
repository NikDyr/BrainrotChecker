import SwiftUI
import WebKit

struct WebViewScreen: View {
    @ObservedObject private var conversionStore = ConversionDataStore.shared
    @State private var urlString: String = ""
    @State private var isLoading: Bool = true
    
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                if isLoading {
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
                        // Запросить ссылку для WebView
                        conversionStore.fetchWebViewURL { link in
                            if let link = link {
                                urlString = link
                            }
                            isLoading = false
                        }
                    }
                } else {
                    if !urlString.isEmpty {
                        WebView(urlString: urlString)
                    } else {
                        Text("Cannot load.")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("WebView")
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String

    // Safari User-Agent для маскировки WebView
    private let customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15"
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Включаем автовоспроизведение только для inline-видео
        if #available(iOS 10.0, *) {
            config.allowsInlineMediaPlayback = true
            config.mediaTypesRequiringUserActionForPlayback = []
        }
        let webView = WKWebView(frame: .zero, configuration: config)
        // Устанавливаем кастомный User-Agent
        webView.customUserAgent = customUserAgent
        // Делегаты для обработки навигации, ошибок и вкладок
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        // Добавляем обработчик свайпа вправо для возврата назад
        let swipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipe(_:)))
        swipeGesture.direction = .right
        webView.addGestureRecognizer(swipeGesture)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(urlString: urlString)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var lastRedirectURL: URL?
        var initialURLString: String

        init(urlString: String) {
            self.initialURLString = urlString
        }

        @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
            if let webView = gesture.view as? WKWebView {
                if webView.canGoBack {
                    webView.goBack()
                }
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorHTTPTooManyRedirects {
                // В случае ошибки множественных редиректов пробуем загрузить страницу с последнего URL
                let failingURL = nsError.userInfo[NSURLErrorFailingURLErrorKey] as? URL
                let reloadURL = failingURL ?? URL(string: initialURLString)
                if let url = reloadURL {
                    let request = URLRequest(url: url)
                    webView.load(request)
                }
            }
        }

        // Отключаем зум после загрузки страницы
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let js = "var meta = document.querySelector('meta[name=viewport]'); if (!meta) { meta = document.createElement('meta'); meta.name = 'viewport'; document.head.appendChild(meta); } meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }

        // Открытие новых вкладок (target="_blank") в текущем окне
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct WebViewScreen_Previews: PreviewProvider {
    static var previews: some View {
        WebViewScreen()
    }
}
