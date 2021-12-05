//
//  AppDelegate.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {

    // swiftlint:disable:next weak_delegate
    private let userNotificationCenterDelegate: UserNotificationCenterDelegate = UserNotificationCenterDelegate()

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = userNotificationCenterDelegate

        let action: UNNotificationAction = UNNotificationAction(identifier: UNNotificationAction.Identifier.update, title: "Update", options: .foreground)
        let category: UNNotificationCategory = UNNotificationCategory(identifier: UNNotificationCategory.Identifier.update, actions: [action], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
