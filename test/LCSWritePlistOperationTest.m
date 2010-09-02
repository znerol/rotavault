//
//  LCSWritePlistOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSWritePlistOperationTest.h"
#import "LCSWritePlistOperation.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"
#import "LCSTestdir.h"


@implementation LCSWritePlistOperationTest

-(void)setUp
{
    error = nil;
}

-(void)tearDown
{
    [error release];
    error = nil;
}

-(void)operation:(LCSOperation*)operation handleError:(NSError*)inError
{
    error = [inError retain];
}

-(void)testWritePlistOperationWithPath
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    plistPath = [[testdir path] stringByAppendingPathComponent:@"test.plist"];
    NSDictionary *plist = [NSDictionary dictionaryWithObject:@"42" forKey:@"Deep Thought"];

    LCSWritePlistOperation *op = [[LCSWritePlistOperation alloc] init];
    op.delegate = self;
    op.plistPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:plistPath];
    op.plist = [[LCSSimpleOperationInputParameter alloc] initWithValue:plist];
    [op start];

    STAssertNil(error, @"%@", @"No error expected at this time");
    NSDictionary *reread = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    STAssertEqualObjects(reread, plist, @"%@", @"Difference in contents of written file not expected");

    [op release];
    [testdir remove];
    [testdir release];
}

-(void)testWritePlistOperationWithoutPath
{
    plistPath = nil;
    NSDictionary *plist = [NSDictionary dictionaryWithObject:@"42" forKey:@"Deep Thought"];

    LCSWritePlistOperation *op = [[LCSWritePlistOperation alloc] init];
    op.delegate = self;
    op.plistPath = [[LCSKeyValueOperationInOutParameter alloc] initWithTarget:self keyPath:@"plistPath"];
    op.plist = [[LCSSimpleOperationInputParameter alloc] initWithValue:plist];
    [op start];

    STAssertNil(error, @"%@", @"No error expected at this time");
    STAssertNotNil(plistPath, @"%@", @"Path must have been set to a temporary file");
    NSDictionary *reread = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    STAssertEqualObjects(reread, plist, @"%@", @"Difference in contents of written file not expected");

    NSFileManager *fm = [[NSFileManager alloc] init];
    [fm removeItemAtPath:plistPath error:nil];
    [op release];
}
@end
