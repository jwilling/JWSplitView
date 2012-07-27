#import <Cocoa/Cocoa.h>

enum {
    JWSplitViewDividerStyleThin = 1,
};
typedef NSInteger JWSplitViewDividerStyle;


@interface JWSplitView : NSView

//- (void)setView:(NSView *)view forSplitView:(NSUInteger)splitView;
- (void)addSplitView:(NSView *)view;

@property (nonatomic, readwrite) CGFloat dividerThickness;
//@property (nonatomic, copy) TUIViewDrawRect dividerDrawRectBlock;

@property (nonatomic, getter = isHorizontal) BOOL horizontal;

@property (nonatomic, copy) NSString *autosaveName;

//- (NSLayoutPriority)holdingPriorityForSubviewAtIndex:(NSInteger)subviewIndex;
//- (void)setHoldingPriority:(NSLayoutPriority)priority forSubviewAtIndex:(NSInteger)subviewIndex;


@end
