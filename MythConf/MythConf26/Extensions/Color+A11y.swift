//
//  Color+A11y.swift
//  IOSDevuk26
//

import SwiftUI

extension View {
    /// Use this instead of `.foregroundStyle(.secondary)` — system `.secondary`
    /// resolves to `(138,138,142)` which fails WCAG AA (3.44:1) on white.
    func secondaryTextStyle() -> some View {
        foregroundStyle(Color.textSecondary)
    }
}
