/*
 Copyright (c) 2012, Jonathan Willing
 All rights reserved.
 Licensed under the BSD License.
 http://www.opensource.org/licenses/bsd-license
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met: Redistributions of source code must retain the
 above copyright notice, this list of conditions and the following disclaimer. Redistributions
 in binary form must reproduce the above copyright notice, this list of conditions and the
 following disclaimer in the documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "JWSplitView.h"
#import <objc/runtime.h>

NSString * const JWSplitViewDidResizeNotification = @"JWSplitViewDidResizeNotification";

@class JWDividerView;
typedef void (^JWSplitViewDraggingHandler)(NSEvent *dragEvent, JWDividerView *divider, id sender);

@interface JWSplitView()
@property (nonatomic, strong) NSMutableArray *splitViews;
@property (nonatomic, strong) NSMutableArray *dividers;
@property (nonatomic, strong) NSMutableArray *dividerConstraints;
@property (nonatomic, strong) NSArray *restoredConstants;
@property (nonatomic, copy) JWSplitViewDraggingHandler dragHandler;
@end

@interface JWDividerView()
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) JWSplitViewDividerStyle dividerStyle;
@property (nonatomic, assign) BOOL horizontal;
@property (nonatomic, assign, readwrite) NSLayoutConstraint *constraint;
@end

@interface NSView (LayoutExtensions)
- (void)setPriority:(NSLayoutPriority)priority;
- (NSLayoutPriority)priorityOrDefault:(NSLayoutPriority)defaultPriority;
@end

@interface NSObject (DragEvents)
- (void)mouseDraggedOnDivider:(NSView *)divider withEvent:(NSEvent *)event;
- (void)mouseDownOnDivider:(NSView *)divider withEvent:(NSEvent *)event;
- (void)mouseUpOnDivider:(NSView *)divider withEvent:(NSEvent *)event;
@end

@implementation JWSplitView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.splitViews = [NSMutableArray array];
        self.dividers = [NSMutableArray array];
        self.dividerConstraints = [NSMutableArray array];
        self.dividerThickness = 5.f;
        self.dividerStyle = JWSplitViewDividerStyleThin;
        self.horizontal = YES;
        
        [self addDivider];
    }
    return self;
}

- (void)setHorizontal:(BOOL)horizontal {
    _horizontal = horizontal;
    for (JWDividerView *view in self.splitViews) {
        view.horizontal = horizontal;
    }
}

- (void)setDividerStyle:(JWSplitViewDividerStyle)dividerStyle {
    _dividerStyle = dividerStyle;
    for (JWDividerView *divider in self.dividers) {
        divider.dividerStyle = dividerStyle;
        [divider setNeedsDisplay:YES];
    }
}

- (void)addSplitView:(NSView *)view {
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.splitViews addObject:view];
    [self addSubview:view];
    
    [self addDivider];
    [self resetLayout];
}

- (void)addDivider {
    JWDividerView *divider = [[JWDividerView alloc] initWithFrame:CGRectZero];
    [divider setTranslatesAutoresizingMaskIntoConstraints:NO];
    divider.horizontal = self.horizontal;
    divider.dividerStyle = self.dividerStyle;
    [self.dividers addObject:divider];
    [self addSubview:divider];
    
    [self resetDividerLayout];
}

- (NSView *)splitViewAtIndex:(NSUInteger)index {
    return self.splitViews[index];
}

- (JWDividerView *)dividerAtSplitViewIndex:(NSUInteger)index {
    return self.dividers[index + 1];
}


#pragma mark -
#pragma mark Constraint setups

- (void)resetAllConstraints {
    [self removeConstraints:self.constraints];
}

- (void)resetDividerLayout {
    [self resetAllConstraints];
    
    [self.dividerConstraints removeAllObjects];
    
    NSMutableArray *standardConstraints = [NSMutableArray array];
    
    [self.dividers enumerateObjectsUsingBlock:^(id div, NSUInteger idx, BOOL *stop) {
        BOOL last = ([div isEqual:self.dividers.lastObject]);
        BOOL first = ([div isEqual:self.dividers[0]]);
        BOOL h = self.horizontal;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(div);
        NSDictionary *metrics = @{ @"size" : @(self.dividerThickness), @"negSize" : @(-self.dividerThickness) };
        
        if (first) {
            [standardConstraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:h ? @"H:|-(==negSize)-[div]" : @"V:|-(==negSize)-[div]"
                                                     options:0 metrics:metrics views:views]];
        } else if (last) {
            [standardConstraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:h ? @"H:[div]-(==negSize)-|" : @"V:[div]-(==negSize)-|"
                                                     options:0 metrics:metrics views:views]];
        } else {
            
            CGFloat dividedPosition = ceilf( ((self.dividerConstraints.count + 1.f) / self.splitViews.count) * (h ? self.frame.size.width : self.frame.size.height));
            
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:div attribute:(h ? NSLayoutAttributeLeft : NSLayoutAttributeTop)
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self attribute:(h ? NSLayoutAttributeLeft : NSLayoutAttributeTop)
                                                                         multiplier:1.0 constant:dividedPosition];
            [constraint setPriority:490];
            [self.dividerConstraints addObject:constraint];
            [div setConstraint:constraint]; // divider weakly stores a reference to this constraint so we can modify it later
            
            if ([self shouldRestorePositions]) {
                constraint.constant = [self.restoredConstants[[self.dividerConstraints indexOfObject:constraint]] floatValue];
            }
        }
        
        // set the divider thickness, and stretch to fill the width or height
        NSArray *stretch = [NSLayoutConstraint constraintsWithVisualFormat:h ? @"V:|[div(>=0)]|" : @"H:|[div(>=0)]|"
                                                                   options:0 metrics:metrics views:views];
        NSArray *size = [NSLayoutConstraint constraintsWithVisualFormat:h ? @"H:[div(==size)]" : @"V:[div(==size)]"
                                                                options:0 metrics:metrics views:views];
        [standardConstraints addObjectsFromArray:stretch];
        [standardConstraints addObjectsFromArray:size];
    }];
    [self addConstraints:self.dividerConstraints];
    [self addConstraints:standardConstraints];
}

- (void)resetLayout {
    NSMutableDictionary *views = [@{} mutableCopy];
    NSMutableArray *constraints = [@[] mutableCopy];
    BOOL h = self.horizontal;
    
    [self.splitViews enumerateObjectsUsingBlock:^(NSView *currentView, NSUInteger idx, BOOL *stop) {
        views[@"current"] = currentView;
        views[@"prevDiv"] = self.dividers[idx];
        views[@"nextDiv"] = self.dividers[idx + 1];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:h ? @"H:[prevDiv][current(>=0@600)][nextDiv]" : @"V:[prevDiv][current(>=0)][nextDiv]"
                                                                                 options:0 metrics:0 views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:h ? @"V:|[current]|" : @"H:|[current]|"
                                                                                 options:0 metrics:0 views:views]];
    }];
    [self addConstraints:constraints];
}

- (void)mouseDownOnDivider:(JWDividerView *)divider withEvent:(NSEvent *)downEvent {
    NSPoint mouseDownPoint = [downEvent locationInWindow];
    
    BOOL horizontal = self.horizontal;
    CGFloat originalConstant = divider.constraint.constant;
    
    __block JWSplitView *me = self;
    self.dragHandler = ^(NSEvent *event, JWDividerView *currentDivider, id sender) {
        CGPoint mouseCurrentPoint = [event locationInWindow];
        
        CGFloat deltaY = ceil(mouseCurrentPoint.y - mouseDownPoint.y);
        CGFloat deltaX = ceil(mouseDownPoint.x - mouseCurrentPoint.x);
        
        CGFloat newConstant = originalConstant - (horizontal ? deltaX : deltaY);
        CGFloat minimum = [me.delegate respondsToSelector:@selector(splitView:constrainMinCoordinate:ofSubviewAt:)] ? [me.delegate splitView:me constrainMinCoordinate:newConstant ofSubviewAt:[me.dividers indexOfObject:currentDivider] - 1] : -1;
        CGFloat maximum = [me.delegate respondsToSelector:@selector(splitView:constrainMinCoordinate:ofSubviewAt:)] ? [me.delegate splitView:me constrainMaxCoordinate:newConstant ofSubviewAt:[me.dividers indexOfObject:currentDivider] - 1] : -1;
        
        currentDivider.constraint.constant = newConstant;
        
        if (maximum != -1 && newConstant > maximum) currentDivider.constraint.constant = maximum;
        else if (maximum != -1 && newConstant < minimum) currentDivider.constraint.constant = minimum;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JWSplitViewDidResizeNotification object:me];
    };
}

- (void)mouseDraggedOnDivider:(JWDividerView *)divider withEvent:(NSEvent *)event {
    if (self.dragHandler)
        self.dragHandler(event, divider, self);
}

- (void)mouseUpOnDivider:(NSView *)divider withEvent:(NSEvent *)event {
    self.dragHandler = nil;
    
    [self savePositions];
}


#pragma mark -
#pragma mark Saving / restoring state

- (BOOL)shouldRestorePositions {
    return (self.autosaveName != nil && self.restoredConstants.count > 0);
}

- (void)setAutosaveName:(NSString *)autosaveName {
    _autosaveName = [autosaveName copy];
    [self restorePositionsWithAutosaveName:autosaveName];
}

- (void)restorePositionsWithAutosaveName:(NSString *)autosave {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:autosave];
    if (!data)
        return;
    
    self.restoredConstants = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self resetDividerLayout];
}

- (void)savePositions {
    if (!_autosaveName)
        return;
    
    NSMutableArray *constants = [NSMutableArray arrayWithCapacity:self.dividerConstraints.count];
    for (NSLayoutConstraint *constraint in self.dividerConstraints) {
        [constants addObject:@(constraint.constant)];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:constants];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:self.autosaveName];
}

- (NSArray *)splitterPositions
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.dividerConstraints) [array addObject:@(constraint.constant)];
    
    return array;
}

- (void)setSplitterPositions:(NSArray *)splitterPositions
{
    NSInteger limit = splitterPositions.count;
    for (NSInteger i = 0; i < limit; i++) [self.dividerConstraints[i] setConstant:[splitterPositions[i] doubleValue]];
}

@end



@implementation JWDividerView

- (void)mouseDown:(NSEvent *)theEvent {
    [self.superview mouseDownOnDivider:self withEvent:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    [self.superview mouseDraggedOnDivider:self withEvent:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
    [self.superview mouseUpOnDivider:self withEvent:theEvent];
}

- (void)mouseEntered:(NSEvent *)event {
    if (self.horizontal) {
        [[NSCursor resizeLeftRightCursor] push];
    } else {
        [[NSCursor resizeUpDownCursor] push];
    }
}

- (void)mouseExited:(NSEvent *)event {
    [[NSCursor currentCursor] pop];
}

- (void)updateTrackingAreas {
    if (_trackingArea) {
        [self removeTrackingArea:self.trackingArea];
        self.trackingArea = nil;
    }
    
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp)
                                                       owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CGContextRef ctx = [context graphicsPort];
    
    switch (self.dividerStyle) {
        case JWSplitViewDividerStyleThin: {
            CGContextSetRGBFillColor(ctx, 0.35, 0.35, 0.35, 1);
            CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height));
            CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
            CGContextFillRect(ctx, CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height));
        }
            break;
            
        default:
            break;
    }
}

@end

@implementation NSView (LayoutExtensions)

static char NSViewLayoutPriorityKey;

- (void)setPriority:(NSLayoutPriority)priority {
    NSAssert(priority > NSLayoutPriorityDragThatCanResizeWindow, @"Split view layout priority cannot exceed NSLayoutPriorityDragThatCannotResizeWindow");
    objc_setAssociatedObject(self, &NSViewLayoutPriorityKey, @(priority), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutPriority)priorityOrDefault:(NSLayoutPriority)defaultPriority {
    NSNumber *obj = objc_getAssociatedObject(self, &NSViewLayoutPriorityKey);
    if (!obj && obj.floatValue < 1) {
        return defaultPriority;
    }
    return obj.floatValue;
}

@end
