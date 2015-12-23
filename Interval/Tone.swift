//
//  Synthesizer.swift
//  Interval
//
//  Created by Anoop Naravaram on 1/11/15.
//  Copyright (c) 2015 Anoop Naravaram. All rights reserved.
//

import Foundation

@objc class Tone : NSObject {
    let frequency:Double
    let decay:Double
    let waveform:Double->Double // domain 0 to 2π, range 0 to 1
    
    var theta:Double = 0
    var amplitude:Double
    
    var waveValue:Double { return amplitude * waveform(theta % (2 * M_PI)) }
    
    init (frequency:Double, decay:Double, initialAmplitude:Double, waveform:Double->Double) {
        self.frequency = frequency
        self.decay = decay
        self.amplitude = initialAmplitude
        self.waveform = waveform
    }
    
    func moveToNextSample(fs: Double) -> Void {
        amplitude *= exp(-decay / fs)
        theta += 2 * M_PI * frequency / fs
    }
}
