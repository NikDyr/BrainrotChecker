import DeviceActivity
import FamilyControls
import ManagedSettings

class ScreenTimeMonitor: DeviceActivityMonitor {
    let appGroupID = "group.com.puplaplay.braincheck"
    let instagramBundle = "com.burbn.instagram"
    let tiktokBundle = "com.zhiliaoapp.musically"
    let youtubeBundle = "com.google.ios.youtube"

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        guard let store = try? DeviceActivityReport.fetch(for: .daily, date: Date()) else { return }
        var instagramMinutes = 0
        var tiktokMinutes = 0
        var youtubeMinutes = 0

        for (token, usage) in store.applicationActivity {
            switch token.bundleIdentifier {
            case instagramBundle:
                instagramMinutes = Int((usage.totalActivityDuration ?? 0) / 60)
            case tiktokBundle:
                tiktokMinutes = Int((usage.totalActivityDuration ?? 0) / 60)
            case youtubeBundle:
                youtubeMinutes = Int((usage.totalActivityDuration ?? 0) / 60)
            default:
                continue
            }
        }

        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(instagramMinutes, forKey: "instagramMinutes")
        defaults?.set(tiktokMinutes, forKey: "tiktokMinutes")
        defaults?.set(youtubeMinutes, forKey: "youtubeMinutes")
    }
}
