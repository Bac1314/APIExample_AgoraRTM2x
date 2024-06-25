//
//  Canvas.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/24.
//

import SwiftUI

enum CanvasTool: String {
    case pen, eraser, marker, select
}

enum CanvasAction {
    case delete(UUID)
    case update(DrawingPoint)
    case move(DrawingPoint)
    case submitNewDrawing(Drawing) // Can be empty points (just drawing) or full of points (for moving drawing)
    case submitFinishedDrawing(Drawing)
}

struct Canvas: View {
    
    @Binding var currentDrawing: Drawing
    @Binding var drawings: [Drawing]
    
    var colors : [Color] = [.black, .blue, .red, .green, .orange]
    var penWidths : [CGFloat] = [3, 5, 7, 9]
    
    @State var selectedColor : Color = .black
    @State var selectedTool : CanvasTool = .pen
    @State var selectedPenWidth : CGFloat = 5
//    @State var selectedDrawing : Drawing = Drawing()
    @State var isSelectingColor : Bool = false
    @State var isSelectingWidth : Bool = false
    
    var onCanvasUserAction: ((CanvasAction) -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: CANVAS
            GeometryReader { geometry in
                ZStack {
                    //MARK: Previous Drawings
                    ForEach(drawings) { drawing in
                        Path { path in
                            addLine(drawing: drawing, toPath: &path)
                        }
                        .stroke(drawing.color, lineWidth: drawing.lineWidth)
                        .onTapGesture {
                            if selectedTool == .eraser {
                                if let index = drawings.firstIndex(where: {$0.id == drawing.id}) {
                                    self.onCanvasUserAction?(.delete(drawings[index].id))
                                    drawings.remove(at: index)
                                }
                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0.1)
                                .onChanged { value in
                                    if selectedTool == .select {
                                        if let index = drawings.firstIndex(where: {$0.id == drawing.id}) {
                                            currentDrawing = drawings[index]
                                        }
                                        
                                        let xOffset = value.location.x - value.startLocation.x
                                        let yOffset = value.location.y - value.startLocation.y
                                        
                                        // Update currentDrawing with new moving points
                                        currentDrawing.points = drawing.points.map { point in
                                            CGPoint(x: point.x + xOffset, y: point.y + yOffset).roundTo2Decimals()
                                        }
                                    }
                                }
                                .onEnded { value in
                                    if selectedTool == .select {
                                        if let index = drawings.firstIndex(where: {$0.id == drawing.id}) {
                                            self.onCanvasUserAction?(.delete(drawings[index].id))
                                            self.onCanvasUserAction?(.submitNewDrawing(currentDrawing)) // To send to remote user
                                            self.onCanvasUserAction?(.submitFinishedDrawing(currentDrawing)) // For local to update to cloud
                                            
                                            drawings.remove(at: index)
                                            drawings.append(currentDrawing)
                                            currentDrawing = Drawing()
                                        }
                                    }
                                }
                        )
                        .disabled(selectedTool == .pen)
                        
                        
                    }
                    
                    // MARK: Current Drawing Path
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
                                let currentPoint = value.location.roundTo2Decimals()
                                currentDrawing.points.append(currentPoint)

                                if currentDrawing.points.count == 1 {
                                    self.onCanvasUserAction?(.submitNewDrawing(currentDrawing))
                                }else {
                                    self.onCanvasUserAction?(.update(DrawingPoint(id: currentDrawing.id, point: currentPoint)))
                                }
                            }
                        }
                        .onEnded { value in
                            if selectedTool == .pen {
                                self.onCanvasUserAction?(.submitFinishedDrawing(currentDrawing))
                                drawings.append(currentDrawing)
                                currentDrawing = Drawing()
                                currentDrawing.color = selectedColor
                                currentDrawing.lineWidth = selectedPenWidth
                            }
                        }
                )
            }
            .zIndex(1.0)

                     
            // MARK: TOOL SELECTION VIEWS
            VStack{
            
                // MARK: Popup Color selection
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
                }
                
                // MARK: Popup Size Selection
                if isSelectingWidth {
                    HStack{
                        ForEach(penWidths, id: \.self) { width in
                            HStack{
                                Circle()
                                    .frame(width: width*3, height: width*3)
                                    .foregroundColor(selectedColor)
                                    .padding(4)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor, lineWidth: selectedPenWidth == width ? 2 : 0)
                                    )
                                
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
                }
                
                // MARK: Main TOOL SELECTION
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
                                        isSelectingWidth.toggle()
                                    }
                                }else {
                                    selectedTool = .pen
                                }
                            }
                        }
                    
                    
                    Image(systemName: "eraser")
                        .padding(.horizontal)
                        .foregroundStyle(selectedTool == .eraser ? selectedColor : Color.black)
                        .scaleEffect(selectedTool == .eraser ? CGSize(width: 1.5, height: 1.5) : CGSize(width: 1.0, height: 1.0))
                        .onTapGesture {
                            withAnimation {
                                selectedTool = .eraser
                                isSelectingWidth = false
                                isSelectingColor = false
                            }
                        }
                    
                    
                    Image(systemName: "hand.point.up.left")
                        .padding(.horizontal)
                        .foregroundStyle(selectedTool == .select ? selectedColor : Color.black)
                        .scaleEffect(selectedTool == .select ? CGSize(width: 1.5, height: 1.5) : CGSize(width: 1.0, height: 1.0))
                        .onTapGesture {
                            withAnimation {
                                selectedTool = .select
                                isSelectingWidth = false
                                isSelectingColor = false
                            }
                        }
                    
                    Rectangle()
                        .frame(width: 1, height: 25)
                        .background(Color.black)
                    
                    // Color white
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
                                isSelectingColor.toggle()
                            }
                        }
                    
                }
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
            .zIndex(2.0)
            
        }
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
    
//    private func setTool(tool : CanvasTool) {
//        withAnimation {
//            switch tool {
//            case .pen:
//                
//                break
//            case .marker:
//                
//                break
//            case .eraser:
//                
//                break
//            case .select:
//                
//                break
//            }
//        }
//    }
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
