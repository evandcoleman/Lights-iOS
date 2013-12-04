//
//  LTInnerShadowView.m
//  Lights
//
//  Created by Evan Coleman on 12/3/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTInnerShadowView.h"

@interface LTInnerShadowView ()

@property (nonatomic, strong) CAShapeLayer *shadowLayer;

@end

@implementation LTInnerShadowView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:YES];
    }
    
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [self layoutShadowLayer];
    
    [super layoutSublayersOfLayer:layer];
}


- (void)layoutShadowLayer {
	CALayer *layer = self.layer;
    CGRect bounds = [layer bounds];
    CAShapeLayer *shadowLayer = self.shadowLayer;
    
    if (! CGRectEqualToRect(bounds, [shadowLayer frame])) {
        [shadowLayer removeFromSuperlayer];
        
        // http://stackoverflow.com/questions/4431292/inner-shadow-effect-on-uiview-layer/11436615#11436615
        // Answered by Matt Wilding
        
        shadowLayer = [CAShapeLayer layer];
        
        [shadowLayer setFrame:bounds];
        
        // Standard shadow stuff
        [shadowLayer setShadowColor:[[UIColor blackColor] CGColor]];
        [shadowLayer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [shadowLayer setShadowOpacity:0.3f];
        [shadowLayer setShadowRadius:1.0f];
        
        // Causes the inner region in to NOT be filled.
        [shadowLayer setFillRule:kCAFillRuleEvenOdd];
        
        // Create the larger rectangle path.
        CGMutablePathRef path = CGPathCreateMutable();
        
		CGRect shadowBounds = [shadowLayer bounds];
        
        CGPathAddRect(path, NULL, CGRectInset(shadowBounds, -3.0f, -3.0f));
        
        // Add the inner path so it's subtracted from the outer path.
        // someInnerPath could be a simple bounds rect, or maybe
        // a rounded one for some extra fanciness.
        
        CGPathRef innerPath = [[UIBezierPath bezierPathWithRect:shadowBounds] CGPath];
        
        CGPathAddPath(path, NULL, innerPath);
        CGPathCloseSubpath(path);
        
        [shadowLayer setPath:path];
        
        CGPathRelease(path);
        
        [shadowLayer setShouldRasterize:YES];
        
        [layer insertSublayer:shadowLayer atIndex:0];
        
        self.shadowLayer = shadowLayer;
    }
}

@end
