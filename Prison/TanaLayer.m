//
//  TanaLayer.m
//  Prison
//
//  Created by 筒井 啓太 on 13/03/17.
//  Copyright (c) 2013 東京工業大学. All rights reserved.
//

#import "TanaLayer.h"

const int kNumItems=8;

NSString * const kTanaFiles[kCategoryNum]=
{
  @"tana_yellow.png",
  @"tana_love.png",
};

NSString * const kItemNames[kCategoryNum][kNumItems]=
{
  { @"hiyoko", @"banana", @"color_pencil", @"d", @"e", @"f", @"g", @"h" },
  { @"ai", @"ring", @"present", @"d", @"e", @"f", @"g", @"h" },
};

const CGPoint kBamiris[kNumItems]=
{
  { 86.f, 270.f },
  { 152.f, 270.f },
  { 130.f, 180.f },
  { 250.f, 180.f },
  { 336.f, 180.f },
  { 200.f, 90.f },
  { 285.f, 90.f },
  { 410.f, 90.f },
};

@implementation TanaLayer

- (id)initWithCategory:(Category)category
            dictionary:(NSDictionary *)dictionary
{
  if( ( self=[super init] ) )
  {
    category_=category;
    dictionary_=[dictionary copy];
    
    CCSprite *tana=[CCSprite spriteWithFile:kTanaFiles[category]];
    tana.position=ccp( 240.f, 160.f );
    [self addChild:tana];
    
    for( int i=0; i<kNumItems; ++i )
    {
      NSString *itemName=kItemNames[category][i];
      NSString *message=[dictionary objectForKey:itemName];
      
      if( message && ![message isEqualToString:@""]){
        NSString *filename=[NSString stringWithFormat:@"%@.png", itemName];
        items[i]=[CCSprite spriteWithFile:filename];
      }else{
        items[i]=[CCSprite spriteWithFile:@"hatena.png"];
      }
      items[i].position=kBamiris[i];
      [self addChild:items[i]];
    }
    
    self.isTouchEnabled = YES;
  }
  return self;
}

- (void)setScrollLayer:(CCScrollLayer*)scrollLayer
{
  scrollLayer_=scrollLayer;
}

- (void)setDictionary:(NSDictionary *)dictionary
{
  dictionary_=[dictionary copy];
  
  for( int i=0; i<kNumItems; ++i )
  {
    NSString *itemName=kItemNames[category_][i];
    NSString *message=[dictionary objectForKey:itemName];
    if( message && ![message isEqualToString:@""]){
      NSString *filename=[NSString stringWithFormat:@"%@.png", itemName];
      items[i]=[CCSprite spriteWithFile:filename];
    }else{
      items[i]=[CCSprite spriteWithFile:@"hatena.png"];
    }
    items[i].position=kBamiris[i];
    [self addChild:items[i]];
  }
}

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint location=[touch locationInView:[touch view]];
  location=[[CCDirector sharedDirector] convertToGL:location];
  
  for( int i=0; i<kNumItems; ++i ){
    float h=items[i].contentSize.height;
    float w=items[i].contentSize.width;
    float x=items[i].position.x - ( w / 2 );
    float y=items[i].position.y - ( h / 2 );
    CGRect rect=CGRectMake( x, y, w, h );
    
    if( CGRectContainsPoint( rect, location ) ){
      NSString *itemName=kItemNames[[scrollLayer_ currentScreen]][i];
      NSString *message=[dictionary_ objectForKey:itemName];

      UIAlertView *alert;
      if( message && ![message isEqualToString:@""]){
        alert=[[[UIAlertView alloc] initWithTitle:itemName
                                          message:message
                                         delegate:self
                                cancelButtonTitle:nil
                                otherButtonTitles:@"OK", nil]
               autorelease];
      }else{
        alert=[[[UIAlertView alloc] initWithTitle:@"はてな"
                                          message:@"なんでしょーｗｗｗ"
                                         delegate:self
                                cancelButtonTitle:nil
                                otherButtonTitles:@"OK", nil]
               autorelease];
      }
      [alert show];
    }
  }
}

@end
