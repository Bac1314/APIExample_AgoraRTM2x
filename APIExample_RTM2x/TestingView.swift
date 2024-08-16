//
//  TestingView.swift
//  APIExample_RTM2x
//
//  Created by BBC on 2024/4/2.
//

import SwiftUI
import AVFoundation

struct Point: Hashable {
    var x: CGFloat
    var y: CGFloat
    
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}
struct TestingView: View {
    @State private var rocketPosition = CGPoint(x: 200, y: 400)
    @State private var projectiles: [Point] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Rocket Ship
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .position(rocketPosition)
                .foregroundColor(.white)
            
            // Projectiles
            ForEach(projectiles, id: \.self) { projectile in
                Circle()
                    .fill(Color.pink)
                    .frame(width: 20, height: 20)
                    .position(projectile.cgPoint)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Move the rocket ship
                    rocketPosition = CGPoint(x: value.location.x, y: rocketPosition.y)
                }
        )
        .onTapGesture {
            // Shoot a projectile
            shootProjectile()
        }
        .onAppear {
            // Start the game loop
            startGameLoop()
        }
    }
    
    private func shootProjectile() {
        let projectileStart = Point(x: rocketPosition.x, y: rocketPosition.y - 50)
        projectiles.append(projectileStart)
    }
    
    private func startGameLoop() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateProjectiles()
        }
    }
    
    private func updateProjectiles() {
        // Move projectiles up
        for index in projectiles.indices {
            projectiles[index].y -= 5 // Move the projectile up
        }
        
        // Remove projectiles that go off-screen
        projectiles.removeAll { projectile in
            projectile.y < 0
        }
    }
}


#Preview {
    struct Preview: View {
        
        var body: some View {
            TestingView()
        }
    }
    
    return Preview()
}
