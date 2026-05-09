//
//  TimeColumnView.swift
//  IOSDevuk26
//

import SwiftUI

/// A fixed-width column showing a session's start and end times.
struct TimeColumnView: View {
    let startTime: String
    let endTime: String

    var body: some View {
        VStack(alignment: .trailing) {
            Text(startTime)
                .bold()
                .monospacedDigit()
            Text(endTime)
                .secondaryTextStyle()
                .monospacedDigit()
        }
        .font(.caption)
        .frame(width: 44, alignment: .trailing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session start time \(startTime), session end time \(endTime)")
    }
}
