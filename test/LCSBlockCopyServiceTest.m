//
//  LCSBlockCopyServiceTest.m
//  rotavault
//
//  Created by Lorenz Schori on 29.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyServiceTest.h"
#import "LCSBlockCopyService.h"


@implementation LCSBlockCopyServiceTest

- (void) setUp
{
    const char  constTemdirTemplate[] = "/tmp/lcs_unit_test_XXXXXXXX";
    char        tempdirTemplate[sizeof(constTemdirTemplate)];
    memcpy(tempdirTemplate, constTemdirTemplate, sizeof(tempdirTemplate));

    char *result = mkdtemp(tempdirTemplate);
    assert(result != NULL);

    tempdirPath = [[NSString alloc] initWithCString:result
                                           encoding:NSASCIIStringEncoding];
}

- (void) tearDown
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    [fm removeItemAtPath:tempdirPath error:nil];
    [fm release];

    [tempdirPath release];
}

- (void)testBlockCopy
{
    LCSBlockCopyService* bcs;
    NSString    *srcdev;
    NSString    *dstdev;

    bcs = [[LCSBlockCopyService alloc] init];
    [bcs restoreFromSource:srcdev toTarget:dstdev];
}
@end
