//
//  IndexManager.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IndexManagerInstance   [IndexManager shareIndexManager]
#define CurrentIndex           [IndexManagerInstance currentIndex]
#define NewIndex               [IndexManagerInstance newIndex]

@interface IndexManager : NSObject

+ (IndexManager *)shareIndexManager;

- (UInt16)currentIndex;

- (UInt16)newIndex;

@end
