
import SwiftUI
import WebKit

struct WebViewScreen: View {
    let urlString: String

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            if !urlString.isEmpty, let url = URL(string: urlString) {
                WebView(url: url)
            } else {
                Text("Cannot load.")
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No-op: handled in makeUIView
    }
}

struct WebViewScreen_Previews: PreviewProvider {
    static var previews: some View {
        WebViewScreen(urlString: "https://example.com")
    }
}
