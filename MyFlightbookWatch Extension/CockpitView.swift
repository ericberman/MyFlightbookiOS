/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2015-2026 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  CockpitView.swift
//  MyFlightbookWatch
//

import SwiftUI

struct CockpitView : View {
    @EnvironmentObject private var model : WatchModel

    // An unknown stage (nothing meaningful from the phone yet) is shown as unstarted so that Start is always available.
    private var stage : NewFlightStages {
        let stage = model.status?.flightStage ?? .unknown
        return stage == .unknown ? .unstarted : stage
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    switch stage {
                    case .unstarted:
                        Button("WatchStart") { model.startFlight() }
                            .frame(maxWidth: .infinity)
                    case .inprogress:
                        inProgress
                    case .done:
                        Text("WatchFlightSubmitted")
                    case .unknown:
                        EmptyView() // unreachable: folded into .unstarted above
                    }
                    gps
                }
                .padding(.horizontal, 8)
            }
            .navigationTitle("WatchTitleNewFlight")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { model.requestStatus() }
        .alert("", isPresented: $model.showFlightSubmitted) {
            Button("OK") {}
        } message: {
            Text("WatchFlightSubmitted")
        }
        .alert("Error", isPresented: Binding(get: { model.cockpitError != nil }, set: { if !$0 { model.cockpitError = nil } })) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(model.cockpitError ?? "")
        }
    }

    private var inProgress : some View {
        let status = model.status
        return VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Button("WatchStop", role: .destructive) { model.endFlight() }
                Button {
                    model.pausePlay()
                } label: {
                    Image(systemName: (status?.isPaused ?? false) ? "play.fill" : "pause.fill")
                }
                .frame(width: 50)
            }
            HStack {
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    let seconds = Int(model.elapsedSeconds(at: context.date))
                    Text(String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60))
                        .font(.title3.monospacedDigit())
                }
                Spacer(minLength: 0)
                if status?.isRecording ?? false {
                    Image(systemName: "record.circle.fill").foregroundStyle(.red)
                }
            }
            Text(status?.flightstatus ?? "").font(.caption)
        }
    }

    private var gps : some View {
        let status = model.status
        func display(_ s : String?) -> String { (s?.isEmpty ?? true) ? "--" : s! }
        return HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text(display(status?.latDisplay))
                Text(display(status?.lonDisplay))
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing) {
                Text(display(status?.speedDisplay))
                Text(display(status?.altDisplay))
            }
        }
        .font(.footnote)
    }
}

#Preview {
    CockpitView().environmentObject(WatchModel())
}

private func previewModel(_ stage : NewFlightStages) -> WatchModel {
    let model = WatchModel()
    let status = SharedWatch()
    status.flightStage = stage
    status.isRecording = true
    status.flightstatus = "In flight"
    status.elapsedSeconds = 3725
    status.latDisplay = "47.6062N"
    status.lonDisplay = "122.3321W"
    status.speedDisplay = "112 kt"
    status.altDisplay = "3,500 ft"
    model.status = status
    model.statusUpdated = Date()
    return model
}

#Preview("Unstarted") {
    CockpitView().environmentObject(previewModel(.unstarted))
}

#Preview("In progress") {
    CockpitView().environmentObject(previewModel(.inprogress))
}

#Preview("Done") {
    CockpitView().environmentObject(previewModel(.done))
}
