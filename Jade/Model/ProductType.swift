//
//  ProductType.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import Foundation

enum ProductType: String, CaseIterable, Decodable, Identifiable {

    case jamfPro = "JAMF_PRO"
    case now = "JAMF_NOW"
    case school = "JAMF_SCHOOL"
    case connect = "JAMF_CONNECT"
    case privateAccess = "JAMF_PRIVATE_ACCESS"
    case protect = "JAMF_PROTECT"
    case threatDefense = "JAMF_THREAT_DEFENSE"
    case dataPolicy = "JAMF_DATA_POLICY"
    case pkiProxy = "JAMF_PKI_PROXY"
    case serverTools = "JAMF_PRO_SERVER_TOOLS"
    // special case
    case adcsConnector = "AD_CS_CONNECTOR"
    case composer = "COMPOSER"
    // special case
    case healthcareListener = "JAMF_HEALTHCARE_LISTENER"
    // special case
    case infrastructureManager = "JAMF_INFRASTRUCTURE_MANAGER"
    // special case
    case sccmPlugin = "SCCM_PLUGIN"

    static var allURLCases: [ProductType] {
        [.jamfPro, .now, .school, .connect, .privateAccess, .protect, .threatDefense, .dataPolicy, .pkiProxy, .serverTools, adcsConnector, .composer]
    }

    var id: String {
        rawValue
    }

    var description: String {
        switch self {
        case .jamfPro:
            return "Jamf Pro"
        case .now:
            return "Jamf Now"
        case .school:
            return "Jamf School"
        case .connect:
            return "Jamf Connect"
        case .threatDefense:
            return "Jamf Threat Defense"
        case .privateAccess:
            return "Jamf Private Access"
        case .protect:
            return "Jamf Protect"
        case .dataPolicy:
            return "Jamf Data Policy"
        case .pkiProxy:
            return "Jamf PKI Proxy"
        case .serverTools:
            return "Jamf Pro Server Tools"
        case .adcsConnector:
            return "AD CS Connector"
        case .composer:
            return "Composer"
        case .healthcareListener:
            return "Healthcare Listener"
        case .infrastructureManager:
            return "Infrastructure Manager"
        case .sccmPlugin:
            return "SCCM Plugin"
        }
    }

    var homepage: String {
        switch self {
        case .jamfPro:
            return "https://www.jamf.com/products/jamf-pro/"
        case .school:
            return "https://www.jamf.com/products/jamf-school/"
        case .now:
            return "https://www.jamf.com/products/jamf-now/"
        case .connect:
            return "https://www.jamf.com/products/jamf-connect/"
        case .privateAccess:
            return "https://www.jamf.com/products/jamf-private-access/"
        case .protect:
            return "https://www.jamf.com/products/jamf-protect/"
        case .threatDefense:
            return "https://www.jamf.com/products/jamf-threat-defense/"
        case .dataPolicy:
            return "https://www.jamf.com/products/jamf-data-policy/"
        case .pkiProxy:
            return "https://docs.jamf.com/pki-proxy/"
        case .serverTools:
            return "https://docs.jamf.com/technical-articles/Jamf_Pro_Server_Tools.html"
        case .adcsConnector:
            return "https://docs.jamf.com/ad-cs-connector/"
        case .composer:
            return "https://www.jamf.com/products/jamf-composer/"
        case .healthcareListener:
            return "https://marketplace.jamf.com/details/jamf-healthcare-listener/"
        case .infrastructureManager:
            return "https://docs.jamf.com/infrastructure-manager/"
        case .sccmPlugin:
            return "https://docs.jamf.com/plug-ins/sccm-jamf-pro-server/"
        }
    }

    var systemName: String {
        switch self {
        case .jamfPro:
            return "laptopcomputer.and.iphone"
        case .now:
            return "desktopcomputer"
        case .school:
            return "graduationcap"
        case .connect:
            return "person.text.rectangle"
        case .privateAccess:
            return "person.text.rectangle"
        case .protect:
            return "checkmark.shield"
        case .threatDefense:
            return "checkmark.shield"
        case .dataPolicy:
            return "scroll"
        case .pkiProxy:
            return "network"
        case .serverTools:
            return "wrench.and.screwdriver"
        case .adcsConnector:
            return "arrow.left.and.right"
        case .composer:
            return "shippingbox"
        case .healthcareListener:
            return "waveform.path.ecg"
        case .infrastructureManager:
            return "building"
        case .sccmPlugin:
            return "powerplug"
        }
    }

    var url: URL? {

        switch self {
        case .adcsConnector, .healthcareListener, .infrastructureManager, .sccmPlugin:
            return URL(string: "\(Product.baseURL)/current")
        default:
            let slug: String = rawValue.lowercased().replacingOccurrences(of: "_", with: "-")
            return URL(string: "\(Product.baseURL)/product/\(slug)")
        }
    }
}
