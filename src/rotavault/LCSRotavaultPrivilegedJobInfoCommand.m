//
//  LCSRotavaultPrivilegedHelperToolCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 19.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultPrivilegedJobInfoCommand.h"
#import "LCSInitMacros.h"
#import "SampleCommon.h"

@interface LCSRotavaultPrivilegedJobInfoCommand (Private)
- (id)initPrivilegedCommandWithRequest:(NSDictionary*)aRequest authorization:(AuthorizationRef*)anAuthorization;
@end

@implementation LCSRotavaultPrivilegedJobInfoCommand

+ (LCSRotavaultPrivilegedJobInfoCommand*)privilegedJobInfoCommandWithLabel:(NSString*)label
                                                             authorization:(AuthorizationRef)auth
{
    return [[[LCSRotavaultPrivilegedJobInfoCommand alloc] initPrivilegedJobInfoCommandWithLabel:label
                                                                                  authorization:auth] autorelease];
}

- (id)initPrivilegedJobInfoCommandWithLabel:(NSString*)label authorization:(AuthorizationRef)auth
{
    NSDictionary *req = [NSDictionary dictionaryWithObjectsAndKeys:
                         @kLCSHelperInfoForRotavaultJobCommand, @kBASCommandKey,
                         label, @kLCSHelperInfoForRotavaultJobLabelParameter,
                         nil];
                         
    LCSINIT_OR_RETURN_NIL([super initWithRequest:req fromSet:kLCSHelperCommandSet withAuthorization:auth]);
    
    return self;
}

- (void)collectResults
{
    controller.result = [response objectForKey:@kLCSHelperInfoForRotavaultJobResultPlistKey];
}
@end
