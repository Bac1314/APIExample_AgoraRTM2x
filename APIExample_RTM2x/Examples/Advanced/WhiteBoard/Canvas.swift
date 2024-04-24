//
//  Canvas.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/24.
//

import SwiftUI

struct Canvas: View {
    @Binding var currentDrawing: Drawing
    @Binding var drawings: [Drawing]
    
    var colors : [Color] = [.black, .blue, .red, .green, .orange]
    @State var selectedColor : Color = .black

    var onSubmitDrawing: (() -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: Canvas
            GeometryReader { geometry in
                ZStack {
                    // Previous Drawings
                    ForEach(drawings) { drawing in
                        Path { path in
                            addLine(drawing: drawing, toPath: &path)
                        }
                        .stroke(drawing.color, lineWidth: drawing.lineWidth)
                    }
                    
                    // Current Drawing
                    Path { path in
                        addLine(drawing: self.currentDrawing, toPath: &path)
                    }
                    .stroke(selectedColor, lineWidth: currentDrawing.lineWidth)
                }
                .background(Color.white)
                .gesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { value in
                            let currentPoint = value.location
                            currentDrawing.points.append(currentPoint)
                            print("id \(currentDrawing.id) \(currentPoint)")

                        }
                        .onEnded { value in
                            drawings.append(currentDrawing)
                            currentDrawing = Drawing()
                            currentDrawing.color = selectedColor
                            print("onEnded")
                            
       
                            self.onSubmitDrawing?()
                        }
                )
            }
            
            // MARK: Color selection
            HStack{
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .frame(width: 35)
                        .padding(3)
                        .foregroundStyle(color)
                        .padding(1)
                        .overlay(
                            Circle()
                                .stroke(color, lineWidth: selectedColor == color ? 2 : 0)
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedColor = color
                                currentDrawing.color = color
                            }
                        }
                }
            }
        }
//        .frame(width: 400, height: 800)
    }
    
    private func addLine(drawing: Drawing, toPath path: inout Path) {
        let points = drawing.points
        if points.count > 1 {
            for i in 0..<points.count-1 {
                let current = points[i]
                let next = points[i+1]
                path.move(to: current)
                path.addLine(to: next)
            }
        }
    }
}


#Preview {
    struct Preview: View {
        @State private var currentDrawing: Drawing = Drawing()
        @State private var drawings: [Drawing] = [Drawing]()
        
        var body: some View {
            Canvas(currentDrawing: $currentDrawing, drawings: $drawings)
        }
    }

    return Preview()
}
