//
//  TileBoard.h
//  TilePuzzle
//
//  Created by Marvin Galang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TileObject.h"

@interface TileBoard : NSObject
@property (nonatomic, retain) NSMutableArray *tiles;
@property (nonatomic, assign) NSUInteger noTileRow;  //track row in the puzzle board that have the
@property (nonatomic, assign) NSUInteger noTileCol;  //empty tile.
@property (nonatomic, assign) NSUInteger noTileIndex;  

-(id) initWithScreenFrame:(CGRect)screenFrame;
-(void) randomizeTile;
-(void) tilePieceTapped:(TileObject *) tilePiece ;
-(void) tilePiecePanned:(TileObject *) tilePiece translation:(CGPoint) translation state:(NSUInteger) state;
-(BOOL) isPuzzleSolved;
-(BOOL) isPuzzleSolvable;

-(void) disableUserEnabledInteraction;
-(void) enableUserEnabledInteraction;
-(NSString*) calculateElapseTime;
-(void) updateImageViews:(UIImage *) pickerImage;

@end
