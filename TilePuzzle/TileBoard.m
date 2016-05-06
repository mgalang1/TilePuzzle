//
//  TileBoard.m
//  TilePuzzle
//
//  Created by Marvin Galang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TileBoard.h"
#import <QuartzCore/QuartzCore.h>

@interface TileBoard() 

@property (nonatomic, retain) TileObject* adjacentTileObj;
@property (nonatomic, assign) CGPoint boardOrigin;
@property (nonatomic, assign) CGFloat squareSize;
@property (nonatomic, retain) NSDate* beginTime;

-(void) calculateTileBoardOrigin:(CGRect) screenFrame;

@end

@implementation TileBoard
@synthesize tiles=tiles_;
@synthesize noTileCol=noTileCol_;
@synthesize noTileRow=noTileRow_;
@synthesize noTileIndex=noTileIndex_;
@synthesize boardOrigin=boardOrigin_;
@synthesize squareSize=squareSize_;
@synthesize adjacentTileObj=adjacentTileObj_;
@synthesize beginTime=beginTime_;

#pragma mark - initializers/destructors
- (id)initWithScreenFrame:(CGRect) screenFrame {
    self = [super init];
    if (self) {
        
        [self calculateTileBoardOrigin:screenFrame];
        
        //create tile in the correct order
        int tileNumber=1;
        self.tiles=[NSMutableArray array];
        for (int j=0; j<3; j++) 
            for (int i=0; i<3; i++)
            {
            TileObject *tileObj = [[TileObject alloc] initWithTileNumber:CGRectMake(self.boardOrigin.x + (i*self.squareSize) + i, self.boardOrigin.y + (j*self.squareSize) + j, self.squareSize, self.squareSize) row:j column:i tileNumber:tileNumber];
            [self.tiles addObject:tileObj];
            [tileObj release];
            tileNumber++;
        }
    }
    
    return self;
}

- (void)dealloc 
{   
    self.tiles=nil;
    self.adjacentTileObj=nil;
    [super dealloc];
}

#pragma mark - Tile Puzzle Calculation Methods

-(void) calculateTileBoardOrigin:(CGRect) screenFrame
{
    //calculate size of the squares
    self.squareSize= floorf((screenFrame.size.width-2)/3);
    CGPoint tileBoardOrigin=CGPointMake(0, 0);
    tileBoardOrigin.y=floorf((screenFrame.size.height/2)-(1.5 * self.squareSize));
    
    CGFloat offset = screenFrame.size.width - (3*self.squareSize) - 2;
    tileBoardOrigin.x=tileBoardOrigin.x+(offset/2);
    
    self.boardOrigin=tileBoardOrigin;
    
}

-(void) randomizeTile {
    
    srand((unsigned)time(NULL));
    for (int i=[self.tiles count]-1;i>=1;i--) {
        int randNumber = (rand() % (i+1));
        
        TileObject *swapObj=[self.tiles objectAtIndex:randNumber];
        NSUInteger swapRow=swapObj.row;
        NSUInteger swapColumn=swapObj.column;
        CGRect swapFrame=swapObj.frame;
        
        TileObject *lastObjInRange=[self.tiles objectAtIndex:i];
        
        //swap properties of the two objects
        swapObj.row=lastObjInRange.row;
        swapObj.column=lastObjInRange.column;
        
        [UIView animateWithDuration:0.6 animations:^{
            swapObj.frame=lastObjInRange.frame;
        }];
        
        lastObjInRange.row=swapRow;
        lastObjInRange.column=swapColumn;
        
        [UIView animateWithDuration:0.6 animations:^{
            lastObjInRange.frame=swapFrame;
        }];
            
    }
    
    //reset beginTime
    self.beginTime=[NSDate date];

    //scan objects and find where is the 9th tile number    
    for (int k=0; k<[self.tiles count] ; k++) {
        TileObject *tileObj= [self.tiles objectAtIndex:k];
        if (tileObj.tileNumber==9) {
            self.noTileRow=tileObj.row;
            self.noTileCol=tileObj.column;
            tileObj.hidden=YES;
            k=[self.tiles count];
        }
    }
}


