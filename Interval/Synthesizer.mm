//
//  Synthesizer.m
//  Interval
//
//  Created by Anoop Naravaram on 1/11/15.
//  Copyright (c) 2015 Anoop Naravaram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Synthesizer.h"
#import "Instrmnt.h"
#import "Flute.h"
#import "Mandolin.h"
#import "AEAudioController.h"
#import "AEBlockChannel.h"

#define SAMPLING_RATE 44100.0


double noteToFrequency(Note n) {
    return 440.0 * exp2((n - 69) / 12.0);
}

double (^squareWaveform)(double x) = ^(double x) {
    if (x < M_PI) {
        return 1.0;
    } else {
        return -1.0;
    }
};

@interface Synthesizer ()
//@property NSMutableDictionary *currentlyPlayingNotes; // NSNumber keys, Tone values
@property Note currentlyPlayingNote;
@property stk::Instrmnt *instrument;
@end

@implementation Synthesizer : NSObject

-(id) init {
    self = [super init];
    
    if (self) {
        NSBundle *rawwaveBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"rawwaves" withExtension:@"bundle"]];
        stk::Stk::setRawwavePath([[rawwaveBundle resourcePath] UTF8String]);
        //_currentlyPlayingNotes = [[NSMutableDictionary alloc] init];
        _instrument = new stk::Mandolin(400);
    }
    
    return self;
}

-(void) start {
    
    AEAudioController *audioController = [[AEAudioController alloc]
                                          initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]
                                          inputEnabled:NO];
    NSError *errorAudioSetup = NULL;
    BOOL result = [audioController start:&errorAudioSetup];
    if ( !result ) {
        NSLog(@"Error starting audio engine: %@", errorAudioSetup.localizedDescription);
        return;
    }
    
    AEBlockChannel *myChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp  *time,
                                                                    UInt32 frames,
                                                                    AudioBufferList *audio) {
        for ( int i=0; i<frames; i++ ) {
            
            ((float*)audio->mBuffers[0].mData)[i] =
            ((float*)audio->mBuffers[1].mData)[i] = self.instrument->tick();
            
        }
    }];
    
    [audioController addChannels:@[myChannel]];
    
    /*
    Novocaine *audioManager = [[Novocaine alloc] init];
    [audioManager setOutputBlock:^(float *data, UInt32 numSamples, UInt32 numChannels) {
        
        for (int i = 0; i < numSamples; i++) {
            / *
            double waveSum = 0;
            for (NSNumber *n in [self currentlyPlayingNotes]) {
                Tone *t = [[self currentlyPlayingNotes] objectForKey: n];
                waveSum += [t waveValue];
                [t moveToNextSample:SAMPLING_RATE];
            }
            for (int ch = 0; ch < numChannels; ch++) {
                data[i*numChannels + ch] = waveSum;
            }
            data[i*numChannels] = waveSum;
             * /
            data[i*numChannels] = self.instrument->tick();
        }
    }];
    [audioManager play];
    */
}

-(void) noteOn:(Note)n {
    self.instrument->noteOn(noteToFrequency(n), 1);
    self.currentlyPlayingNote = n;
    /*
    [[self currentlyPlayingNotes]
     setObject:[[Tone alloc]
                initWithFrequency:noteToFrequency(n)
                decay:1
                initialAmplitude:1
                waveform:squareWaveform]
     forKey:[NSNumber numberWithInt:n]];
     */
}

-(void) noteOff:(Note)n {
    if (n == self.currentlyPlayingNote) {
        self.instrument->noteOff(1);
    }
    /*
    [[self currentlyPlayingNotes] removeObjectForKey:[NSNumber numberWithInt:n]];
     */
}

@end
