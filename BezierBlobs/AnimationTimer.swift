//
//  AnimationTimer.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-21.
//

import Foundation

class AnimationTimer: ObservableObject {
    
    //  timerFiringTimeIncrement - animationTimeIncrement
    //  == pause between animations (if any)

    static let timerFiringTimeIncrement : Double = 2.25
    static let animationTimeIncrement : Double = 2.2
    
    // timer for orbiting vertices as well as double-tap
    // blob curve quick return to initial configuration

    static let animationQuickMarchTimeIncrement : Double = 0.6
    
    @Published var isAnimating = false
    
    var timer: Timer.TimerPublisher
                       
    init() {
        timer = Timer.publish(every: AnimationTimer.timerFiringTimeIncrement,
                              on: .main, in: .common)
    }
    
    func start(timeIncrement : Double = 0) {
        
        isAnimating = true
        timer = Timer.publish(every: timeIncrement,
                              on: .main, in: .common)
        _ = timer.connect()
    }
    
    func restart() {
        
        cancel()
        start(timeIncrement: AnimationTimer.timerFiringTimeIncrement)
    }
    
    func cancel() {
        
        isAnimating = false
        timer.connect().cancel()
    }
}
