//
//  LCSRotavaultPrivilegedJobInstallCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 19.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultPrivilegedJobInstallCommand.h"
#import "LCSInitMacros.h"
#import "SampleCommon.h"


@implementation LCSRotavaultPrivilegedJobInstallCommand
+ (LCSRotavaultPrivilegedJobInstallCommand*)privilegedJobInstallCommandWithLabel:(NSString*)label
                                                                                   method:(NSString*)method
                                                                                  runDate:(NSDate*)runDate
                                                                                   source:(NSString*)source
                                                                                   target:(NSString*)target
                                                                           sourceChecksum:(NSString*)sourceChecksum
                                                                           targetChecksum:(NSString*)targetChecksum
                                                                            authorization:(AuthorizationRef)auth
{
    return [[[LCSRotavaultPrivilegedJobInstallCommand alloc] initPrivilegedJobInstallCommandWithLabel:label
                                                                                               method:method
                                                                                              runDate:runDate
                                                                                               source:source
                                                                                               target:target
                                                                                       sourceChecksum:sourceChecksum
                                                                                       targetChecksum:targetChecksum
                                                                                        authorization:auth] autorelease];
}

- (id)initPrivilegedJobInstallCommandWithLabel:(NSString*)label
                                        method:(NSString*)method
                                       runDate:(NSDate*)runDate
                                        source:(NSString*)source
                                        target:(NSString*)target
                                sourceChecksum:(NSString*)sourceChecksum
                                targetChecksum:(NSString*)targetChecksum
                                 authorization:(AuthorizationRef)auth
{
    NSMutableDictionary *req = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         @kLCSHelperInstallRotavaultJobCommand, @kBASCommandKey,
                         label, @kLCSHelperInfoForRotavaultJobLabelParameter,
                         method, @kLCSHelperInstallRotavaultJobMethod,
                         source, @kLCSHelperInstallRotavaultJobSourceParameter,
                         target, @kLCSHelperInstallRotavaultJobTargetParameter,
                         sourceChecksum, @kLCSHelperInstallRotavaultJobSourceChecksumParameter,
                         targetChecksum, @kLCSHelperInstallRotavaultJobTargetChecksumParameter,
                         nil];
    if (runDate) {
        [req setObject:runDate forKey:@kLCSHelperInstallRotavaultJobRunDateParameter];
    }
    
    LCSINIT_OR_RETURN_NIL([super initWithRequest:req fromSet:kLCSHelperCommandSet withAuthorization:auth]);
    return self;
}

@end
