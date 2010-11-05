//
//  LCSSelectableCollectionViewItem.m
//  rotavault
//
//  Created by Lorenz Schori on 05.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSSelectableCollectionViewItem.h"
#import "LCSSelectable.h"


@implementation LCSSelectableCollectionViewItem
-(void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    
    if ([[self view] conformsToProtocol:@protocol(LCSSelectable)]) {
        [((id <LCSSelectable>)[self view]) setSelected:flag];        
    }
}
@end
