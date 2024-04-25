//
//  Canvas.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/24.
//

import SwiftUI

enum CanvasTool: String {
    case pen, eraser, highlighter
}

struct Canvas: View {
    @Binding var currentDrawing: Drawing
    @Binding var drawings: [Drawing]
    
    var colors : [Color] = [.black, .blue, .red, .green, .orange]
    var penWidths : [CGFloat] = [3, 5, 7, 9]
    
    @State var selectedColor : Color = .black
    @State var selectedTool : CanvasTool = .pen
    @State var selectedPenWidth : CGFloat = 3
    @State var isSelectingColor : Bool = false
    @State var isSelectingWidth : Bool = false

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
                        .onTapGesture {
                            if selectedTool == .eraser {
                                if let index = drawings.firstIndex(where: {$0.id == drawing.id}) {
                                    drawings.remove(at: index)
                                }
                            }
                        }
                        
                    }
                    
                    // Current Drawing
                    Path { path in
                        addLine(drawing: self.currentDrawing, toPath: &path)
                    }
                    .stroke(selectedColor, lineWidth: currentDrawing.lineWidth)
                }
                .background(Color.white)
                .gesture(
                    DragGesture(minimumDistance: 0.1)
                        .onChanged { value in
                            if selectedTool == .pen {
                                let currentPoint = value.location
                                currentDrawing.points.append(currentPoint)
                            }
                        }
                        .onEnded { value in
                            if selectedTool == .pen {
                                drawings.append(currentDrawing)
                                currentDrawing = Drawing()
                                currentDrawing.color = selectedColor
                                currentDrawing.lineWidth = selectedPenWidth
                            
                                self.onSubmitDrawing?()
                            }
                        }
                )
            }
            
            // MARK: TOOL SELECTION
            HStack{
                Image(systemName: "pencil.tip")
                    .padding(.horizontal)
                    .foregroundStyle(selectedTool == .pen ? selectedColor : Color.black)
                    .scaleEffect(selectedTool == .pen ? CGSize(width: 1.5, height: 1.5) : CGSize(width: 1.0, height: 1.0))
                    .onTapGesture {
                        withAnimation {
                            if selectedTool == .pen {
                                withAnimation {
                                    isSelectingColor = false
                                    isSelectingWidth = true
                                }
                            }else {
                                selectedTool = .pen
                            }
                        }
                    }
                    
                
                Image(systemName: "eraser")
                    .padding(.horizontal)
                    .foregroundStyle(selectedTool == .eraser ? Color.accentColor : Color.black)
                    .scaleEffect(selectedTool == .eraser ? CGSize(width: 1.5, height: 1.5) : CGSize(width: 1.0, height: 1.0))
                    .onTapGesture {
                        withAnimation {
                            selectedTool = .eraser
                            isSelectingWidth = false
                            isSelectingColor = false
                        }
                    }
                
                Rectangle()
                    .frame(width: 1, height: 25)
                    .background(Color.black)
                
                
                Circle()
                    .fill(selectedColor)
                    .strokeBorder(
                        AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center, startAngle: .zero, endAngle: .degrees(360)),
                        lineWidth: 5
                    )
                    .frame(width: 35, height: 35)
                    .padding(.horizontal)
                    .onTapGesture {
                        withAnimation {                                    
                            isSelectingWidth = false
                            isSelectingColor = true
                        }
                    }
        
            }
            .font(.title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)

                        
            // MARK: Color selection
            if isSelectingColor {
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
                                    isSelectingColor = false
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                .offset(y: -80)
            }
            
            // MARK: Size Selection
            if isSelectingWidth {
                HStack{
                    ForEach(penWidths, id: \.self) { width in
                        HStack{
                            Circle()
                                .frame(width: width*3, height: width*3)
                                .foregroundColor(selectedColor)
                        }
                        .frame(width: 35)
                        .onTapGesture {
                            withAnimation {
                                selectedPenWidth = width
                                currentDrawing.lineWidth = width
                                isSelectingWidth = false
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                .offset(y: -80)
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
