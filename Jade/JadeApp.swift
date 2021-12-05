//
//  JadeApp.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

@main
struct JadeApp: App {
    // swiftlint:disable:next weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            AppCommands()
        }
    }
}
