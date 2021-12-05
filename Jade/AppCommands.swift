//
//  AppCommands.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import SwiftUI

struct AppCommands: Commands {
    @Environment(\.openURL) var openURL: OpenURLAction

    @CommandsBuilder var body: some Commands {
        CommandGroup(replacing: .newItem) { }
        CommandGroup(replacing: .help) {
            Button("Jade Help") {
                help()
            }
        }
    }

    private func help() {

        guard let url: URL = URL(string: .homepage) else {
            return
        }

        openURL(url)
    }
}
