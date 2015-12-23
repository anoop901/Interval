//
//  Synthesizer.h
//  Interval
//
//  Created by Anoop Naravaram on 1/11/15.
//  Copyright (c) 2015 Anoop Naravaram. All rights reserved.
//

#ifndef Interval_Synthesizer_h
#define Interval_Synthesizer_h

typedef int Note;

@class AEAudioController;

@interface Synthesizer : NSObject

-(void) start;
-(void) noteOn:(Note)n;
-(void) noteOff:(Note)n;

@end


#endif
