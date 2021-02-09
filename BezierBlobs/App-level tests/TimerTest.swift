/*
 helped out by:
 https://stackoverflow.com/questions/59241293/swiftui-how-do-you-restart-a-timer-after-cancelling-it
 */

import SwiftUI
import Combine

struct TimerTest: View {
    
    static let timeIncrement : Double = 0.5

    @State var isAnimating = false
    @State var secondsElapsed: Double = 0
    @State var timer: Timer.TimerPublisher = Timer.publish (every: timeIncrement, on: .main, in: .common)

    var body: some View {
        VStack {
            Text("{\( (self.secondsElapsed).format(fspec: "4.1") )} seconds elapsed")
            Button(isAnimating ? "Stop timer" : "Start timer",
                   action: {
                    isAnimating ? cancelTimer() : startTimer()
                    isAnimating.toggle()
            })

        }
        .onDisappear(perform: {
            cancelTimer()
            
        }).onReceive(timer) { _ in
            self.secondsElapsed += TimerTest.timeIncrement
        }
    }
    
    func startTimer() {
        instantiateTimer()
        _ = timer.connect()
    }

    func cancelTimer() {
        self.timer.connect().cancel()
    }
    
    func instantiateTimer() {
        self.timer = Timer.publish (every: TimerTest.timeIncrement, on: .main, in: .common)
    }
}
