//
//  LCSHdiUtilPlistOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistTaskOperation.h"


@interface LCSHdiInfoOperation : LCSPlistTaskOperation
@end

@interface LCSAttachImageOperation : LCSPlistTaskOperation {
    NSString* path;
}
@property(retain) NSString* path;
@end

@interface LCSDetachImageOperation : LCSTaskOperation {
    NSString* path;
}
@property(retain) NSString* path;
@end
