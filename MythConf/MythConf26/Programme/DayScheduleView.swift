//
//  DayScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

/// A scrollable list of all time slots for a single conference day.
struct DayScheduleView: View {
    let sessions: [Session]
    /// Extra bottom padding so the floating countdown banner above the tab
    /// bar doesn't cover the last row.
    var bottomInset: CGFloat = 0

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sessions) { session in
                    if session.containsTalk {
                        ParallelSessionsRowView(session: session)
                    } else {
                        BreakRowView(session: session)
                    }
                    Divider()
                }
            }
            .padding(.bottom, bottomInset)
        }
    }
}