-(void) tilePieceTapped:(TileObject *) tilePiece {
    
    //check if the piece that was tapped is adjacent to the tile number 9
    int colDiff=fabs((int)tilePiece.column-(int)self.noTileCol);
    int rowDiff=fabs((int)tilePiece.row-(int)self.noTileRow);
    
    //if adjacent to the hidden tile number
    if (colDiff + rowDiff ==1) {
        
        TileObject *swapObj=[self.tiles objectAtIndex:self.noTileIndex];
        NSUInteger swapRow=swapObj.row;
        NSUInteger swapColumn=swapObj.column;
        CGRect swapFrame=swapObj.frame;
    
        
        //swap properties of the two objects
        swapObj.row=tilePiece.row;
        swapObj.column=tilePiece.column;
        swapObj.frame=tilePiece.frame;
        
        //update tracking variable for the hidden tile Piece (e.g. tile number 9)
        self.noTileRow=tilePiece.row;
        self.noTileCol=tilePiece.column;
        
        //move the tapped Piece
        tilePiece.row = swapRow;
        tilePiece.column =swapColumn;
        
        [UIView animateWithDuration:0.2 animations:^{
            tilePiece.frame=swapFrame;
        }];
    }
}

-(void) tilePiecePanned:(TileObject *) tilePiece translation:(CGPoint) translation state:(NSUInteger) state {
    
    //check if the piece that was tapped is adjacent to the tile number 9
    int colDiff=fabs((int)tilePiece.column-(int)self.noTileCol);
    int rowDiff=fabs((int)tilePiece.row-(int)self.noTileRow);
    
    ////if the tile that is being panned is adjacent to board empty tile space only one tile piece will be moved.
    
    //if adjacent to the hidden tile number
    if (colDiff + rowDiff ==1) {

        //calculate lower boundary and upper boundary limit while being panned.
        CGFloat lowerXThreshold = MIN (self.boardOrigin.x + (tilePiece.column*self.squareSize) + tilePiece.column, self.boardOrigin.x + (self.noTileCol*self.squareSize) + self.noTileCol);
        CGFloat upperXThreshold = MAX (self.boardOrigin.x + (tilePiece.column*self.squareSize) + tilePiece.column, self.boardOrigin.x + (self.noTileCol*self.squareSize) + self.noTileCol);
        CGFloat lowerYThreshold = MIN (self.boardOrigin.y + (tilePiece.row*self.squareSize) + tilePiece.row,self.boardOrigin.y + (self.noTileRow*self.squareSize) + self.noTileRow) ;
        CGFloat upperYThreshold = MAX (self.boardOrigin.y + (tilePiece.row*self.squareSize) + tilePiece.row,self.boardOrigin.y + (self.noTileRow*self.squareSize) + self.noTileRow) ;
    
        CGFloat targetX= MIN(MAX(lowerXThreshold,tilePiece.frame.origin.x+translation.x),upperXThreshold);
    
        CGFloat targetY= MIN(MAX(lowerYThreshold,tilePiece.frame.origin.y+translation.y),upperYThreshold);
    
        tilePiece.frame=CGRectMake(targetX, targetY, self.squareSize, self.squareSize);
    
    
        if (state==3) {
        
            //determine where the moved tile position will be. The closer to the board tile slot the tilePiece will be position there.
            CGFloat xDiff1= fabs(self.boardOrigin.x + (tilePiece.column*self.squareSize) + tilePiece.column - tilePiece.frame.origin.x);
        
            CGFloat xDiff2=fabs(self.boardOrigin.x + (self.noTileCol*self.squareSize) + self.noTileCol - tilePiece.frame.origin.x);

            CGFloat yDiff1= fabs(self.boardOrigin.y + (tilePiece.row*self.squareSize) + tilePiece.row - tilePiece.frame.origin.y);
        
            CGFloat yDiff2=fabs(self.boardOrigin.y + (self.noTileRow*self.squareSize) + self.noTileRow - tilePiece.frame.origin.y);
        
        
            //if destination is the empty tile
            if (xDiff2<xDiff1 || yDiff2<yDiff1) {
            
                //swap the properties of the two tile
            
                TileObject *swapObj=[self.tiles objectAtIndex:self.noTileIndex];
                NSUInteger swapRow=swapObj.row;
                NSUInteger swapColumn=swapObj.column;
                CGRect swapFrame=swapObj.frame;
            
                swapObj.row=tilePiece.row;
                swapObj.column=tilePiece.column;
                swapObj.frame=CGRectMake(self.boardOrigin.x + (tilePiece.column*self.squareSize) + tilePiece.column, self.boardOrigin.y + (tilePiece.row*self.squareSize) + tilePiece.row, self.squareSize, self.squareSize);
            
                //update tracking variable for the hidden tile Piece (e.g. tile number 9)
                self.noTileRow=tilePiece.row;
                self.noTileCol=tilePiece.column;
            
                //move the tapped Piece
                tilePiece.row = swapRow;
                tilePiece.column =swapColumn;
            
                [UIView animateWithDuration:0.2 animations:^{
                tilePiece.frame=swapFrame;
                }];
            
                }
        
            else
                {
                
                CGRect oldFrame= CGRectMake(self.boardOrigin.x + (tilePiece.column*self.squareSize) + tilePiece.column, self.boardOrigin.y + (tilePiece.row*self.squareSize) + tilePiece.row, self.squareSize, self.squareSize);
            
                [UIView animateWithDuration:0.2 animations:^{
                tilePiece.frame=oldFrame;
                }];
                }
            }
        
        }
    
    //if the non adjacent other piece in the same row or column is being panned.
    if ( (colDiff + rowDiff ==2 && tilePiece.row==self.noTileRow) || ((colDiff + rowDiff ==2 && tilePiece.column==self.noTileCol)) ) {
        
        CGFloat adjacentRow=-1;
        CGFloat adjacentCol=-1;
        
        //determine the tile between the obect being panned and the empty tile
        if (tilePiece.row==self.noTileRow && self.noTileCol<tilePiece.column) {
            adjacentCol=tilePiece.column-1;
            adjacentRow=tilePiece.row;
            }
        
        if (tilePiece.row==self.noTileRow && self.noTileCol>tilePiece.column) {
            adjacentCol=tilePiece.column+1;
            adjacentRow=tilePiece.row;
        }
        
        if (tilePiece.column==self.noTileCol && self.noTileRow<tilePiece.row) {
            adjacentCol=tilePiece.column;
            adjacentRow=tilePiece.row-1;
        }
        
        if (tilePiece.column==self.noTileCol && self.noTileRow>tilePiece.row) {
            adjacentCol=tilePiece.column;
            adjacentRow=tilePiece.row+1;
        }
        
        
        //calculate lower boundary and upper boundary limit of the tile object being panned.
        CGFloat lowerXThreshold = MIN (self.boardOrigin.x + (tilePiece.column*self.squareSize) + tilePiece.column, self.boardOrigin.x + (adjacentCol*self.squareSize) + adjacentCol);
        CGFloat upperXThreshold = MAX (self.boardOrigin.x + (tilePiece.column*self.squareSize) + tilePiece.column, self.boardOrigin.x + (adjacentCol*self.squareSize) + adjacentCol);
        CGFloat lowerYThreshold = MIN (self.boardOrigin.y + (tilePiece.row*self.squareSize) + tilePiece.row,self.boardOrigin.y + (adjacentRow*self.squareSize) + adjacentRow) ;
        CGFloat upperYThreshold = MAX (self.boardOrigin.y + (tilePiece.row*self.squareSize) + tilePiece.row,self.boardOrigin.y + (adjacentRow*self.squareSize) + adjacentRow) ;
        
        
        //calculate lower boundary and upper boundary of the adjacent tile Piece.
        CGFloat lowerXThresholdAdj = MIN (self.boardOrigin.x + (adjacentCol*self.squareSize) + adjacentCol, self.boardOrigin.x + (self.noTileCol*self.squareSize) + self.noTileCol);
        CGFloat upperXThresholdAdj = MAX (self.boardOrigin.x + (adjacentCol*self.squareSize) + adjacentCol, self.boardOrigin.x + (self.noTileCol*self.squareSize) + self.noTileCol);
        CGFloat lowerYThresholdAdj = MIN (self.boardOrigin.y + (adjacentRow*self.squareSize) + adjacentRow,self.boardOrigin.y + (self.noTileRow*self.squareSize) + self.noTileRow) ;
        CGFloat upperYThresholdAdj = MAX (self.boardOrigin.y + (adjacentRow*self.squareSize) + adjacentRow,self.boardOrigin.y + (self.noTileRow*self.squareSize) + self.noTileRow) ;
        
        
        //determine the adjacent TileView Object
        if (!self.adjacentTileObj) {
            for (TileObject *oneView in self.tiles) {
                if (oneView.row==adjacentRow && oneView.column==adjacentCol) {
                    self.adjacentTileObj=(TileObject *) oneView;
                }
            }
        }
        
        CGFloat targetX= MIN(MAX(lowerXThreshold,tilePiece.frame.origin.x+translation.x),upperXThreshold);
        CGFloat targetY= MIN(MAX(lowerYThreshold,tilePiece.frame.origin.y+translation.y),upperYThreshold);
        
        
        CGFloat targetXAdj= MIN(MAX(lowerXThresholdAdj,self.adjacentTileObj.frame.origin.x+translation.x),upperXThresholdAdj);
        CGFloat targetYAdj= MIN(MAX(lowerYThresholdAdj,self.adjacentTileObj.frame.origin.y+translation.y),upperYThresholdAdj);
        
        
        
        //determine if the adjacent tile will be moved as well. If the movement is towards the empty tile then move the adjacent tile. Otherwise leave it there.
        
        //calculate difference in space between adjacentTile and Empty Tile Space
        CGFloat xDiffAdjPrev=fabs(self.boardOrigin.x + (self.noTileCol*self.squareSize) + self.noTileCol - self.adjacentTileObj.frame.origin.x);
        CGFloat yDiffAdjPrev=fabs(self.boardOrigin.y + (self.noTileRow*self.squareSize) + self.noTileRow - self.adjacentTileObj.frame.origin.y);
        CGFloat xDiffAdjNew=fabs(self.boardOrigin.x + (self.noTileCol*self.squareSize) + self.noTileCol - targetXAdj);
        CGFloat yDiffAdjNew=fabs(self.boardOrigin.y + (self.noTileRow*self.squareSize) + self.noTileRow - targetYAdj);
        
        if (xDiffAdjNew<xDiffAdjPrev || yDiffAdjNew<yDiffAdjPrev) {
            tilePiece.frame=CGRectMake(targetX, targetY, self.squareSize, self.squareSize);
            
            //if the position of the panned tile object has not reached yet the position of the adjacent object
            if ( (fabs(targetX-self.adjacentTileObj.frame.origin.x) <= self.squareSize+1 && fabs(targetY-self.adjacentTileObj.frame.origin.y)==0) || 
                (fabs(targetY-self.adjacentTileObj.frame.origin.y) <= self.squareSize+1 && fabs(targetX-self.adjacentTileObj.frame.origin.x)==0) )
                {
                self.adjacentTileObj.frame=CGRectMake(targetXAdj, targetYAdj, self.squareSize, self.squareSize);
                }
            }
        else
            {
            tilePiece.frame=CGRectMake(targetX, targetY, self.squareSize, self.squareSize);
            }
        
        
        if (state==3) {
            
            //Numbers needed to evaluate which row/column the panned tile object will fall.
            CGFloat oldOriginX=self.boardOrigin.x + (tilePiece.column*self.squareSize) + tilePiece.column;
            CGFloat oldOriginY=self.boardOrigin.y + (tilePiece.row*self.squareSize) + tilePiece.row;
            CGFloat targetOriginX=self.boardOrigin.x + (self.adjacentTileObj.column*self.squareSize) + self.adjacentTileObj.column;
            CGFloat targetOriginY=self.boardOrigin.y + (self.adjacentTileObj.row*self.squareSize) + self.adjacentTileObj.row;
            
            
            //Numbers needed to evaluate which row/column the adjacent tile object will fall.
            CGFloat oldOriginXAdj=self.boardOrigin.x + (self.adjacentTileObj.column*self.squareSize) + self.adjacentTileObj.column;
            CGFloat oldOriginYAdj=self.boardOrigin.y + (self.adjacentTileObj.row*self.squareSize) + self.adjacentTileObj.row;
            CGFloat targetOriginXAdj=self.boardOrigin.x + (self.noTileCol*self.squareSize) + self.noTileCol;
            CGFloat targetOriginYAdj=self.boardOrigin.y + (self.noTileRow*self.squareSize) + self.noTileRow;
            
            
            //if panned tile object moves to the new position then swap position of the three tiles
            if ( (fabs(tilePiece.frame.origin.x - targetOriginX) < fabs(tilePiece.frame.origin.x - oldOriginX)) || (fabs(tilePiece.frame.origin.y - targetOriginY) < fabs(tilePiece.frame.origin.y - oldOriginY)) ) {
                
                //store row and column of the panned object
                NSUInteger swapRow=tilePiece.row;
                NSUInteger swapColumn=tilePiece.column;
                
                //Panned tilePiece position will get the adjacent object's position
                tilePiece.row=self.adjacentTileObj.row;
                tilePiece.column=self.adjacentTileObj.column;
                
                //adjacent objects position will get empty tile's position
                self.adjacentTileObj.row=self.noTileRow;
                self.adjacentTileObj.column=self.noTileCol;
                
                [UIView animateWithDuration:0.2 animations:^{
                    tilePiece.frame=CGRectMake(self.boardOrigin.x + (tilePiece.column*self.squareSize) + tilePiece.column, self.boardOrigin.y + (tilePiece.row*self.squareSize) + tilePiece.row, self.squareSize, self.squareSize);
                    
                    self.adjacentTileObj.frame=CGRectMake(self.boardOrigin.x + (self.adjacentTileObj.column*self.squareSize) + self.adjacentTileObj.column, self.boardOrigin.y + (self.adjacentTileObj.row*self.squareSize) + self.adjacentTileObj.row, self.squareSize, self.squareSize);
                }];
                
                //empty tile piece will get the position of old position the panned object
                self.noTileRow=swapRow;
                self.noTileCol=swapColumn;
                TileObject *noTileObj=[self.tiles objectAtIndex:self.noTileIndex];
                noTileObj.row=swapRow;
                noTileObj.column=swapColumn;
                noTileObj.frame=CGRectMake(self.boardOrigin.x + (noTileObj.column*self.squareSize) + noTileObj.column, self.boardOrigin.y + (noTileObj.row*self.squareSize) + noTileObj.row, self.squareSize, self.squareSize);
                }
            
            //if panned object remain in the old position
            else {
                //set panned object to the original location
                [UIView animateWithDuration:0.2 animations:^{
                    tilePiece.frame=CGRectMake(self.boardOrigin.x + (tilePiece.column*self.squareSize) + tilePiece.column, self.boardOrigin.y + (tilePiece.row*self.squareSize) + tilePiece.row, self.squareSize, self.squareSize);
                }];
                
                //determine where the adjacent object will fall. If it closer to the empty tile location...
                if ( (fabs(self.adjacentTileObj.frame.origin.x - targetOriginXAdj) < fabs(self.adjacentTileObj.frame.origin.x - oldOriginXAdj)) || (fabs(self.adjacentTileObj.frame.origin.y - targetOriginYAdj) < fabs(self.adjacentTileObj.frame.origin.y - oldOriginYAdj)) )  {
                    
                    //swap the position of the adjacent object and the empty tile space
                    //store row and column of the adjacent object
                    NSUInteger swapRow=self.adjacentTileObj.row;
                    NSUInteger swapColumn=self.adjacentTileObj.column;
                    
                    //adjacent tile object will get the position of the empty tile space
                    self.adjacentTileObj.row=self.noTileRow;
                    self.adjacentTileObj.column=self.noTileCol;
                    [UIView animateWithDuration:0.2 animations:^{
                        self.adjacentTileObj.frame=CGRectMake(self.boardOrigin.x + (self.adjacentTileObj.column*self.squareSize) + self.adjacentTileObj.column, self.boardOrigin.y + (self.adjacentTileObj.row*self.squareSize) + self.adjacentTileObj.row, self.squareSize, self.squareSize);
                    }];
                    
                    self.noTileRow=swapRow;
                    self.noTileCol=swapColumn;
                    TileObject *noTileObj=[self.tiles objectAtIndex:self.noTileIndex];
                    noTileObj.row=swapRow;
                    noTileObj.column=swapColumn;
                    noTileObj.frame=CGRectMake(self.boardOrigin.x + (noTileObj.column*self.squareSize) + noTileObj.column, self.boardOrigin.y + (noTileObj.row*self.squareSize) + noTileObj.row, self.squareSize, self.squareSize);
                    }
                
                else {
                    [UIView animateWithDuration:0.2 animations:^{
                        self.adjacentTileObj.frame=CGRectMake(self.boardOrigin.x + (self.adjacentTileObj.column*self.squareSize) + self.adjacentTileObj.column, self.boardOrigin.y + (self.adjacentTileObj.row*self.squareSize) + self.adjacentTileObj.row, self.squareSize, self.squareSize);
                    }];
                    }
                
            }
            
            
            self.adjacentTileObj=nil; 
        }
     
        
    }
    
}

