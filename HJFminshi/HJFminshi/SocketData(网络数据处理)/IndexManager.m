//
//  IndexManager.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "IndexManager.h"

@interface IndexManager ()

@property (nonatomic,assign) UInt16 currentindex;

@end

static IndexManager * sigleIndexManager = nil;

@implementation IndexManager
+ (IndexManager *)shareIndexManager
{
    if (sigleIndexManager == nil) {
        sigleIndexManager = [[IndexManager alloc] init];
    }
    return sigleIndexManager;
}

- (UInt16)currentIndex
{
    return _currentindex;
}

- (UInt16)newIndex
{
    ++_currentindex;
    if (_currentindex > 0x7fff) {
        _currentindex = 0;
    }
    return _currentindex;
}

@end
