//
//  LCSVerifier.h
//  rotavault
//
//  Created by Lorenz Schori on 04.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LCSVerifier : NSObject {
    BOOL            evaluated;
    BOOL            passed;
    NSString*       title;
    NSString*       message;
    LCSVerifier*    depends;
}
@property(assign) BOOL evaluated;
@property(assign) BOOL passed;
@property(copy) NSString* title;
@property(copy) NSString* message;
@property(retain) LCSVerifier* depends;
- (void)evaluate;
@end

@interface LCSVerifier (SubclassOverride)
- (void)performEvaluation;
@end
