//
//  LCSOperationParameter.h
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LCSOperationInputParameter <NSObject>
@property(readonly,retain) id value;
@end

@protocol LCSOperationInOutParameter <NSObject>
@property(readwrite,retain) id value;
@end

@protocol LCSOperationOutputParameter <NSObject>
@property(readwrite,retain) id value;
@end
