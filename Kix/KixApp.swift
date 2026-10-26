//
//  KixApp.swift
//  Kix
//
//  由 Konstanty Halets 创建于 2026/01/06。
//

import SwiftUI

@main
struct KixApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AuthRouterView()
                .environmentObject(appState)
        }
    }
}

