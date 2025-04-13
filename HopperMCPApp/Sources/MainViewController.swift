//
//  MainViewController.swift
//  HopperMCP
//
//  Created by JH on 2025/4/13.
//

import SwiftUI

final class MainViewController: NSHostingController<MainView> {
    init() {
        super.init(rootView: .init())
        sizingOptions = .preferredContentSize
    }

    @available(*, unavailable)
    @MainActor @preconcurrency dynamic required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
