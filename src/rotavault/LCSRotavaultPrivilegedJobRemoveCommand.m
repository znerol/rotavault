//
//  LCSRotavaultPrivilegedJobRemoveCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 19.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultPrivilegedJobRemoveCommand.h"
#import "LCSInitMacros.h"
#import "SampleCommon.h"


@implementation LCSRotavaultPrivilegedJobRemoveCommand
+ (LCSRotavaultPrivilegedJobRemoveCommand*)privilegedJobRemoveCommandWithLabel:(NSString*)label
                                                                          authorization:(AuthorizationRef)auth
{
    return [[[LCSRotavaultPrivilegedJobRemoveCommand alloc] initPrivilegedJobRemoveCommandWithLabel:label
                                                                                      authorization:auth] autorelease];
}

- (id)initPrivilegedJobRemoveCommandWithLabel:(NSString*)label authorization:(AuthorizationRef)auth
{
    NSDictionary *req = [NSDictionary dictionaryWithObjectsAndKeys:
                         @kLCSHelperRemoveRotavaultJobCommand, @kBASCommandKey,
                         label, @kLCSHelperRemoveRotavaultJobLabelParameter,
                         nil];
    
    LCSINIT_OR_RETURN_NIL([super initWithRequest:req fromSet:kLCSHelperCommandSet withAuthorization:auth]);
    
    return self;    
}
@end
