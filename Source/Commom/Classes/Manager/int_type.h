//
//  int_type.h
//  YALO
//
//  Created by BaoNQ on 7/25/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#ifndef int_type_h
#define int_type_h

#ifdef __LP64__
#define __64bit__         1
typedef	long long		INTEGER_T;
#else
#define __64bit__         0
typedef	int             INTEGER_T;
#endif

#if __LP64__
#define OSAtomicIncrementBarrier(v) OSAtomicIncrement64Barrier(v)
#else
#define OSAtomicIncrementBarrier(v) OSAtomicIncrement32Barrier(v)
#endif

#endif /* int_type_h */
