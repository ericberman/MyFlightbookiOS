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
//  RemoteListViews.swift
//  MyFlightbookWatch
//
//  Recents, Totals and Currency pages. Each shows a list fetched from the iPhone; long-press refreshes.
//

import SwiftUI

private let rowBackground = Color(white: 0.878)
private let titleColor = Color(red: 0, green: 0.25, blue: 0.5)
private let secondaryColor = Color(white: 0.33)

private struct RemoteListView<Item, Row : View> : View {
    let title : LocalizedStringKey
    let emptyMessage : LocalizedStringKey
    let list : RemoteList<Item>
    let refresh : () -> Void
    @ViewBuilder let row : (Item) -> Row

    var body: some View {
        NavigationStack {
            List {
                if let error = list.error {
                    Text(error)
                } else if list.items?.isEmpty ?? false {
                    Text(emptyMessage)
                }
                ForEach(Array((list.items ?? []).enumerated()), id: \.offset) { _, item in
                    row(item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowBackground(RoundedRectangle(cornerRadius: 8).fill(rowBackground))
                }
            }
            .navigationTitle(title)
            .simultaneousGesture(LongPressGesture().onEnded { _ in refresh() })
        }
        .onAppear {
            if list.items == nil || list.isExpired {
                refresh()
            }
        }
    }
}

struct RecentsView : View {
    @EnvironmentObject private var model : WatchModel

    private static let dateFormatter : DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()

    var body: some View {
        RemoteListView(title: "WatchTitleRecents", emptyMessage: "WatchNoFlights", list: model.recents, refresh: model.refreshRecents) { item in
            VStack(alignment: .leading) {
                HStack {
                    Text(Self.dateFormatter.string(from: item.date)).font(.headline).foregroundStyle(titleColor)
                    Spacer(minLength: 0)
                    Text(item.totalTimeDisplay).font(.caption).foregroundStyle(secondaryColor)
                }
                Text(item.route).font(.caption2).foregroundStyle(secondaryColor)
                (Text(item.tailNumDisplay).bold() + Text(" " + item.comment))
                    .font(.caption).foregroundStyle(.black).lineLimit(3)
            }
        }
    }
}

struct TotalsView : View {
    @EnvironmentObject private var model : WatchModel

    var body: some View {
        RemoteListView(title: "WatchTitleTotals", emptyMessage: "WatchNoTotals", list: model.totals, refresh: model.refreshTotals) { item in
            VStack(alignment: .leading) {
                Text(item.title).font(.headline).foregroundStyle(titleColor).lineLimit(3)
                Text(item.valueDisplay).font(.caption).foregroundStyle(.black)
                Text(item.subDesc).font(.footnote).foregroundStyle(secondaryColor).lineLimit(3)
            }
        }
    }
}

struct CurrencyView : View {
    @EnvironmentObject private var model : WatchModel

    private func color(for state : MFBWebServiceSvc_CurrencyState) -> Color {
        switch state {
        case MFBWebServiceSvc_CurrencyState_NotCurrent: return .red
        case MFBWebServiceSvc_CurrencyState_GettingClose: return .blue
        case MFBWebServiceSvc_CurrencyState_OK: return Color(red: 0, green: 0.5, blue: 0)
        default: return .black
        }
    }

    var body: some View {
        RemoteListView(title: "WatchTitleCurrency", emptyMessage: "WatchNoCurrency", list: model.currency, refresh: model.refreshCurrency) { item in
            VStack(alignment: .leading) {
                Text(item.attribute).font(.headline).foregroundStyle(titleColor).lineLimit(2)
                Text(item.value).font(.caption).foregroundStyle(color(for: item.state)).lineLimit(2)
                Text(item.discrepancy).font(.footnote).foregroundStyle(secondaryColor)
            }
        }
    }
}
