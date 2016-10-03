//
//  XYZViewController.m
//  Color Burst
//
//  Created by William Ray on 05/08/2014.
//  Copyright (c) 2014 Roger Ray. All rights reserved.
//

#import "XYZViewController.h"
#import "XYZMainScene.h"

@interface XYZViewController()

@property NSString *leaderboardIdentifier;
@property BOOL gameCenterEnabled;
@property NSString *localPlayer;

@end

@implementation XYZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self authenticateLocalPlayer];
    
    // Configure the view.
    SKView * skView = (SKView *)self.originalContentView;
    //    skView.showsFPS = YES;
    //    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [XYZMainScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    self.canDisplayBannerAds = YES;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
                
                [self loadCompletedAchievements];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reportScore:)
     name:@"ReportScore"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showLeaderboard:)
     name:@"DisplayLeaderboard"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAchievements:)
     name:@"DisplayAchievements"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateAchievementProgress:)
     name:@"ReportAchievement"
     object:nil];
}

-(void)reportScore:(NSNotification *) notification {
    if (_gameCenterEnabled) {
        NSDictionary *userInfo = [notification userInfo];
        NSNumber *score = (NSNumber *)[userInfo objectForKey:@"score"];
        NSString *identifier = (NSString *)[userInfo objectForKey:@"identifier"];
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:[NSString stringWithFormat:@"colour_burst_%@", identifier]];
        scoreReporter.value = [score longLongValue];;
        scoreReporter.context = 0;
        
        NSArray *scores = @[scoreReporter];
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

- (void)showLeaderboard:(NSNotification *)notification
{
    if (_gameCenterEnabled) {
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        NSDictionary *userInfo = [notification userInfo];
        NSString *identifier = (NSString *)[userInfo objectForKey:@"identifier"];
        if (gameCenterController != nil)
        {
            gameCenterController.gameCenterDelegate = self;
            gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
            gameCenterController.leaderboardIdentifier = [NSString stringWithFormat:@"colour_burst_%@", identifier];
            [self presentViewController: gameCenterController animated: YES completion:nil];
        }
    }
}

-(void)showAchievements:(NSNotification *)notification {
    if (_gameCenterEnabled) {
        
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        if (gameCenterController != nil)
        {
            gameCenterController.gameCenterDelegate = self;
            gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
            [self presentViewController: gameCenterController animated: YES completion:nil];
        }
    }
}

-(BOOL)isGameCenterEnabled {
    return _gameCenterEnabled;
}

-(void)updateAchievementProgress:(NSNotification *)notification {
    if (_gameCenterEnabled) {
        NSDictionary *userInfo = [notification userInfo];
        NSArray *achievementIdentifiers = (NSArray *)[userInfo objectForKey:@"identifier"];
        NSArray *progress = (NSArray *)[userInfo objectForKey:@"progress"];
        NSMutableArray *achievements  = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < progress.count; i++) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@%@", achievementIdentifiers[i], [GKLocalPlayer localPlayer].playerID]]) {
                GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifiers[i]];
                achievement.percentComplete = [progress[i] doubleValue];
                [achievements addObject:achievement];
                if (achievement.percentComplete == 100) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@%@", achievementIdentifiers[i], [GKLocalPlayer localPlayer].playerID]];
                }
            }
        }
        if (achievements != nil) {
            [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"%@", [error localizedDescription]);
                    
                }
            }];
        }
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)resetAchievements {
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error != nil) {
             NSLog(@"%@", [error localizedDescription]);
         }}];
}

-(void)loadCompletedAchievements {
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        if (achievements != nil) {
            for (int i = 0; i < achievements.count; i++) {
                GKAchievement *achievement = achievements[i];
                if (achievement.completed) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@%@", achievement.identifier, [GKLocalPlayer localPlayer].playerID]];
                }
            }
        }
    }];
}

@end
