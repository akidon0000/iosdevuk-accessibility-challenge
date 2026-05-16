//
//  Time+A11y.swift
//  IOSDevuk26
//

import Foundation

extension String {
    /// Convert a 24h `"HH:mm"` time string into `"h:mm AM/PM"` for VoiceOver /
    /// Voice Control read-aloud. Always English AM/PM regardless of the system
    /// locale or the 24-hour preference, so VoiceOver never reads `"14:30"` as
    /// "fourteen thirty".
    /// Returns `self` unchanged if the input does not look like `"HH:mm"`.
    var spokenTime: String {
        let parts = split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              (0...23).contains(hour),
              (0...59).contains(minute)
        else { return self }
        let suffix = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, suffix)
    }
}
