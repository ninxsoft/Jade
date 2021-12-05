//
//  DownloadView.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import CryptoKit
import SwiftUI

struct DownloadView: View {

    private enum DownloadState: String {
        case downloading = "Downloading..."
        case validating = "Validating Checksum..."
        case completed = "Download Complete!"

        var text: String {
            rawValue
        }
    }

    private enum DownloadResult: String {
        case success = "Success"
        case error = "Error"

        var color: Color {
            switch self {
            case .success:
                return .accentColor
            case .error:
                return .red
            }
        }
    }

    @Binding var product: Product?
    @Binding var downloadLink: DownloadLink?
    @ObservedObject var webView: WebView
    var destinationURL: URL?
    @Binding var sheetPresented: Bool
    @State private var downloadState: DownloadState = .downloading
    @State private var downloadResult: DownloadResult?
    @State private var downloadPercentage: Double = 0
    @ViewBuilder var progressView: some View {
        if let downloadResult: DownloadResult = downloadResult {
            ProgressView(value: downloadResult == .success ? 100 : 0, total: 100)
        } else if downloadState == .downloading {
            ProgressView(value: downloadPercentage, total: 100)
        } else if downloadState == .validating {
            ProgressView()
        }
    }
    private let width: CGFloat = 300
    private let height: CGFloat = 125
    private var downloadHeading: String {

        guard let product: Product = product else {
            return ""
        }

        let string: String = "\(product.type.description) \(product.version)"
        return string
    }
    private var downloadDescription: String {

        guard let downloadResult: DownloadResult = downloadResult else {
            return downloadState == .downloading ? "\(downloadPercentage)%" : ""
        }

        switch downloadResult {
        case .success:
            return downloadState == .completed ? "Successfully downloaded file." : ""
        case .error:
            return "There was an error \(downloadState == .validating ? "validating" : "downloading") the file."
        }
    }

    var body: some View {
        VStack {
            Text(downloadHeading)
                .foregroundColor(.primary)
                .font(.title2)
            Text(downloadState.text)
            progressView
                .progressViewStyle(.linear)
                .padding(.horizontal)
            Text(downloadDescription)
                .foregroundColor(downloadResult?.color ?? .primary)
                .lineLimit(nil)
            Spacer()
            Button(downloadState == .completed ? "Close" : "Cancel") {
                webView.stopLoading()
                downloadLink = nil
                sheetPresented = false
            }
        }
        .frame(width: width, height: height)
        .padding()
        .onAppear {
            Task {
                await downloadProduct()
            }
        }
    }

    private func downloadProduct() async {

        downloadState = .downloading

        guard let cookie: HTTPCookie = webView.cookie else {
            webView.refreshCookie() ; return
        }

        guard let url: URL = getURL(product: product, downloadLink: downloadLink),
            let destinationURL: URL = destinationURL else {
            downloadResult = .error ; return
        }

        HTTPCookieStorage.shared.setCookie(cookie)

        do {
            let urlSession: URLSession = URLSession(configuration: .default)
            let (data, _): (Data, URLResponse) = try await urlSession.data(from: url)
            let dictionary: [String: Any] = try JSONDecoder().decode([String: String].self, from: data)

            guard let string: String = dictionary["url"] as? String,
                let signedURL: URL = URL(string: string) else {
                downloadResult = .error ; return
            }

            let (asyncBytes, urlResponse): (URLSession.AsyncBytes, URLResponse) = try await URLSession.shared.bytes(from: signedURL)
            let length: Int64 = urlResponse.expectedContentLength
            var downloadedData: Data = Data()
            downloadedData.reserveCapacity(Int(length))
            var localDownloadPercentage: Int = 0

            for try await byte in asyncBytes {
                downloadedData.append(byte)
                let currentProgress: Int = Int(Double(downloadedData.count) / Double(length) * 100)

                if localDownloadPercentage != currentProgress {
                    localDownloadPercentage = currentProgress
                    downloadPercentage = Double(currentProgress)
                }
            }

            guard let destination: URL = getDestination(destinationURL, using: urlResponse.suggestedFilename),
                write(downloadedData, to: destination) else {
                downloadResult = .error ; return
            }

            downloadState = .validating

            guard validateChecksum(for: destination, against: downloadLink?.checksum) else {
                downloadResult = .error ; return
            }

            NSWorkspace.shared.activateFileViewerSelecting([destination])
            downloadResult = .success
            downloadState = .completed
        } catch {
            downloadResult = .error
            print(error.localizedDescription)
        }
    }

    private func getURL(product: Product?, downloadLink: DownloadLink?) -> URL? {

        guard let product: Product = product,
            let downloadLink: DownloadLink = downloadLink else {
            return nil
        }

        let string: String = "\(Product.baseURL)/\(product.id)/download-links/\(downloadLink.id)/signed-url"

        guard let url: URL = URL(string: string) else {
            return nil
        }

        return url
    }

    private func getDestination(_ destinationURL: URL, using filename: String?) -> URL? {

        guard let filename: String = filename else {
            return nil
        }

        let url: URL = destinationURL.appendingPathComponent(filename)
        return url
    }

    private func write(_ data: Data, to url: URL) -> Bool {

        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }

            try data.write(to: url)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    private func validateChecksum(for url: URL, against checksum: String?) -> Bool {

        guard let checksum: String = checksum else {
            return false
        }

        do {
            let fileHandle: FileHandle = try FileHandle(forReadingFrom: url)
            var hasher: SHA256 = SHA256()

            while autoreleasepool(
                invoking: {
                    let data: Data = fileHandle.readData(ofLength: SHA256.blockByteCount)

                    guard !data.isEmpty else {
                        return false
                    }

                    hasher.update(data: data)
                    return true
                }
            ) { }

            let digest: SHA256.Digest = hasher.finalize()
            let fileChecksum: String = digest.map { String(format: "%02hhx", $0) }.joined()
            return fileChecksum == checksum
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadView(product: .constant(.example), downloadLink: .constant(.example), webView: WebView(), sheetPresented: .constant(true))
    }
}
