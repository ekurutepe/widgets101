//
//  MediumWidget.swift
//  CoronaWidgetExtension
//
//  Created by Engin Kurutepe on 26.11.20.
//

import SwiftUI
import WidgetKit

struct MediumWidget: View {
    var entry: SimpleEntry
    var body: some View {
        VStack(spacing:0) {
            TopBar()
            VStack(alignment: .leading, spacing: 0){
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("🦠 Germany: ")
                        HStack{
                            Spacer()
                            Text("\(entry.germanyCount)")
                        }
                    }
                    .padding(.all, 5)
                    .background(Color.gray)
                    .cornerRadius(6)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("🦠 \(entry.regionName)")
                        HStack{
                            Spacer()
                            Text("\(entry.incidence, specifier: "%.1f")")
                        }
                    }
                    .padding(.all, 5)
                    .background(Color.gray)
                    .cornerRadius(6)
                }
                Spacer()
                Text(entry.date, style: .date)
                    .font(.footnote)
            }
            .padding(.all, 10)
        }
        .background(RadialGradient(gradient: Gradient(colors: [Color.white, Color.gray]), center: .center, startRadius: 0.2*entry.size.width, endRadius: 0.8*entry.size.width))
    }
}

struct MediumWidget_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidget(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), size: CGSize(width: 360, height: 180), germanyCount: 1234, regionName: "Steglitz", incidence: 234))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

