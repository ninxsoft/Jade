//
//  Keychain.swift
//  Jade
//
//  Created by Nindi Gill on 2/12/21.
//

import Foundation

/// Helper Struct used to read and write Jamf ID credentials to and from the Keychain.
struct Keychain {

    /// Attempts to read the **com.ninxsoft.jade** keychain item, returning the corresponding username and password credentials.
    ///
    /// - Returns: A tuple containing the Jamf ID username and password.
    static func read() -> (username: String, password: String)? {

        guard let bundleIdentifier: String = Bundle.main.bundleIdentifier else {
            return nil
        }

        let query: [String: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: bundleIdentifier,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as [String: Any]

        var item: CFTypeRef?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == noErr else {
            return nil
        }

        // swiftlint:disable:next force_cast
        let coreFoundationDictionary: CFDictionary = item as! CFDictionary

        guard let dictionary: [String: Any] = coreFoundationDictionary as? [String: Any],
            let username: String = dictionary["acct"] as? String,
            let data: Data = dictionary["v_Data"] as? Data,
            let password: String = String(data: data, encoding: .utf8) else {
            return nil
        }

        return (username: username, password: password)
    }

    /// Attempts to write the passed in username and password to the **com.ninxsoft.jade** keychain item.
    ///
    /// - Parameters:
    ///   - username: The Jamf ID username.
    ///   - password: The Jamf ID password.
    ///
    /// - Returns: `true` if the operation was successful, otherwise `false`.
    static func update(username: String, password: String) -> Bool {

        guard let bundleIdentifier: String = Bundle.main.bundleIdentifier,
            let data: Data = password.data(using: .utf8) else {
            return false
        }

        let query: [String: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: bundleIdentifier
        ] as [String: Any]

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, nil)
        let exists: Bool = status == noErr

        if exists {

            let attributes: [String: Any] = [
                kSecAttrAccount: username,
                kSecValueData: data
            ] as [String: Any]

            let status: OSStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            return status == noErr
        } else {

            let attributes: [String: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: bundleIdentifier,
                kSecAttrAccount: username,
                kSecValueData: data
            ] as [String: Any]

            let status: OSStatus = SecItemAdd(attributes as CFDictionary, nil)
            return status == noErr
        }
    }
}
