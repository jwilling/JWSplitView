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

#import <Cocoa/Cocoa.h>

enum {
    JWSplitViewDividerStyleThin = 1,
};
typedef NSInteger JWSplitViewDividerStyle;

@class JWDividerView;
@protocol JWSplitViewDelegate;

@interface JWSplitView : NSView

- (void)addSplitView:(NSView *)view;
- (NSView *)splitViewAtIndex:(NSUInteger)index;
- (JWDividerView *)dividerAtSplitViewIndex:(NSUInteger)index;

@property (nonatomic) NSArray *splitterPositions;
@property (nonatomic, weak) id <JWSplitViewDelegate> delegate;
@property (nonatomic, readwrite) CGFloat dividerThickness;
@property (nonatomic, getter = isHorizontal) BOOL horizontal;
@property (nonatomic, assign) JWSplitViewDividerStyle dividerStyle;
@property (nonatomic, copy) NSString *autosaveName;

@end

@interface JWDividerView : NSView
@property (nonatomic, assign, readonly) NSLayoutConstraint *constraint;
@end

@protocol JWSplitViewDelegate <NSObject>
@optional

- (CGFloat)splitView:(JWSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)index;
- (CGFloat)splitView:(JWSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)index;

@end

extern NSString * const JWSplitViewDidResizeNotification;
