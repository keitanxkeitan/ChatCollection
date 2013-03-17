//
//  HelloWorldLayer.m
//  Prison
//
//  Created by 筒井 啓太 on 13/03/17.
//  Copyright 東京工業大学 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "TanaLayer.h"

extern int kNumItems;
extern NSString * kItemNames[kCategoryNum][8];

NSString * const kKeywords[kCategoryNum][8][3]=
{
  { { @"ひよこ", @"ヒヨコ", @"xxx" }, { @"ばなな", @"バナナ", @"xxx" },
    { @"きいろ", @"黄色", @"xxx" }, { @"xxx", @"xxx", @"xxx" },
    { @"xxx", @"xxx", @"xxx" }, { @"xxx", @"xxx", @"xxx" },
    { @"xxx", @"xxx", @"xxx" }, { @"xxx", @"xxx", @"xxx" } },
  { { @"あい", @"アイ", @"愛" }, { @"りんぐ", @"リング", @"指輪" },
    { @"ぷれぜんと", @"プレゼント", @"xxx" }, { @"xxx", @"xxx", @"xxx" },
    { @"xxx", @"xxx", @"xxx" }, { @"xxx", @"xxx", @"xxx" },
    { @"xxx", @"xxx", @"xxx" }, { @"xxx", @"xxx", @"xxx" } }
};

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {    
    // plist を読み込む
    NSString *path=[[NSBundle mainBundle] pathForResource:@"items" ofType:@"plist"];
    
    NSString *cachePath=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                              NSUserDomainMask,
                                                              YES) lastObject]
                         stringByAppendingPathComponent:@"items.plist"];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if( ![fileManager fileExistsAtPath:cachePath] )
    {
      [fileManager copyItemAtPath:path toPath:cachePath error:nil];
    }
    
    NSMutableDictionary *dictionary=[NSMutableDictionary dictionaryWithContentsOfFile:cachePath];

    // タイムラインを読み込む
    accountStore = [[ACAccountStore alloc] init];
    accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    userNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    tweetTextArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self loadTimeline];
            
    // plist を書き込む
    [dictionary writeToFile:cachePath atomically:YES];
    
    // 棚レイヤーを作成する
    NSMutableArray *array=[NSMutableArray array];
    layer1=[TanaLayer node];
    layer2=[TanaLayer node];
    
    [layer1 initWithCategory:kCategoryYellow dictionary:dictionary];
    [layer2 initWithCategory:kCategoryLove dictionary:dictionary];
    
    [array addObject:layer1];
    [array addObject:layer2];
    
    CCScrollLayer *scroller=[[CCScrollLayer alloc] initWithLayers:array widthOffset:0];
    [layer1 setScrollLayer:scroller];
    [layer2 setScrollLayer:scroller];
    [self addChild:scroller];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (void)registerText:(NSString*)text
{
  for( int category=0; category<kCategoryNum; ++category ){
    for( int i=0; i<kNumItems; ++i ){
      for (int j=0; j<3; ++j ){
        NSString *keyword=kKeywords[category][i][j];
        NSRange range=[text rangeOfString:keyword];
        if( range.location!=NSNotFound ){          
          // plist を読み込む
          NSString *path=[[NSBundle mainBundle] pathForResource:@"items" ofType:@"plist"];
          
          NSString *cachePath=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                    NSUserDomainMask,
                                                                    YES) lastObject]
                               stringByAppendingPathComponent:@"items.plist"];
          
          NSFileManager *fileManager=[NSFileManager defaultManager];
          if( ![fileManager fileExistsAtPath:cachePath] )
          {
            [fileManager copyItemAtPath:path toPath:cachePath error:nil];
          }
          
          NSMutableDictionary *dictionary=[NSMutableDictionary dictionaryWithContentsOfFile:cachePath];

          [dictionary setObject:text forKey:kItemNames[category][i]];
         
          // plist を書き込む
          [dictionary writeToFile:cachePath atomically:YES];
         
//          [layer1 setDictionary:dictionary];
//          [layer2 setDictionary:dictionary];
        }
      }
    }
  }
}

#pragma mark - UIAlertViewDelegate Method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if(buttonIndex == 1){
    NSURL *twSettingURL = [NSURL URLWithString:@"prefs:root=TWITTER"];
    [[UIApplication sharedApplication] openURL:twSettingURL];
  }
}

- (void)loadTimeline
{
  [accountStore requestAccessToAccountsWithType:accountType
                          withCompletionHandler:^(BOOL granted, NSError *error) {
                            if (granted) {
                              if (account == nil) {
                                NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
                                
                                if( [accountArray count]==0 ){
                                  //設定されていなければ、twitter設定画面へ飛ばすアラート表示
                                  UIAlertView *twAlert = [[[UIAlertView alloc]initWithTitle:@"no twitter setting"
                                                                                    message:@"set up twitter account"
                                                                                   delegate:self 
                                                                          cancelButtonTitle:@"cancel" 
                                                                          otherButtonTitles:@"open setting", 
                                                           nil] autorelease];
                                  [twAlert show];
                                }
                                
                                account = [accountArray objectAtIndex:0];
                              }
                              
                              if (account != nil) {
                                NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/user_timeline.json"];
                                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                                [params setObject:@"20" forKey:@"count"];
                                [params setObject:@"1" forKey:@"include_entities"];
                                [params setObject:@"1" forKey:@"include_rts"];
                                
                                TWRequest *request = [[TWRequest alloc] initWithURL:url
                                                                         parameters:params
                                                                      requestMethod:TWRequestMethodGET];
                                [request setAccount:account];
                                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                  
                                  if (responseData) {
                                    NSError *jsonError;
                                    NSArray *timeline = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                        options:NSJSONReadingMutableLeaves error:&jsonError];
                                    for( NSDictionary *tweet in timeline ){
                                      NSString *text=[tweet objectForKey:@"text"];
                                      [self registerText:text];
                                    }
                                    
                                    // plist を読み込む
                                    NSString *path=[[NSBundle mainBundle] pathForResource:@"items" ofType:@"plist"];
                                    
                                    NSString *cachePath=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                                              NSUserDomainMask,
                                                                                              YES) lastObject]
                                                         stringByAppendingPathComponent:@"items.plist"];
                                    
                                    NSFileManager *fileManager=[NSFileManager defaultManager];
                                    if( ![fileManager fileExistsAtPath:cachePath] )
                                    {
                                      [fileManager copyItemAtPath:path toPath:cachePath error:nil];
                                    }
                                    
                                    NSMutableDictionary *dictionary=[NSMutableDictionary dictionaryWithContentsOfFile:cachePath];
                                                                                                            
                                    // [layer1 setDictionary:dictionary];
                                    // [layer2 setDictionary:dictionary];
                                  }
                                  
                                }];
                                
                                
                              }
                              
                              
                            }
                          }];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
