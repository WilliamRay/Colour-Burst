//
//  XYZMainScene.m
//  Color Burst
//
//  Created by William Ray on 05/08/2014.
//  Copyright (c) 2014 Roger Ray. All rights reserved.
//

#import "XYZMainScene.h"
#import "XYZArcadeScene.h"
#import "XYZRelayScene.h"
#import "XYZReactionScene.h"
#import "XYZInstructionScene.h"
#import <iAd/iAd.h>

@implementation XYZMainScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        NSArray *colours = @[[UIColor colorWithRed:1 green:(204/255.0) blue:0 alpha:1], [UIColor colorWithRed:0 green:(191/255.0) blue:1 alpha:1], [UIColor colorWithRed:0 green:(201/255.0) blue:(87/255.0) alpha:1], [UIColor colorWithRed:1 green:(48/255.0) blue:(48/255.0) alpha:1]];
        
        //Create logo
        SKShapeNode *logoCircle = [[SKShapeNode alloc] init];
        CGMutablePathRef circleRad60Path = CGPathCreateMutable();
        CGPathAddArc(circleRad60Path, NULL, 0, 0, [self getFontSizeOrRadius:60], 0, M_PI*2, YES);
        logoCircle.path = circleRad60Path;
        logoCircle.position = CGPointMake((CGRectGetMaxX(self.frame)*0.27), (CGRectGetMaxY(self.frame)*0.8));
        logoCircle.fillColor = colours[0];
        logoCircle.strokeColor = colours[0];
        logoCircle.name = @"logoCircle";
        [self addChild:logoCircle];
        SKLabelNode *logoLabel1 = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS-Bold"];
        logoLabel1.position = CGPointMake((CGRectGetMaxX(self.frame)*0.27), (CGRectGetMaxY(self.frame)*0.8)+2);
        logoLabel1.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        logoLabel1.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
        logoLabel1.fontSize = [self getFontSizeOrRadius:25];
        logoLabel1.text = @"Colour";
        [self addChild:logoLabel1];
        SKLabelNode *logoLabel2 = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS-Bold"];
        logoLabel2.position = CGPointMake((CGRectGetMaxX(self.frame)*0.27), (CGRectGetMaxY(self.frame)*0.8)-2);
        logoLabel2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        logoLabel2.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        logoLabel2.fontSize = [self getFontSizeOrRadius:25];
        logoLabel2.text = @"Burst";
        [self addChild:logoLabel2];
        
        //Create mode one buttons
        SKShapeNode *modeOneCircle = [[SKShapeNode alloc] init];
        modeOneCircle.path = circleRad60Path;
        modeOneCircle.position = CGPointMake((CGRectGetMaxX(self.frame)*0.72), (CGRectGetMaxY(self.frame)*0.6));
        modeOneCircle.fillColor = colours[1];
        modeOneCircle.strokeColor = colours[1];
        modeOneCircle.name = @"reactionStart";
        [self addChild:modeOneCircle];
        SKLabelNode *modeOneLabel = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
        modeOneLabel.position = CGPointMake((CGRectGetMaxX(self.frame)*0.72), (CGRectGetMaxY(self.frame)*0.6));
        modeOneLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        modeOneLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        modeOneLabel.fontSize = [self getFontSizeOrRadius:23];
        modeOneLabel.text = @"Reaction";
        modeOneLabel.name = @"reactionStart";
        [self addChild:modeOneLabel];
        
        //Create mode two buttons
        SKShapeNode *modeTwoCircle = [[SKShapeNode alloc] init];
        modeTwoCircle.path = circleRad60Path;
        modeTwoCircle.position = CGPointMake((CGRectGetMaxX(self.frame)*0.27), (CGRectGetMaxY(self.frame)*0.4));
        modeTwoCircle.fillColor = colours[2];
        modeTwoCircle.strokeColor = colours[2];
        modeTwoCircle.name = @"arcadeStart";
        [self addChild:modeTwoCircle];
        
        SKLabelNode *modeTwoLabel = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
        modeTwoLabel.position = CGPointMake((CGRectGetMaxX(self.frame)*0.27), (CGRectGetMaxY(self.frame)*0.4));
        modeTwoLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        modeTwoLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        modeTwoLabel.fontSize = [self getFontSizeOrRadius:23];
        modeTwoLabel.text = @"Arcade";
        modeTwoLabel.name = @"arcadeStart";
        [self addChild:modeTwoLabel];
        
        //Create mode three buttons
        SKShapeNode *modeThreeCircle = [[SKShapeNode alloc] init];
        modeThreeCircle.path = circleRad60Path;
        modeThreeCircle.position = CGPointMake((CGRectGetMaxX(self.frame)*0.72), (CGRectGetMaxY(self.frame)*0.2));
        modeThreeCircle.fillColor = colours[3];
        modeThreeCircle.strokeColor = colours[3];
        modeThreeCircle.name = @"relayStart";
        [self addChild:modeThreeCircle];
        SKLabelNode *modeThreeLabel = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
        modeThreeLabel.position = CGPointMake((CGRectGetMaxX(self.frame)*0.72), (CGRectGetMaxY(self.frame)*0.2));
        modeThreeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        modeThreeLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        modeThreeLabel.fontSize = [self getFontSizeOrRadius:23];
        modeThreeLabel.text = @"Relay";
        modeThreeLabel.name = @"relayStart";
        [self addChild:modeThreeLabel];
        
        CGPathRelease(circleRad60Path);
        
        SKAction *changeLogoColor = [SKAction runBlock:^(void){
            SKShapeNode *node = (SKShapeNode *)[self childNodeWithName:@"logoCircle"];
            int i = arc4random() %4;
            node.fillColor = colours[i];
            node.strokeColor = colours[i];
        }];
        SKAction *wait = [SKAction waitForDuration:1];
        SKAction *loopLogoColorChange = [SKAction repeatActionForever:[SKAction sequence:@[changeLogoColor, wait]]];
        [self runAction:loopLogoColorChange];
        
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    UIViewController *vc = self.view.window.rootViewController;
    vc.canDisplayBannerAds = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    SKView *skView = (SKView *)self.view;
    SKTransition *transistion = [SKTransition fadeWithDuration:0.8];
    if ([node.name isEqualToString:@"reactionStart"]) {
        SKScene * scene = [[XYZInstructionScene alloc] initWithSize:self.size gameMode:@"reaction"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene transition:transistion];
    }
    else if ([node.name isEqualToString:@"arcadeStart"]) {
        SKScene * scene = [[XYZInstructionScene alloc] initWithSize:self.size gameMode:@"arcade"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene transition:transistion];
    }
    else if ([node.name isEqualToString:@"relayStart"]) {
        SKScene * scene = [[XYZInstructionScene alloc] initWithSize:self.size gameMode:@"relay"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene transition:transistion];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(float)getFontSizeOrRadius:(float)size {
    if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
        return size;
    }
    else {
        return size*2;
    }
}



@end
