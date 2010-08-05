//
//  LCSVaultImageServiceTest.m
//  rotavault
//
//  Created by Lorenz Schori on 22.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSVaultImageServiceTest.h"
#import "LCSVaultImageService.h"

/***** LCSTestPassphraseReader *****/
#import "LCSPassphraseReader.h"
/**
 * A passphrase reader class for unit testing. Feeds "TEST" as the password
 * whenever an encrypted image file should be created or attached.
 */
@interface LCSTestPassphraseReader : NSObject <LCSPassphraseReader>
@end

@implementation LCSTestPassphraseReader

- (void) prepareTask:(NSTask*)task
{
    /* Add -stdinpass to arguments */
    [task setArguments:[[task arguments] arrayByAddingObject:@"-stdinpass"]];

    /* Create pipe for stdin and write "TEST" as the password to it */
    NSPipe *stdinPipe = [NSPipe pipe];
    [task setStandardInput:stdinPipe];

    [[stdinPipe fileHandleForWriting] writeData:
     [@"TEST" dataUsingEncoding:NSASCIIStringEncoding]];

    /* close our end of the pipe */
    [[stdinPipe fileHandleForWriting] closeFile];
}
@end

/***** LCSTestStatusReporter *****/
#import "LCSStatusReporter.h"

/**
 * A status reporter helper class for unit testing. Calls STFail whenever the
 * termination status of the called task is non-zero
 */
@interface LCSTestStatusReporter : NSObject <LCSStatusReporter> {
    LCSVaultImageServiceTest*   tc;
    NSPipe* errPipe;
}
- (LCSTestStatusReporter*) initWithTestCase:(LCSVaultImageServiceTest*)testCase;
@end

@implementation LCSTestStatusReporter
- (LCSTestStatusReporter*) initWithTestCase:(LCSVaultImageServiceTest*)testCase
{
    self = [super init];
    tc = testCase;
    return self;
}

- (void) prepareTask:(NSTask*)task
{
    errPipe = [NSPipe pipe];
    [task setStandardError:errPipe];
}

- (void) taskDidTerminate:(NSTask *)task
{
    int status = [task terminationStatus];
    NSString* message = [[NSString alloc]
                         initWithData:[[errPipe fileHandleForReading] availableData]
                         encoding: NSUnicodeStringEncoding];

    if (status != 0) {
        [tc failWithStatus:status message:message];
    }
    [message release];
}
@end

/***** LCSVaultImageServiceTest *****/

/**
 * Unit test class for the LCSVaultImageService class
 */
@implementation LCSVaultImageServiceTest

- (void) setUp
{
    testdir = [[LCSTestdir alloc] init];
}

- (void) tearDown
{
    [testdir remove];
    [testdir release];
    testdir = nil;
}

- (void) testCreateAtPath
{
    LCSTestPassphraseReader* ps = [[LCSTestPassphraseReader alloc] init];
    LCSTestStatusReporter*   sr = [[LCSTestStatusReporter alloc]
                                   initWithTestCase:self];
    LCSVaultImageService*   vis = [[LCSVaultImageService alloc]
                                   initWithPassphraseReader:ps
                                   progressIndicator:nil statusReporter:sr];

    NSString *path = [[testdir path] stringByAppendingPathComponent:@"test.dmg"];

    [vis createAtPath:path sectors:2000];

    [vis attachImage:path];

    NSDictionary *info = [vis infoForImage:path];
    STAssertNotNil(info, @"info must not be nil");

    NSArray *devices = [vis devicesForImage:path];
    STAssertNotNil(devices, @"device list must not be nil");
    STAssertTrue([devices count] == 1,
                 @"device list must contain exactly one entry");

    /* ugly cleanup code */
    NSTask *ejectTask =
        [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil"
                                 arguments:[NSArray arrayWithObjects: @"eject",
                                            [devices objectAtIndex:0], nil]];
    [ejectTask waitUntilExit];
}

- (void)failWithStatus:(int)status message:(NSString*)message
{
    STFail(@"Command failed with status: %d and message %@", status, message);
}
@end
