//
//  CredentialsView.swift
//  Jade
//
//  Created by Nindi Gill on 2/12/21.
//

import SwiftUI

struct CredentialsView: View {

    private enum ValidationResult: String {
        case none = "None"
        case valid = "Valid"
        case error = "Error"

        var text: String {
            switch self {
            case .none:
                return ""
            case .valid:
                return "Credentials are valid!"
            case .error:
                return "Error validating credentials!"
            }
        }

        var color: Color {
            switch self {
            case .none:
                return .clear
            case .valid:
                return .accentColor
            case .error:
                return .red
            }
        }
    }

    @ObservedObject var webView: WebView
    @Binding var sheetPresented: Bool
    @State private var validating: Bool = false
    @State private var validationResult: ValidationResult = .none
    @ViewBuilder var form: some View {
        Form {
            TextField(text: $webView.username, prompt: Text("Jamf ID username")) {
                Text("Username:")
            }
            .disabled(validating)
            SecureField(text: $webView.password, prompt: Text("Jamf ID password")) {
                Text("Password:")
            }
            .disabled(validating)
            if validating {
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.small)
            } else {
                Text(validationResult.text)
                    .foregroundColor(validationResult.color)
            }
        }
    }
    private let width: CGFloat = 300
    private let height: CGFloat = 150
    private let padding: CGFloat = 5

    var body: some View {
        VStack {
            Text("Jamf ID Credentials")
                .foregroundColor(.primary)
                .font(.title2)
            form
                .focusable(false)
            Spacer()
            HStack {
                Button(validating ? "Cancel" : "Validate") {
                    Task {
                        validateCredentials()
                    }
                }
                .disabled(webView.username.isEmpty || webView.password.isEmpty)
                Button("Close") {
                    close()
                }
                .disabled(validating)
            }
        }
        .frame(width: width, height: height)
        .padding()
        .onChange(of: webView.cookie) { cookie in
            validating = false
            validationResult = cookie != nil ? .valid : .error
        }
    }

    private func validateCredentials() {

        validating.toggle()

        if validating {
            webView.refreshCookie()
        } else {
            webView.stopLoading()
            webView.cookie = .none
        }
    }

    private func close() {
        _ = Keychain.update(username: webView.username, password: webView.password)
        sheetPresented = false
    }
}

struct CredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsView(webView: WebView(), sheetPresented: .constant(true))
    }
}
