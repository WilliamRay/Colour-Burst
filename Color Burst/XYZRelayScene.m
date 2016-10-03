//
//  XYZRelayScene.m
//  Color Burst
//
//  Created by William Ray on 05/08/2014.
//  Copyright (c) 2014 Roger Ray. All rights reserved.
//

#import "XYZRelayScene.h"
#import "XYZGameOverScene.h"
#import <iAd/iAd.h>

@interface XYZRelayScene ()

@property SKLabelNode *countDown;
@property SKLabelNode *colorLabel;
@property SKShapeNode *balls;
@property NSInteger ballsLeft;
@property NSInteger colorNumber;
@property float timeTaken;
@property BOOL timerBegan;

@end

@implementation XYZRelayScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    UIViewController *vc = self.view.window.rootViewController;
    vc.canDisplayBannerAds = NO;
    [self setUpNewGame];
}

-(void)setUpNewGame {
    _balls = [SKShapeNode node];
    [self addChild:_balls];
    
    //Create countdown label
    _countDown = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
    _countDown.fontSize = [self getFontSizeOrRadius:50];
    _countDown.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMaxY(self.frame)*0.85);
    _countDown.fontColor = [SKColor blackColor];
    _countDown.name = @"countDown";
    _countDown.zPosition = 10;
    _countDown.text = @"0.0";
    [self addChild:_countDown];
    
    //Create colour to click label
    _colorLabel = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
    _colorLabel.fontSize = [self getFontSizeOrRadius:25];
    _colorLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - 20, CGRectGetMaxY(self.frame)-15);
    _colorLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _colorLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _colorLabel.fontColor = [SKColor blackColor];
    _colorLabel.text = @"0";
    _colorLabel.zPosition = 10;
    [self addChild:_colorLabel];
    
    
    [self spawnBalls];
    [self checkColorExists];
}

-(void)update:(NSTimeInterval)currentTime {
    //Update the countdown text
    _countDown.text = [NSString stringWithFormat:@"%1.1f", _timeTaken];
}

-(void)showGameOverScreen {
    //show game over screen
    [self reportAchievements];
    SKView *skView = (SKView *)self.view;
    SKTransition *transistion = [SKTransition fadeWithDuration:0.8];
    SKScene *scene = [[XYZGameOverScene alloc] initWithSize:self.size score:_timeTaken gameMode:@"relay"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene transition:transistion];
}

-(void)spawnBalls {
    NSArray *colours = [NSArray arrayWithObjects:
                        [UIColor colorWithRed:0 green:(201/255.0) blue:(87/255.0) alpha:1], //green
                        [UIColor colorWithRed:0 green:(191/255.0) blue:1 alpha:1], //blue
                        [UIColor colorWithRed:1 green:(153/255.0) blue:0 alpha:1], //orange
                        [UIColor colorWithRed:1 green:(204/255.0) blue:0 alpha:1], //yellow
                        [UIColor colorWithRed:(171/255.0) green:(130/255.0) blue:1 alpha:1], //purple
                        [UIColor colorWithRed:1 green:(48/255.0) blue:(48/255.0) alpha:1], // red
                        nil];
    for (int i = 0; i < 10; i++) {
        BOOL tryForNewCoords = YES;
        //Creates the ball
        SKShapeNode *ball = [[SKShapeNode alloc] init];
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathAddArc(path, NULL, 0, 0, [self getFontSizeOrRadius:30], 0, M_PI*2, YES);
        ball.path = path;
        CGPathRelease(path);
        int colorNumber = arc4random() %colours.count;
        UIColor *color = colours[colorNumber];
        ball.fillColor = color;
        ball.strokeColor = color;
        ball.name = [NSString stringWithFormat:@"%i", colorNumber];
        while (tryForNewCoords) {
            ball.position = [self createBallCoord:ball];
            if (_balls.children.count > 0) {
                for (SKShapeNode *node in _balls.children) {
                    float deltaX = ball.position.x - node.position.x;
                    float deltaY = ball.position.y - node.position.y;
                    
                    float distance = sqrtf(deltaX*deltaX + deltaY*deltaY);
                    
                    if (distance <= ball.frame.size.width*1.25) {
                        tryForNewCoords = YES;
                        break;
                    }
                    else
                        tryForNewCoords = NO;
                }
            }
            else
                tryForNewCoords = NO;
        }
        _ballsLeft += 1;
        [_balls addChild:ball];
    }
}

-(CGPoint)createBallCoord:(SKNode*)ball {
    //Create a coordinate
    int maxXCoord = CGRectGetMaxX(self.frame) - ball.frame.size.width;
    int maxYCoord = CGRectGetMaxY(self.frame) - ball.frame.size.width;
    int x = (arc4random() % maxXCoord) + ball.frame.size.width/2;
    int y = (arc4random() % maxYCoord) + ball.frame.size.width/2;
    CGPoint coords = CGPointMake(x, y);
    return coords;
}

