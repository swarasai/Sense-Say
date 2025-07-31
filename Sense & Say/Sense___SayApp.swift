//___FILEHEADER___

import SwiftUI
import FirebaseCore

@main
struct Sense___SayApp: App {
    @StateObject var theme = AppTheme()
    init() { FirebaseApp.configure() }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme) // inject theme everywhere
        }
    }
}
