//
//  StatusBarController.swift
//  HopperMCPApp
//
//  Created by JH on 2025/4/9.
//

import AppKit
import SwiftUI
import MacControlCenterUI
import MenuBarExtraAccess

struct MenuView: View {
    @Environment(\.openSettings) var openSettings

    @Binding var isMenuPresented: Bool

    @State private var isCommandsDisabled = false
    @State private var darkMode: Bool = true
    @State private var nightShift: Bool = true
    @State private var trueTone: Bool = true
    @State private var volume: CGFloat = 0.75
    @State private var brightness: CGFloat = 0.5
    @State private var audioOutputSelection: MenuEntry.ID? = MockData.audioOutputsDefault
    @State private var airPodsOptionSelection: MenuEntry.ID? = MockData.airPodsOptionsDefault
    @State private var isWiFiExpanded = true
    @State private var wiFiSelection: MenuEntry.ID? = MockData.wiFiNetworksDefault
    @State private var audioOutputs: [MenuEntry] = MockData.audioOutputs
    @State private var airPodsOptions: [MenuEntry] = MockData.airPodsOptions
    @State private var wiFiNetworks: [MenuEntry] = MockData.wiFiNetworks
    @State private var isSafariEnabled: Bool = true
    @State private var isMusicEnabled: Bool = true
    @State private var isXcodeEnabled: Bool = false

    var body: some View {
        MacControlCenterMenu(isPresented: $isMenuPresented) {
            MenuSection("Display", divider: false)

            MenuSlider(
                value: $brightness,
                image: Image(systemName: "sun.max.fill")
            )
            .disabled(isCommandsDisabled)
            .frame(minWidth: sliderWidth)

            HStack {
                MenuCircleToggle(
                    isOn: $darkMode,
                    controlSize: .prominent,
                    style: .init(
                        image: Image(systemName: "airplayvideo"),
                        color: .white,
                        invertForeground: true
                    )
                ) {
                    Text("Dark Mode")
                }
                MenuCircleToggle(
                    isOn: $nightShift,
                    controlSize: .prominent,
                    style: .init(
                        image: Image(systemName: "sun.max.fill"),
                        color: .orange
                    )
                ) {
                    Text("Night Shift")
                }
                MenuCircleToggle(
                    isOn: $trueTone,
                    controlSize: .prominent,
                    style: .init(
                        image: Image(systemName: "sun.max.fill"),
                        color: .blue
                    )
                ) {
                    Text("True Tone")
                }
                .disabled(isCommandsDisabled)
            }
            .frame(height: 80)

            MenuSection("Sound")

            MenuVolumeSlider(value: $volume)
                .frame(minWidth: sliderWidth)

            MenuCommand("Sound Settings...") {
                print("Sound Settings clicked")
            }

            MenuSection("Output")

            MenuList(audioOutputs, selection: $audioOutputSelection) { item, isSelected, itemClicked in
                if item.name.contains("AirPods Max") {
                    HighlightingMenuDisclosureGroup(
                        style: .menuItem,
                        initiallyExpanded: false,
                        labelHeight: .controlCenterIconItem,
                        toggleVisibility: .always, // <-- try setting to .onHover!
                        label: {
                            MenuCircleToggle(isOn: .constant(isSelected), image: item.image) {
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    HStack(spacing: 2) {
                                        Text("82%")
                                        Image(systemName: "battery.75", variableValue: 0.82)
                                    }
                                    .frame(height: 10)
                                    .opacity(0.7)
                                }
                            } onClick: {
                                _ in itemClicked()
                            }
                        }, content: {
                            MenuList(airPodsOptions, selection: $airPodsOptionSelection) { item, isSelected, itemClicked in
                                MenuToggle(
                                    isOn: .constant(isSelected),
                                    style: .checkmark()
                                ) {
                                    HStack {
                                        item.image
                                        Text(item.name).font(.system(size: 12))
                                        Spacer()
                                    }
                                } onClick: {
                                    _ in itemClicked()
                                }
                            }
                        }
                    )
                    .disabled(isCommandsDisabled)
                } else {
                    MenuToggle(isOn: .constant(isSelected), image: item.image) {
                        Text(item.name)
                    } onClick: { _ in itemClicked() }
                }
            }

            MenuDisclosureSection("Wi-Fi Network", isExpanded: $isWiFiExpanded) {
                MenuScrollView(maxHeight: 135) {
                    MenuList(wiFiNetworks, selection: $wiFiSelection) { item in
                        MenuToggle(image: item.image) {
                            Text(item.name)
                        }
                    }
                    .disabled(isCommandsDisabled)
                }
            }

            MenuSection("Custom Icons")
            MenuToggle("Safari", isOn: $isSafariEnabled, style: .icon(appIcon(for: "com.apple.Safari")))
            MenuToggle("Music", isOn: $isMusicEnabled, style: .icon(appIcon(for: "com.apple.Music")))
            MenuToggle("Xcode", isOn: $isXcodeEnabled, style: .icon(appIcon(for: "com.apple.dt.Xcode")))
                .disabled(isCommandsDisabled)

            MenuSection("Debug")
                .disabled(isCommandsDisabled)

            MenuCircleToggle(
                "Disable Some Menu Items",
                isOn: $isCommandsDisabled,
                image: Image(systemName: "rectangle.slash")
            )

            Divider()

            MenuCommand {
//                showStandardAboutWindow()
            } label: {
                Text("About") // custom label view
            }
            .disabled(isCommandsDisabled)

            MenuCommand {
                openSettings()
            } label: {
                Text("Settings...") // custom label view
            }

            Divider()

            MenuCommand("Quit") {
//                quit()
            }
        }
    }
}

