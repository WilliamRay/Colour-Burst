//
//  XYZReactionScene.m
//  Color Burst
//
//  Created by William Ray on 05/08/2014.
//  Copyright (c) 2014 Roger Ray. All rights reserved.
//

#import "XYZReactionScene.h"
#import "XYZGameOverScene.h"
#import <iAd/iAd.h>

@interface XYZReactionScene ()

@property float timeLeft;
@property SKLabelNode *scoreLabel;
@property SKLabelNode *countDown;
@property NSInteger score;
@property SKNode *balls;
@property BOOL timerBegan;

@end

static const float timeIncreaseAmount = 0.3;
static const float timeDecreaseAmount = 0.5;

@implementation XYZReactionScene

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
    _timerBegan = NO;
    _timeLeft = 2.0;
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
    _scoreLabel.fontSize = [self getFontSizeOrRadius:25];
    _scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), 50);
    _scoreLabel.fontColor = [SKColor blackColor];
    _scoreLabel.name = @"score";
    _scoreLabel.text = @"0";
    _scoreLabel.zPosition = 10;
    _score = 0;
    [self addChild:_scoreLabel];
    
    _countDown = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
    _countDown.fontSize = [self getFontSizeOrRadius:50];
    _countDown.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMaxY(self.frame)*0.85);
    _countDown.fontColor = [SKColor blackColor];
    _countDown.name = @"countDown";
    _countDown.zPosition = 10;
    [self addChild:_countDown];
    
    for (int i = 0; i < arc4random() %4 + 1; i++) {
        [self spawnNewSetOfBalls];
    }
    _balls = [SKNode new];
    [self addChild:_balls];
    
    
}

-(void)update:(NSTimeInterval)currentTime {
    _scoreLabel.text = [NSString stringWithFormat:@"Score: %li", (long)_score];
    if (_timeLeft <= 0) {
        _countDown.text = @"STOP!";
    }
    else
        _countDown.text = [NSString stringWithFormat:@"%1.1f", _timeLeft];
    if (_balls.children.count == 0) {
        [self spawnNewSetOfBalls];
    }
    if ((arc4random() %30 == 0) && (_balls.children.count < 4) && (_timerBegan)) {
        [self spawnNewSetOfBalls];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL doIncrease = NO;
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    if (!_timerBegan) {
        [self createTimer];
    }
    for (SKNode *node in [self nodesAtPoint:touchLocation]) {
        if ([node.name isEqualToString:@"ball"]) {
            doIncrease = YES;
            [node removeFromParent];
        }
    }
    if (doIncrease) {
        [self updateScore];
        _timeLeft += timeIncreaseAmount;
        [self showTimeChangeLabelAtPosistion:touchLocation ofType:@"increase"];
    }
    else {
        _timeLeft -= timeDecreaseAmount;
        [self showTimeChangeLabelAtPosistion:touchLocation ofType:@"decrease"];
    }
}

-(void)updateScore {
    _score += 1;
    NSArray *identifiers = @[@"reaction_5_points", @"reaction_10_points", @"reaction_20_points", @"reaction_50_points", @"reaction_100_points", @"reaction_150_points"];
    NSArray *progress = @[[self calculateProgress:5], [self calculateProgress:10], [self calculateProgress:20], [self calculateProgress:50], [self calculateProgress:100], [self calculateProgress:150]];
    [self reportAchievementsWithIdentifier:identifiers andProgress:progress];
}

-(NSNumber*)calculateProgress:(double)achievementAmount {
    double progress = (_score/achievementAmount) *100;
    NSNumber *progressPercent = [NSNumber numberWithDouble:progress];
    
    if (progress <= 100) {
        return progressPercent;
    } else {
        return [NSNumber numberWithDouble:100];
    }
}

-(void)createTimer {
    //Create the timer
    SKAction *wait = [SKAction waitForDuration:0.1];
    SKAction *sequence = [SKAction sequence:@[[SKAction performSelector:@selector(writeTimer) onTarget:self], wait]];
    SKAction *repeat = [SKAction repeatActionForever:sequence];
    [self runAction:repeat withKey:@"timer"];
    _timerBegan = YES;
}

-(void)showTimeChangeLabelAtPosistion:(CGPoint)position ofType:(NSString*)type {
    SKLabelNode *timeChange = [SKLabelNode labelNodeWithFontNamed:@"TrebuchetMS"];
    timeChange.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    timeChange.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    timeChange.position = position;
    timeChange.fontSize = [self getFontSizeOrRadius:20];
    timeChange.zPosition = -10;
    if ([type isEqualToString:@"increase"]) {
        timeChange.text = [NSString stringWithFormat:@"+%1.1fs", timeIncreaseAmount];
        timeChange.fontColor = [SKColor greenColor];
    }
    else
    {
        timeChange.text = [NSString stringWithFormat:@"-%1.1fs", timeDecreaseAmount];
        timeChange.fontColor = [SKColor redColor];
    }
    [self addChild:timeChange];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:2];
    [timeChange runAction:fadeOut completion:^(void){
        [timeChange removeFromParent];
    }];
    
}