-(BOOL) isPuzzleSolved {
    
    for (int k=0; k<[self.tiles count] ; k++) {
        TileObject *tileObj= [self.tiles objectAtIndex:k];
        if ((tileObj.row*3 + tileObj.column + 1)!=tileObj.tileNumber) {
            return NO;
        }
    }
    return YES;
}

-(BOOL) isPuzzleSolvable {
    
    //store the tile object in a temporary array
    NSMutableArray *arrayTiles=[[NSMutableArray alloc] initWithArray:self.tiles];
    NSUInteger targetIndex;
    for (int k=0; k<[self.tiles count] ; k++) {
        TileObject *tileObj= [self.tiles objectAtIndex:k];
        targetIndex=(tileObj.row*3) + tileObj.column;
//        NSLog(@"%i,%i,%i",tileObj.row,tileObj.column,tileObj.tileNumber);
        [arrayTiles replaceObjectAtIndex:targetIndex withObject:(TileObject*) tileObj];
        }
    
    
//    for (int k=0; k<[arrayTiles count];k++) {
//        TileObject *tileObj= [arrayTiles objectAtIndex:k];
//        NSLog(@"%i,%i,%i",tileObj.row,tileObj.column,tileObj.tileNumber);
//    }
    
    //determine the #of inversions
    NSUInteger numInversion=0;
    for (int i=0; i<[arrayTiles count]-1 ; i++) {
        for (int j=i+1; j<[arrayTiles count]; j++) {
            if ([[arrayTiles objectAtIndex:i] tileNumber]>[[arrayTiles objectAtIndex:j] tileNumber] && [[arrayTiles objectAtIndex:i] tileNumber]<[arrayTiles count] )
                numInversion++;
        }
    }
    
    [arrayTiles release];
    
    if (numInversion % 2 ==0)
        return YES;
    else return NO;
}

