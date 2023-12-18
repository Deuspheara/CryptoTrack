//
//  SparklineView.swift
//  CryptoTrack
//
//  Created by Quentin Gaillardet on 13/12/2023.
//

import SwiftUI

struct SparklineView: View {
    let dataPoints: [Double]
    let lineColor : Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard let minValue = dataPoints.min(), let maxValue = dataPoints.max() else {
                    return
                }

                let scale = geometry.size.height / CGFloat(maxValue - minValue)
                let xOffset = geometry.size.width / CGFloat(max(dataPoints.count - 1, 1))

                for (index, point) in dataPoints.enumerated() {
                    let x = CGFloat(index) * xOffset
                    let y = CGFloat(point - minValue) * scale
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(lineColor, lineWidth: 2)
        }
    }
}

#Preview {
    SparklineView(dataPoints: [150.5, 152.3, 155.6, 153.2, 149.1, 151.5, 148.6, 152.7, 149.2, 153.8, 150.6, 155.2, 153.1, 156.7, 152.2, 155.1, 150.3, 157.6, 153.2, 159.1, 156.8, 160.5, 158.8, 162.4, 159.9, 163.6, 163.2, 163.9, 163.5, 167.1, 163.8, 168.5, 166.2], lineColor: Color.red)

}
