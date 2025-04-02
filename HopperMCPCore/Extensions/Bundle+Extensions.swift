import Foundation

extension Bundle {
    var name: String {
        (infoDictionary?["CFBundleName"] as? String) ?? "HopperMCP"
    }

    var shortVersionString: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var copyright: String? {
        infoDictionary?["NSHumanReadableCopyright"] as? String
    }
}
