//
//  TileObject.m
//  TilePuzzle
//
//  Created by Marvin Galang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TileObject.h"

@interface TileObject()

@end

@implementation TileObject

@synthesize row=row_;
@synthesize column=column_;
@synthesize tileNumber=tileNumber_;


#pragma mark - initializers/destructors
- (id)initWithTileNumber:(CGRect)frame row:(NSUInteger) row column:(NSUInteger) column tileNumber:(NSUInteger) tileNumber
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame=frame;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        imageView.image=[UIImage imageNamed:@"YellowSquare.png"];
        [self addSubview:imageView];
        [imageView release];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        label.textAlignment=UITextAlignmentCenter;
        label.text=[NSString stringWithFormat:@"%i",tileNumber];
        label.backgroundColor=[UIColor clearColor];
        label.textColor=[UIColor blackColor];
        label.font=[label.font fontWithSize:frame.size.height/2];
        [self addSubview:label];
        [label release];
        
        self.userInteractionEnabled=YES;
        self.exclusiveTouch=YES;
        self.row=row;
        self.column=column;
        self.tileNumber=tileNumber;
        
    }
    return self;
}

- (void)dealloc 
{
    [super dealloc];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