/// Returns the icon image for the application with the given bundle ID.
/// If the application does not exist or cannot be found, a blank image placeholder is returned.
func appIcon(for bundleID: String) -> Image {
    if let bundle = Bundle(identifier: bundleID),
       let iconName = bundle.infoDictionary?["CFBundleIconFile"] as? String,
       let icon = bundle.image(forResource: iconName) {
        return Image(nsImage: icon)
    } else if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID),
              let bundle = Bundle(url: appURL),
              let iconName = bundle.infoDictionary?["CFBundleIconFile"] as? String,
              let icon = bundle.image(forResource: iconName) {
        return Image(nsImage: icon)
    } else if let defaultIcon = NSImage(systemSymbolName: "app", accessibilityDescription: nil) {
        return Image(nsImage: defaultIcon)
    } else {
        return Image(systemName: "square")
    }
}

/// Menu entry metadata.
struct MenuEntry: Hashable, Identifiable {
    let name: String
    let image: Image
    let imageColor: Color?

    /// Identifiable
    var id: String { name }

    /// Hashable - custom since Image isn't Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(name: String, image: Image, imageColor: Color? = nil) {
        self.name = name
        self.image = image
        self.imageColor = imageColor
    }

    init(name: String, systemImage: String, imageColor: Color? = nil) {
        self.name = name
        self.image = Image(systemName: systemImage)
        self.imageColor = imageColor
    }
}

/// Based on macOS Control Center slider width
let sliderWidth: CGFloat = 270

/// Mock data for the demo app UI.
enum MockData {
    static let audioOutputsDefault: MenuEntry.ID = "Tim's AirPods Max"
    static let audioOutputs: [MenuEntry] = [
        .init(name: "MacBook Pro Speakers", systemImage: "laptopcomputer"),
        .init(name: "Display Audio", systemImage: "speaker.wave.2.fill"),
        .init(name: "Tim's AirPods Max", systemImage: "airpodsmax"),
        .init(name: "AppleTV", systemImage: "appletv.fill"),
    ]

    static let airPodsOptionsDefault: MenuEntry.ID = "Off"
    static let airPodsOptions: [MenuEntry] = [
        .init(name: "Off", systemImage: "person.fill"),
        .init(name: "Noise Cancellation", systemImage: "person.crop.circle.fill"),
        .init(name: "Transparency", systemImage: "person.wave.2.fill"),
    ]

    static let wiFiNetworksDefault: MenuEntry.ID = "Wi-Fi Art Thou Romeo"
    static let wiFiNetworks: [MenuEntry] = [
        .init(name: "Wi-Fi Art Thou Romeo", image: .randomWiFiImage()),
        .init(name: "Drop It Like It's Hotspot", image: .randomWiFiImage()),
        .init(name: "Panic At The Cisco", image: .randomWiFiImage()),
        .init(name: "Lord Of The Pings", image: .randomWiFiImage()),
        .init(name: "Hide Yo Kids Hide Yo Wi-Fi", image: .randomWiFiImage()),
        .init(name: "DLINK45892", image: .randomWiFiImage()),
    ]
}

extension Image {
    /// For purposes of demonstration, generate a WiFi image with a random signal strength.
    static func randomWiFiImage() -> Image {
        Image(systemName: "wifi", variableValue: Double.random(in: 0.2 ... 1.0))
    }
}
