//
//  HelloWorldLayer.h
//  Prison
//
//  Created by 筒井 啓太 on 13/03/17.
//  Copyright 東京工業大学 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CCScrollLayer.h"
#import "Twitter/Twitter.h"
#import "Accounts/Accounts.h"
#import "TanaLayer.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
  NSMutableArray *userNameArray;
  NSMutableArray *tweetTextArray;
  ACAccount *account;
  ACAccountStore *accountStore;
  ACAccountType *accountType;
  TanaLayer *layer1;
  TanaLayer *layer2;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
- (void)loadTimeline;

@end
