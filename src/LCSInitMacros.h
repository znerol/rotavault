/**
 *  @file LCSInitMacros.h
 *
 *  Created by Lorenz Schori on 07.09.10.
 *  Copyright 2010 znerol.ch. All rights reserved.
 *
 */

#define LCSINIT_OR_RETURN_NIL(initfunc) \
if(!(self = initfunc)) { \
    return nil; \
}

#define LCSINIT_SUPER_OR_RETURN_NIL() LCSINIT_OR_RETURN_NIL([super init])

#define LCSINIT_RELEASE_AND_RETURN_IF_NIL(x) \
if(!(x)) { \
    [self release]; \
    return nil; \
}