#pragma mark

-(void) disableUserEnabledInteraction {
    
    for (int k=0; k<[self.tiles count] ; k++) {
        TileObject *tileObj= [self.tiles objectAtIndex:k];
        tileObj.userInteractionEnabled=NO;
    }
    
    
}
-(void) enableUserEnabledInteraction {
    
    for (int k=0; k<[self.tiles count] ; k++) {
        TileObject *tileObj= [self.tiles objectAtIndex:k];
        tileObj.userInteractionEnabled=YES;
    }
    
}

-(NSString*) calculateElapseTime {
    int hour;
    int minutes;
    int seconds;
    
    NSTimeInterval elapseSeconds;
    
    elapseSeconds = [[NSDate date] timeIntervalSinceDate:[self beginTime]];
    
    hour=elapseSeconds/3600;
    minutes=(elapseSeconds-(hour*3600))/60;
    seconds=elapseSeconds-(hour*3600)-(minutes*60);
    
    return [NSString stringWithFormat:@"%02i:%02i:%02d",hour,minutes,seconds];
}

-(void) changeTileImage:(UIImageView *) imageView image:(UIImage *) image {
    
    imageView.image=image;
}

-(void) updateImageViews:(UIImage *) pickerImage {
    
    
    
    if (pickerImage.size.width != 3*self.squareSize && pickerImage.size.height != 3*self.squareSize)
        {
        CGSize itemSize = CGSizeMake(3*self.squareSize, 3*self.squareSize);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[pickerImage drawInRect:imageRect];
		pickerImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        }
    
    
    CGSize imageSize = pickerImage.size;
    CGFloat normalizedPieceWidth = self.squareSize / imageSize.width;
    CGFloat normalizedPieceHeight = self.squareSize / imageSize.height;
    
    
    //slice image to 9 tile pieces
    TileObject *tileObj=nil;
    UIImageView *sliceTile=nil;
    
    for (int i=0; i<[self.tiles count]; i++) {
        
        tileObj=[self.tiles objectAtIndex:i];
        
        for (UIView *oneView in tileObj.subviews) {
            if ([oneView isMemberOfClass:[UIImageView class]]) 
                sliceTile=(UIImageView *) oneView;
            }
        
        CGFloat x=floorf((tileObj.tileNumber-1)/3);
        CGFloat y=tileObj.tileNumber-(x*3)-1;

        // set content rect 
        sliceTile.image=pickerImage;
        sliceTile.layer.contentsRect = CGRectMake(normalizedPieceWidth*y, normalizedPieceHeight*x, normalizedPieceWidth, normalizedPieceHeight);
    }
}


@end
