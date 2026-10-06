import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct DonasyONApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var rewardsViewModel = RewardsViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(rewardsViewModel)
                .environmentObject(userProfileViewModel)
        }
    }
}