-(void)spawnNewSetOfBalls {
    BOOL tryForNewCoords = YES;
    NSArray *colours = [NSArray arrayWithObjects:
                        [UIColor colorWithRed:0 green:(201/255.0) blue:(87/255.0) alpha:1], //green
                        [UIColor colorWithRed:0 green:(191/255.0) blue:1 alpha:1], //blue
                        [UIColor colorWithRed:1 green:(153/255.0) blue:0 alpha:1], //orange
                        [UIColor colorWithRed:1 green:(204/255.0) blue:0 alpha:1], //yellow
                        [UIColor colorWithRed:(171/255.0) green:(130/255.0) blue:1 alpha:1],
                        [UIColor colorWithRed:1 green:(48/255.0) blue:(48/255.0) alpha:1], //red
                        nil];
    SKShapeNode *ball = [[SKShapeNode alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddArc(path, NULL, 0, 0, [self getFontSizeOrRadius:30], 0, M_PI*2, YES);
    ball.path = path;
    UIColor *ballColor = colours[arc4random() %colours.count];
    ball.strokeColor = ballColor;
    ball.fillColor = ballColor;
    ball.name = @"ball";
    CGPathRelease(path);

    while (tryForNewCoords) {
        ball.position = [self createBallCoord:ball];
        if (_balls.children.count > 0)
        {
            for (SKNode *otherBall in _balls.children) {
                float deltaX = ball.position.x - otherBall.position.x;
                float deltaY = ball.position.y - otherBall.position.y;
                
                float distance = sqrtf(deltaX*deltaX + deltaY*deltaY);
                
                if (distance <= ball.frame.size.width*1.5) {
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
    [_balls addChild:ball];
    
}

-(CGPoint)createBallCoord:(SKNode*)ball {
    
    int maxXCoord = CGRectGetMaxX(self.frame) - ball.frame.size.width;
    int maxYCoord = CGRectGetMaxY(self.frame) - ball.frame.size.width;
    
    int x = (arc4random() % maxXCoord) + ball.frame.size.width/2;
    int y = (arc4random() % maxYCoord) + ball.frame.size.width/2;
    CGPoint coords = CGPointMake(x, y);
    return coords;
}


-(void)showGameOverScreen {
    SKView *skView = (SKView *)self.view;
    SKTransition *transistion = [SKTransition fadeWithDuration:0.8];
    SKScene *scene = [[XYZGameOverScene alloc] initWithSize:self.size score:_score gameMode:@"reaction"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene transition:transistion];
}


-(void)writeTimer {
    _timeLeft -= 0.1;
    if (_timeLeft < 0) {
        [self showGameOverScreen];
    }
}

-(float)getFontSizeOrRadius:(float)size {
    if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
        return size;
    }
    else {
        return size*2;
    }
}

-(void)reportAchievementsWithIdentifier:(NSArray *)identifiers andProgress:(NSArray *)progress {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[identifiers, progress] forKeys:@[@"identifier", @"progress"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReportAchievement" object:self userInfo:userInfo];
}


@end