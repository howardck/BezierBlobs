//
//  AnimationTimer.swift
//  BezierBlobs
//
//  Created by Howard Katz on 2021-06-21.
//

import Foundation

class AnimationTimer: ObservableObject {
    
    // timeIncrement - animationTimeIncrement
    //   == pause between animations

    static let timeIncrement : Double = 3.2
    static let animationTimeIncrement : Double = 1.6
    
    @Published var isAnimating = false
    
    var timer: Timer.TimerPublisher
                       
    init() {
        timer = Timer.publish(every: AnimationTimer.timeIncrement,
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
        start(timeIncrement: AnimationTimer.timeIncrement)
    }
    
    func cancel() {
        
        isAnimating = false
        timer.connect().cancel()
    }
}