-(void)checkColorExists {
    //Check if a ball exists with the current colour
    BOOL colorExists = NO;
    if (_balls.children.count > 0) {
        SKNode *node = [_balls childNodeWithName:[NSString stringWithFormat:@"%li", (long)_colorNumber]];
        if (node) {
            colorExists = YES;
            [self updateColorLabel];
        }
    }
    if (colorExists == NO) {
        _colorNumber = arc4random() %6;
        [self checkColorExists];
    }
}

-(void)popUpColorChange {
    //Create the pop-up label to show the next colour
    if ([self childNodeWithName:@"popUp"]) {
        [[self childNodeWithName:@"popUp"] removeFromParent];
    }
    SKLabelNode *popUpColorLabel = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
    popUpColorLabel.fontSize = [self getFontSizeOrRadius:30];
    popUpColorLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    popUpColorLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    popUpColorLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    popUpColorLabel.fontColor = _colorLabel.fontColor;
    popUpColorLabel.text = _colorLabel.text;
    popUpColorLabel.zPosition = 10;
    popUpColorLabel.name = @"popUp";
    [self addChild:popUpColorLabel];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:1.5];
    [popUpColorLabel runAction:fadeOut completion:^(void){[self removeFromParent];}];
}

-(void)updateColorLabel {
    NSArray *colorNames = [NSArray arrayWithObjects:@"Green", @"Blue", @"Orange", @"Yellow", @"Purple", @"Red", nil];
    NSArray *colours = [NSArray arrayWithObjects:
                        [UIColor colorWithRed:0 green:(201/255.0) blue:(87/255.0) alpha:1], //green
                        [UIColor colorWithRed:0 green:(191/255.0) blue:1 alpha:1], //blue
                        [UIColor colorWithRed:1 green:(153/255.0) blue:0 alpha:1], //orange
                        [UIColor colorWithRed:1 green:(204/255.0) blue:0 alpha:1], //yellow
                        [UIColor colorWithRed:(171/255.0) green:(130/255.0) blue:1 alpha:1], //purple
                        [UIColor colorWithRed:1 green:(48/255.0) blue:(48/255.0) alpha:1], // red
                        nil];
    if (![_colorLabel.text isEqualToString:colorNames[_colorNumber]]) {
        _colorLabel.text = colorNames[_colorNumber];
        _colorLabel.fontColor = colours[_colorNumber];
        [self popUpColorChange];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL allowIncrease = YES;
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    if (!_timerBegan) {
        [self createTimer];
    }
    for (SKNode *node in [_balls nodesAtPoint:touchLocation]) {
        if ([node.name isEqualToString:[NSString stringWithFormat:@"%li", (long)_colorNumber]]) {
            _ballsLeft -=1;
            allowIncrease = NO;
            [node removeFromParent];
            if (_ballsLeft == 0) {
                [self showGameOverScreen];
            }
            else
                [self checkColorExists];
        }
    }
    if (allowIncrease) {
        _timeTaken += 1;
        [self showTimeChangeLabelAtPosistion:touchLocation];
    }
}

-(void)createTimer {
    //Create the timer
    _timerBegan = YES;
    SKAction *wait = [SKAction waitForDuration:0.1];
    SKAction *sequence = [SKAction sequence:@[wait, [SKAction runBlock:^(void){_timeTaken+=0.1;}]]];
    SKAction *repeat = [SKAction repeatActionForever:sequence];
    [self runAction:repeat withKey:@"timer"];
}

-(void)showTimeChangeLabelAtPosistion:(CGPoint)position {
    //Show a time increase label at the point tapped
    SKLabelNode *timeChange = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
    timeChange.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    timeChange.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    timeChange.position = position;
    timeChange.fontSize = [self getFontSizeOrRadius:20];
    timeChange.zPosition = 10;
    timeChange.text = @"+1.0s";
    timeChange.fontColor = [SKColor redColor];
    [self addChild:timeChange];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:2];
    [timeChange runAction:fadeOut completion:^(void){
        [timeChange removeFromParent];
    }];
    
}

-(void)reportAchievements {
    NSArray *identifiers = @[@"relay_under_10_seconds", @"relay_under_5_seconds", @"relay_under_3_seconds", @"relay_under_2_seconds", @"relay_under_1_seconds"];
    NSMutableArray *progress = [[NSMutableArray alloc] init];
    if (_timeTaken < 10) {
        [progress addObject:[NSNumber numberWithDouble:100]];
    }
    if (_timeTaken < 5) {
        [progress addObject:[NSNumber numberWithDouble:100]];
    }
    if (_timeTaken < 3) {
        [progress addObject:[NSNumber numberWithDouble:100]];
    }
    if (_timeTaken < 2) {
        [progress addObject:[NSNumber numberWithDouble:100]];
    }
    if (_timeTaken < 1) {
        [progress addObject:[NSNumber numberWithDouble:100]];
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[identifiers, progress] forKeys:@[@"identifier", @"progress"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReportAchievement" object:self userInfo:userInfo];
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