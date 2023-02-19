/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2023 MyFlightbook, LLC
 
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
//  MyFlightbookWidgets.swift
//  MyFlightbookWidgets
//
//  Created by Eric Berman on 2/17/23.
//

import WidgetKit
import SwiftUI
import Intents

// MARK: Currency widget
struct CurrencyEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let currency : [SimpleCurrencyItem]?
    var errorDescription : String?
    
    // Get some sample items.  These are not localized because actual data is also not localized
    static func defaultCurrency() -> [SimpleCurrencyItem] {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.short
        var d : Date
        
        // #1: Simple passenger currency, expires in 40 days
        let sci1 = SimpleCurrencyItem()!
        d = Calendar.current.date(byAdding: .day, value: 40, to: Date())!
        sci1.attribute = "ASEL - Passengers"
        sci1.discrepancy = ""
        sci1.value = "Current Until: \(df.string(from: d))"
        sci1.state = MFBWebServiceSvc_CurrencyState_OK
        
        // #2: Simple night currency, expired
        let sci2 = SimpleCurrencyItem()!
        d = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        sci2.attribute = "ASEL - Night"
        sci2.discrepancy = "(Short by 3 landings)"
        sci2.value = "Expired: \(df.string(from: d))"
        sci2.state = MFBWebServiceSvc_CurrencyState_NotCurrent

        // #3: IFR currency, getting close
        let sci3 = SimpleCurrencyItem()!
        d = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        sci3.attribute = "IFR - Airplane"
        sci3.discrepancy = ""
        sci3.value = "Current Until: \(df.string(from: d))"
        sci3.state = MFBWebServiceSvc_CurrencyState_GettingClose
        return [sci1, sci2, sci3]
    }
}

struct CurrencyProvider: IntentTimelineProvider {
    @State var lastEntry : CurrencyEntry?
    
    func placeholder(in context: Context) -> CurrencyEntry {
        return CurrencyEntry(date: Date(), configuration: ConfigurationIntent(), currency: CurrencyEntry.defaultCurrency())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (CurrencyEntry) -> ()) {
        if (context.isPreview || lastEntry == nil) {
            completion(CurrencyEntry(date: Date(), configuration: configuration, currency: CurrencyEntry.defaultCurrency()))
        }
        else {
            completion(lastEntry!)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let svc = CurrencyCall() { (wsc) in
            if let cc = wsc as? CurrencyCall {
                let entry = CurrencyEntry(date: Date(), configuration: configuration, currency: cc.currencyList, errorDescription: cc.errorString)
                self.lastEntry = entry
                completion(Timeline(entries: [entry], policy: .atEnd))
            }
        }
        svc.makeCall()
    }
}

struct currencyRow : View {
    var curr : SimpleCurrencyItem
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing:0) {
                VStack {
                    Spacer()
                    Text(curr.attribute)
                        .font(.system(size: 17))
                        .padding([Edge.Set.trailing, Edge.Set.leading], 10)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    Spacer()
                }
                .frame(height: 40)
                VStack(spacing:0) {
                    Text(curr.value)
                        .font(.system(size: 17, weight: .bold))
                        .padding([Edge.Set.trailing], 10)
                        .padding([Edge.Set.top, Edge.Set.bottom], 0)
                        .foregroundColor(MyFlightbookCurrencyWidgetsEntryView.colorForState(state: curr.state))
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    Text(curr.discrepancy)
                        .font(.system(size: 10))
                        .foregroundColor(Color(UIColor.systemGray))
                        .padding([Edge.Set.top, Edge.Set.bottom], 0)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(height: 40)
            }
            Divider()
        }
        .padding([Edge.Set.top, Edge.Set.bottom], 0)
    }
}

struct MyFlightbookCurrencyWidgetsEntryView : View {
    var entry : CurrencyProvider.Entry
    
    static func colorForState(state : MFBWebServiceSvc_CurrencyState) -> Color? {
        switch (state) {
        case MFBWebServiceSvc_CurrencyState_OK:
            return Color.green
        case MFBWebServiceSvc_CurrencyState_GettingClose:
            return Color.blue
        case MFBWebServiceSvc_CurrencyState_NotCurrent:
            return Color.red
        case MFBWebServiceSvc_CurrencyState_NoDate:
            return nil
        default:
            return nil
        }
    }
    
