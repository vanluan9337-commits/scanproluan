import SwiftUI

@main
struct ScanProApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                DocsView().tabItem { Label("Tài liệu", systemImage: "doc.viewfinder") }
                TranslateView().tabItem { Label("Dịch ảnh", systemImage: "character.bubble") }
            }
        }
    }
}
