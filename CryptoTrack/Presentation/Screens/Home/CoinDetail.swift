//
//  CoinDetail.swift
//  CryptoTrack
//
//  Created by Quentin Gaillardet on 12/12/2023.
//

import SwiftUI

struct CoinDetail: View {
    let coin: Coin

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack{
                    Text(coin.name)
                        
                    Text("#\(coin.marketCapRank ?? 0)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(4)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                       
                }
            
                HStack{
                    Text((coin.currentPrice?.rounded().description ?? "") + Currency.usd.symbol)
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    if let marketCapChangePercentage24h = coin.marketCapChangePercentage24h {
                        Text("\(String(format: "%.2f", marketCapChangePercentage24h))%")
                            .font(.caption)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(4)
                            .background(marketCapChangePercentage24h > 0 ? Color.green : Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                       
                    }
                    
                }
                
                if let sparkline = coin.sparklineIn7d {
                    LineChart(allDataPoints: sparkline.price)
                        .frame(height: 200)
                        .padding(8)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Group {
                    HStack {
                        Text("Market Cap:")
                        Spacer()
                        Text(coin.marketCap?.rounded().description ?? "")
                    }

                    HStack {
                        Text("Fully Diluted Valuation:")
                        Spacer()
                        Text(coin.fullyDilutedValuation?.rounded().description ?? "")
                    }

                    HStack {
                        Text("Circulating Supply:")
                        Spacer()
                        Text(coin.circulatingSupply?.rounded().description ?? "")
                    }

                    
                }
                .font(.headline)

                // 24h Changes
                Group {
                    HStack {
                        Text("High 24h:")
                        Spacer()
                        Text(coin.high24h?.rounded().description ?? "")
                    }

                    HStack {
                        Text("Low 24h:")
                        Spacer()
                        Text(coin.low24h?.rounded().description ?? "")
                    }

                    HStack {
                        Text("Price Change 24h:")
                        Spacer()
                        Text(coin.priceChange24h?.rounded().description ?? "")
                    }

                }
                .font(.headline)
                
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack{
                    Text(coin.symbol)
                        .font(.headline)
                    
                    AsyncImage(url: URL(string: coin.image ?? "" )) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .padding(8)
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

struct LineChart: View {
    let allDataPoints: [Double]
    var timeFrames = [1, 3, 7] // List of available time frames

    @State private var selectedTimeFrameIndex = 2 // Default to 7 days

    var selectedTimeFrame: Int {
        return timeFrames[selectedTimeFrameIndex]
    }

    var filteredDataPoints: [Double] {
        let dataPointsPerDay = allDataPoints.count / 7 // Assuming 7 days, adjust accordingly
        let startIndex = max(allDataPoints.count - selectedTimeFrame * dataPointsPerDay, 0)
        return Array(allDataPoints.suffix(from: startIndex))
    }

    var body: some View {
        VStack {
            Picker("Select Time Frame", selection: $selectedTimeFrameIndex) {
                ForEach(Array(timeFrames.enumerated()), id: \.offset) { index, days in
                    Text("\(days) days")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 16)

            GeometryReader { geometry in
                HStack {
                    Path { path in
                        guard let minValue = filteredDataPoints.min(), let maxValue = filteredDataPoints.max(), maxValue > 0 else {
                            return
                        }

                        let logScale = geometry.size.height / (log10(maxValue) - log10(minValue))
                        let xOffset = (geometry.size.width - 80) / CGFloat(max(filteredDataPoints.count - 1, 1))

                        for (index, point) in filteredDataPoints.enumerated() {
                            let x = CGFloat(index) * xOffset
                            let y = CGFloat(log10(max(point, 0.001)) - log10(minValue)) * logScale
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                    Spacer()

                    VStack {
                        Text(String(format: "%.3f", pow(10, max(log10(filteredDataPoints.max() ?? 0), 0.001))))
                        Spacer()
                        Text(String(format: "%.3f", pow(10, ((log10(filteredDataPoints.max() ?? 0) + log10(filteredDataPoints.min() ?? 0)) / 2))))
                        Spacer()
                        Text(String(format: "%.3f", pow(10, log10(filteredDataPoints.min() ?? 0))))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }

            Text("\(selectedTimeFrame) days")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}





