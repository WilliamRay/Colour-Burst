//
//  XYZInstructionScene.m
//  Color Burst
//
//  Created by William Ray on 05/08/2014.
//  Copyright (c) 2014 Roger Ray. All rights reserved.
//

#import "XYZInstructionScene.h"
#import "XYZArcadeScene.h"
#import "XYZRelayScene.h"
#import "XYZReactionScene.h"
#import <iAd/iAd.h>
#import "XYZViewController.h"

@interface XYZInstructionScene ()

@property NSString *gameMode;

@end

@implementation XYZInstructionScene

-(id)initWithSize:(CGSize)size gameMode:(NSString*)gameMode {
    if (self = [super initWithSize:size]) {
        _gameMode = gameMode;
        SKLabelNode *modeTitle = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS-Bold"];
        modeTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        modeTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        modeTitle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.75);
        modeTitle.fontSize = [self getFontSize:35];
        modeTitle.fontColor = [SKColor whiteColor];
        [self addChild:modeTitle];
        
        SKLabelNode *instructionLineOne = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
        instructionLineOne.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        instructionLineOne.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        instructionLineOne.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.6);
        instructionLineOne.fontSize = [self getFontSize:20];
        instructionLineOne.fontColor = [SKColor whiteColor];
        [self addChild:instructionLineOne];
        SKLabelNode *instructionLineTwo = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
        instructionLineTwo.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        instructionLineTwo.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        instructionLineTwo.position = CGPointMake(CGRectGetMidX(self.frame), instructionLineOne.position.y - instructionLineOne.fontSize * 1.5);
        instructionLineTwo.fontSize = [self getFontSize:20];
        instructionLineTwo.fontColor = [SKColor whiteColor];
        [self addChild:instructionLineTwo];
        SKLabelNode *instructionLineThree = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
        instructionLineThree.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        instructionLineThree.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        instructionLineThree.position = CGPointMake(CGRectGetMidX(self.frame), instructionLineTwo.position.y - instructionLineTwo.fontSize * 1.5);
        instructionLineThree.fontSize = [self getFontSize:20];
        instructionLineThree.fontColor = [SKColor whiteColor];
        [self addChild:instructionLineThree];
        
        SKLabelNode *clickLabel = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
        clickLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        clickLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        clickLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.1);
        clickLabel.text = @"Tap anywhere to contine";
        clickLabel.fontColor = [SKColor whiteColor];
        clickLabel.fontSize = [self getFontSize:20];
        [self addChild:clickLabel];
        if ([gameMode isEqualToString:@"arcade"]) {
            modeTitle.text = @"Arcade";
            instructionLineOne.text = @"Tap the red ball only.";
            instructionLineTwo.text = @"Don't touch the other balls.";
            instructionLineThree.text = @"You have 20s.";
            self.backgroundColor = [UIColor colorWithRed:0 green:(201/255.0) blue:(87/255.0) alpha:1];
        }
        else if ([gameMode isEqualToString:@"relay"]) {
            modeTitle.text = @"Relay";
            instructionLineOne.text = @"Tap the colour shown.";
            instructionLineTwo.text = @"Don't tap the background.";
            instructionLineThree.text = @"Clear all colours as fast as you can.";
            self.backgroundColor = [UIColor colorWithRed:(171/255.0) green:(130/255.0) blue:1 alpha:1];
        }
        else if ([gameMode isEqualToString:@"reaction"]) {
            modeTitle.text = @"Reaction";
            instructionLineOne.text = @"Tap the balls for more time.";
            instructionLineTwo.text = @"Tap as many balls as you can.";
            instructionLineThree.text = @"Don't tap the background.";
            self.backgroundColor = [UIColor colorWithRed:1 green:(153/255.0) blue:0 alpha:1];
        }
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKView *skView = (SKView *)self.view;
    SKTransition *transistion = [SKTransition fadeWithDuration:0.8];
    if ([_gameMode isEqualToString:@"arcade"]) {
        SKScene * scene = [[XYZArcadeScene alloc] initWithSize:self.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene transition:transistion];
    }
    else if ([_gameMode isEqualToString:@"relay"]) {
        SKScene * scene = [[XYZRelayScene alloc] initWithSize:self.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene transition:transistion];
    }
    else if ([_gameMode isEqualToString:@"reaction"]) {
        SKScene * scene = [[XYZReactionScene alloc] initWithSize:self.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene transition:transistion];
    }
}

-(float)getFontSize:(float)fontSize {
    if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
        return fontSize;
    }
    else {
        return fontSize*2;
    }
}

@end
