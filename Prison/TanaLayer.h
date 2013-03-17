//
//  TanaLayer.h
//  Prison
//
//  Created by 筒井 啓太 on 13/03/17.
//  Copyright (c) 2013 東京工業大学. All rights reserved.
//

#import "cocos2d.h"
#import "CCTouchDispatcher.h"
#import "CCScrollLayer.h"

typedef enum Category {
  kCategoryYellow,
  kCategoryLove,
  kCategoryNum,
} Category;

@interface TanaLayer : CCLayer
{
 @private
  CCSprite *items[8];
  Category category_;
  NSDictionary *dictionary_;
  CCScrollLayer *scrollLayer_;
}

- (id)initWithCategory:(Category)category
            dictionary:(NSDictionary*)dictionary;
- (void)setScrollLayer:(CCScrollLayer*)scrollLayer;
- (void)setDictionary:(NSDictionary*)dictionary;

@end