    var body: some View {
        if (!(entry.errorDescription ?? "").isEmpty) {
            VStack {
                Text(entry.errorDescription!)
            }
        } else if (entry.currency?.isEmpty ?? false) {
            VStack {
                Text(String(localized: "No currency is available."))
            }
        } else {
            GeometryReader { geometry in
                LazyVStack(spacing:0) {
                    ForEach(entry.currency!, id:\.attribute) { sci in
                        currencyRow(curr: sci)
                    }
                }
            }
            .widgetURL(URL(string:"myflightbook://currency"))
        }
    }
}

struct MyFlightbookCurrencyWidget: Widget {
    let kind: String = "MyFlightbookCurrencyWidget"
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: CurrencyProvider()) { entry in
            MyFlightbookCurrencyWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName(String(localized: "CurrencyWidgetName"))
        .description(String(localized: "CurrencyWidgetDesc"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct MyFlightbookCurrencyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyFlightbookCurrencyWidgetsEntryView(entry: CurrencyEntry(date: Date(), configuration: ConfigurationIntent(), currency: CurrencyEntry.defaultCurrency()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

// MARK: Totals widget
struct TotalsEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let totals : [SimpleTotalItem]?
    var errorDescription : String?
    
    static func defaultTotals() -> [SimpleTotalItem] {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        let sti1 = SimpleTotalItem()!
        sti1.title = "ASEL"
        sti1.subDesc = "(67 landings, 32 day 12 night), 18 approaches"
        sti1.valueDisplay = "\(nf.string(for: 832.6)!)"

        let sti2 = SimpleTotalItem()!
        sti2.title = "Glider"
        sti2.subDesc = "(1 landing)"
        sti2.valueDisplay = "\(nf.string(for: 1.6)!)"

        let sti3 = SimpleTotalItem()!
        sti3.title = "Retract"
        sti3.subDesc = ""
        sti3.valueDisplay = "\(nf.string(for: 350.1)!)"

        return [sti1, sti2, sti3]
    }
}

struct TotalsProvider: IntentTimelineProvider {
    @State var lastEntry : TotalsEntry?
    
    func placeholder(in context: Context) -> TotalsEntry {
        return TotalsEntry(date: Date(), configuration: ConfigurationIntent(), totals: TotalsEntry.defaultTotals())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TotalsEntry) -> ()) {
        let entry = TotalsEntry(date: Date(), configuration: configuration, totals: TotalsEntry.defaultTotals())
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let svc = TotalsCall() { (wsc) in
            if let tc = wsc as? TotalsCall {
                let entry = TotalsEntry(date: Date(), configuration: configuration, totals: tc.totalsList)
                self.lastEntry = entry
                completion(Timeline(entries: [entry], policy: .atEnd))
            }
        }
        svc.makeCall()
    }
}

struct totalsRow : View {
    var t : SimpleTotalItem
    
    var body: some View {
        VStack {
            HStack {
                Text(t.title)
                    .font(.system(size: 14))
                    .padding([Edge.Set.top, Edge.Set.leading], 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text(t.valueDisplay)
                    .font(.system(size: 14, weight: .bold))
                    .padding([Edge.Set.top, Edge.Set.trailing], 10)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            Text(t.subDesc)
                .font(.system(size: 10))
                .foregroundColor(Color(UIColor.systemGray))
                .padding([Edge.Set.leading], 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            Spacer()
        }
        .padding(0)
        .frame(height: 46)
    }
}

struct MyFlightbookTotalsWidgetsEntryView : View {
    var entry: TotalsProvider.Entry

    var body: some View {
        if (!(entry.errorDescription ?? "").isEmpty) {
            VStack {
                Text(entry.errorDescription!)
            }
        } else if (entry.totals?.isEmpty ?? false) {
            VStack {
                Text(String(localized: "No totals are available."))
            }
        } else {
            GeometryReader { geometry in
                LazyVStack(spacing:0) {
                    ForEach(entry.totals!, id:\.title) { ti in
                        totalsRow(t : ti)
                    }
                }
            }
            .widgetURL(URL(string:"myflightbook://totals"))
        }
    }
}

struct MyFlightbookTotalsWidget: Widget {
    let kind: String = "MyFlightbookTotalsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: TotalsProvider()) { entry in
            MyFlightbookTotalsWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName(String(localized: "TotalsWidgetName"))
        .description(String(localized: "TotalsWidgetDesc"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct MyFlightbookTotalsWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyFlightbookTotalsWidgetsEntryView(entry: TotalsEntry(date: Date(), configuration: ConfigurationIntent(), totals: TotalsEntry.defaultTotals()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
