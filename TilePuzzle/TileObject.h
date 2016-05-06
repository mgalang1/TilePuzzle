//
//  TileObject.h
//  TilePuzzle
//
//  Created by Marvin Galang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileObject : UIView

- (id)initWithTileNumber:(CGRect)frame row:(NSUInteger) row column:(NSUInteger) column tileNumber:(NSUInteger) tileNumber;

@property (nonatomic, assign) NSUInteger row;  //location of the tile
@property (nonatomic, assign) NSUInteger column; // within the board
@property (nonatomic, assign) NSUInteger tileNumber;

@end
