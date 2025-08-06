//___FILEHEADER___

import SwiftUI
import FirebaseCore

@main
struct Sense___SayApp: App {
    @StateObject var userProfile = UserProfile()
    @StateObject var theme = AppTheme()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(userProfile)
                .environmentObject(theme)
                .onAppear {
                    userProfile.loadProfile()
                }
        }
    }
}
