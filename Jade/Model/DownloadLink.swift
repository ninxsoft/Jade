//
//  DownloadLink.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import Foundation

struct DownloadLink: Decodable, Equatable, Identifiable {

    static var example: DownloadLink {
        DownloadLink(
            id: 815,
            url: "https://ci.jamfcloud.com/GM/JamfPro10.0.0.dmg",
            checksum: "59a86e40088444451804005eacfdef49",
            title: "Mac"
        )
    }

    var id: Int
    var url: String
    var checksum: String
    var title: String
    var formattedTitle: String {

        if title == "Mac" || title == "macOS" || title.contains("Jamf Connect") {
            return "Apple"
        } else if title == "GUI" {
            return "Java"
        } else {
            return title
        }
    }
    var systemName: String {

        switch formattedTitle {
        case "Apple":
            return "a.circle"
        case "Java":
            return "j.circle"
        case "Linux":
            return "l.circle"
        case "Manual":
            return "m.circle"
        case "RedHat":
            return "r.circle"
        case "Ubuntu":
            return "u.circle"
        case "Windows":
            return "w.circle"
        default:
            return "arrow.down.circle"
        }
    }
}
