import Foundation
import AppsFlyerLib

class ConversionDataStore: ObservableObject {
    static let shared = ConversionDataStore()

    // Тестовые данные для запроса (на время тестов)
    init() {
        #if DEBUG
        self.conversionData = [
            "af_status": "Non-organic",
            "bundle_id": "com.example.app",
            "os": "iOS",
            "store_id": "com.example.app"
        ]
        #endif
    }
    @Published var conversionData: [AnyHashable: Any]? = nil
    @Published var webViewURL: String? = nil

    func updateConversionData(_ data: [AnyHashable: Any]) {
        var merged = conversionData ?? [:]
        for (key, value) in data {
            merged[key] = value
        }
        conversionData = merged
    }

    func fetchWebViewURL(completion: @escaping (String?) -> Void) {
        guard let conversionData = conversionData else {
            completion(nil)
            return
        }
        guard let url = URL(string: "https://wavemerges.com/config.php") else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: conversionData, options: [.prettyPrinted])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("[ConversionDataStore] JSON payload for POST:\n\(jsonString)")
            }
            request.httpBody = jsonData
        } catch {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            // Парсим JSON и берём поле url
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let ok = json["ok"] as? Bool, ok,
               let urlString = json["url"] as? String {
                DispatchQueue.main.async {
                    self.webViewURL = urlString
                    completion(urlString)
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
