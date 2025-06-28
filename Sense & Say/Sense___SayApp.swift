//___FILEHEADER___

import SwiftUI
import FirebaseCore

@main
struct Sense___SayApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
