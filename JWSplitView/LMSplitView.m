//
//  LMSplitView.m
//
//  Created by Nguyen Bui on 11/22/13.
//  Copyright (c) 2013 LeftMobile. All rights reserved.
//

#import "LMSplitView.h"

@interface JWDividerView()
@property (nonatomic, strong) DividerCombineInfo *info;
@end

@interface DividerCombineInfo()

@property (nonatomic, assign) float pos1;
@property (nonatomic, assign) float pos2;
@property (nonatomic, assign) float reset;

@end

@implementation LMSplitView

- (void) updateDividerCombineInfos:(NSArray *)infos {
    self.dividerCombineInfos = infos;
    
    NSAssert([self.dividers count] == [self.dividerCombineInfos count], @"Wrong info");
    
    // set for each divider
    int i = 0;
    for (JWDividerView *div in self.dividers) {
        // info
        div.info = [self.dividerCombineInfos objectAtIndex:i];
        
        // update divider location
        CGFloat newConstant = div.constraint.constant;
        if(div.info.pos1 != 0 && div.info.pos1 != div.info.pos2) {
            if (div.info.pos1 < div.info.pos2) {
                if (newConstant > div.info.pos2) {
                    newConstant = div.info.pos2;
                }
            }
            else {
                if (newConstant < div.info.pos2) {
                    newConstant = div.info.pos2;
                }
            }
        }
        div.constraint.constant = newConstant;
        
        i++;
    }
}

- (void)mouseDownOnDivider:(JWDividerView *)divider withEvent:(NSEvent *)downEvent {
    NSPoint mouseDownPoint = [downEvent locationInWindow];
    BOOL horizontal = self.horizontal;
    CGFloat originalConstant = divider.constraint.constant;
    
    self.dragHandler = ^(NSEvent *event, JWDividerView *currentDivider, id sender) {
        CGPoint mouseCurrentPoint = [event locationInWindow];
        
        CGFloat deltaY = ceil(mouseCurrentPoint.y - mouseDownPoint.y);
        CGFloat deltaX = ceil(mouseDownPoint.x - mouseCurrentPoint.x);
        
        CGFloat newConstant = originalConstant - (horizontal ? deltaX : deltaY);
        if(currentDivider.info.pos1 != 0 && currentDivider.info.pos1 != currentDivider.info.pos2) {
            if (currentDivider.info.pos1 < currentDivider.info.pos2) {
                if(newConstant < currentDivider.info.pos1) {
                    newConstant = currentDivider.info.reset;
                }
                else if (newConstant > currentDivider.info.pos2) {
                    newConstant = currentDivider.info.pos2;
                }
            }
            else {
                if(newConstant > currentDivider.info.pos1) {
                    newConstant = currentDivider.info.reset;
                }
                else if (newConstant < currentDivider.info.pos2) {
                    newConstant = currentDivider.info.pos2;
                }
            }
        }
        
        currentDivider.constraint.constant = newConstant;
    };
}

@end

@implementation DividerCombineInfo

- (id) initWithPos1:(CGFloat) p1 pos2:(CGFloat) p2 resetTo:(CGFloat) re {
    self = [super init];
    if(self) {
        self.pos1 = p1;
        self.pos2 = p2;
        self.reset = re;
    }
    
    return self;
}

@end