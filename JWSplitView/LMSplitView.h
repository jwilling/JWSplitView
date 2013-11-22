//
//  LMSplitView.h
//
//  Created by Nguyen Bui on 11/22/13.
//  Copyright (c) 2013 LeftMobile. All rights reserved.
//

#import "JWSplitView.h"

@interface LMSplitView : JWSplitView
@property (nonatomic, strong) NSArray *dividerCombineInfos;
@end

@interface DividerCombineInfo : NSObject

- (id) initWithPos1:(CGFloat) p1 pos2:(CGFloat) p2 resetTo:(CGFloat) re;

@end