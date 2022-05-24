//
//  PieChartView.swift
//
//
//  Created by Nazar Ilamanov on 4/23/21.
//

import SwiftUI

@available(OSX 10.15, *)
public struct PieChartView: View {
    public let values: [Double]
    public let names: [String]
    public let formatter: (Double) -> String
    
    public var colors: [Color]
    public var backgroundColor: Color
    public var foregroundColor: Color
    
    public var widthFraction: CGFloat
    public var innerRadiusFraction: CGFloat
    public var accentColor: Color
    public var accentLightColor: Color
    
    @State private var activeIndex: Int = -1
    
    var slices: [PieSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PieSliceData] = []
        
        for (i, value) in values.enumerated() {
            let degrees: Double = value * 360 / sum
            tempSlices.append(PieSliceData(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), text: String(format: "%.0f%%", value * 100 / sum), color: self.colors[i]))
            endDeg += degrees
        }
        return tempSlices
    }
    
    public init(values:[Double], names: [String], formatter: @escaping (Double) -> String, colors: [Color] = [Color.blue, Color.green, Color.orange],
                backgroundColor: Color = Color(red: 21 / 255, green: 24 / 255, blue: 30 / 255, opacity: 1.0),
                widthFraction: CGFloat = 0.75, innerRadiusFraction: CGFloat = 0.60,
                foregroundColor: Color = .black, accentColor: Color = Color.green, accentLightColor: Color = Color.green.opacity(0.6)) {
        self.values = values
        self.names = names
        self.formatter = formatter
        
        self.colors = colors
        self.backgroundColor = backgroundColor
        self.widthFraction = widthFraction
        self.innerRadiusFraction = innerRadiusFraction
        self.foregroundColor = foregroundColor
        self.accentLightColor = accentLightColor
        self.accentColor = accentColor
    }
    
    public var body: some View {
        GeometryReader { geometry in
            HStack {
                ZStack {
                    ForEach(0..<self.values.count) { i in
                        PieSlice(pieSliceData: self.slices[i])
                            .scaleEffect(self.activeIndex == i ? 1.03 : 1)
                            .animation(Animation.spring())
                    }
                    .frame(width: widthFraction * geometry.size.width, height: widthFraction * geometry.size.width)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let radius = 0.5 * widthFraction * geometry.size.width
                                let diff = CGPoint(x: value.location.x - radius, y: radius - value.location.y)
                                let dist = pow(pow(diff.x, 2.0) + pow(diff.y, 2.0), 0.5)
                                if (dist > radius || dist < radius * innerRadiusFraction) {
                                    self.activeIndex = -1
                                    return
                                }
                                var radians = Double(atan2(diff.x, diff.y))
                                if (radians < 0) {
                                    radians = 2 * Double.pi + radians
                                }
                                
                                for (i, slice) in slices.enumerated() {
                                    if (radians < slice.endAngle.radians) {
                                        self.activeIndex = i
                                        break
                                    }
                                }
                            }
                            .onEnded { value in
                                self.activeIndex = -1
                            }
                    )
                    Circle()
                        .fill(self.backgroundColor)
                        .frame(width: widthFraction * geometry.size.width * innerRadiusFraction, height: widthFraction * geometry.size.width * innerRadiusFraction)
                    
                    VStack(spacing: 4) {
                        Text("Total".uppercased())
                            .font(.system(size: 13))
                            .foregroundColor(Color.gray)
                        Text(self.formatter(self.activeIndex == -1 ? values.reduce(0, +) : values[self.activeIndex]))
                            .font(.system(size: 28)).bold().foregroundColor(accentColor)
                        Text(self.activeIndex == -1 ? "" : names[self.activeIndex].uppercased())
                            .font(.system(size: 13))
                            .foregroundColor(Color.gray)
                    }
                    
                }
                HStack {
                    Spacer()
                PieChartRows(colors: self.colors, names: self.names, values: self.values.map { self.formatter($0) },
                             percents: self.values.map { String(format: "%.0f%%", $0 * 100 / self.values.reduce(0, +)) }, accentColor: accentColor, accentLightColor: accentLightColor).padding(20)
                    Spacer()
                }
            }
            .background(self.backgroundColor)
            .foregroundColor(self.foregroundColor)
        }
    }
}

@available(OSX 10.15, *)
struct PieChartRows: View {
    var colors: [Color]
    var names: [String]
    var values: [String]
    var percents: [String]
    var accentColor: Color
    var accentLightColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0..<self.values.count) { i in
                HStack(alignment: .center, spacing: 30) {
                    Circle()
                        .fill(self.colors[i])
                        .frame(width: 20, height: 20)
                    
                    Text(self.percents[i]).font(.system(size: 24))
                        .foregroundColor(accentColor).bold()
                    
                    Text(self.names[i])
                    Spacer()
                    Button {
                        //action
                    } label: {
                        Image("arrow")
                            .frame(width: 34, height: 34, alignment: .center)
                            .background(accentLightColor).clipShape(Circle())
                    }

                }
            }
        }.frame(width: 400, height: .infinity, alignment: .leading)
    }
}

@available(OSX 10.15.0, *)
struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(values: [1300, 500, 300], names: ["Ordini Temporanei", "Ordini inviati", "Ordini sospesi"],
                     formatter: {value in String(format: "$%.2f", value)}, backgroundColor: .white,
                     widthFraction: 0.3, foregroundColor: .black, accentColor: Color.blue, accentLightColor: Color.blue.opacity(0.5))
        .previewLayout(.fixed(width: 1100, height: 330))
        
    }
}


