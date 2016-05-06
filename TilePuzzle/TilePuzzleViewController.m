//
//  TilePuzzleViewController.m
//  TilePuzzle
//
//  Created by Marvin Galang on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "TilePuzzleViewController.h"
#import "TileBoard.h"
#import "CustomImageViewController.h"

@interface TilePuzzleViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, retain) TileBoard *board;
@property (nonatomic, retain) IBOutlet UILabel *timerLabel;
@property (nonatomic, assign) SystemSoundID tickSoundID;
@property (nonatomic, assign) BOOL soundSwitch;
@property (nonatomic, retain) IBOutlet UIView *menuView;
@property (nonatomic, retain) IBOutlet UIButton *soundButton;



-(IBAction)reShuffleTile:(id)sender;
-(IBAction)presentMenu:(id)sender;
-(IBAction)toggleSound:(id)sender;
-(void) addGestureRecognizersToPiece:(TileObject *)tilePiece;
-(void) moveTilePiece:(UITapGestureRecognizer *)gestureRecognizer;
-(void) panTilePiece:(UIPanGestureRecognizer *)gestureRecognizer;
-(void) checkPuzzleSolved;
-(void) updateTimerLabel:(id)sender;
-(void) rearrangeTile;

@end

@implementation TilePuzzleViewController

@synthesize board=board_;
@synthesize timer=timer_;
@synthesize timerLabel=timerLabel_;
@synthesize tickSoundID=tickSoundID_;
@synthesize soundSwitch=soundSwitch_;
@synthesize menuView=_menuView;
@synthesize soundButton=soundButton_;


#pragma mark - initializers/destructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.board=[[[TileBoard alloc] initWithScreenFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
        self.soundSwitch=YES;
    }
    return self;
}

- (void)dealloc 
{   
    self.board=nil;
    self.timerLabel=nil;
    [self.timer invalidate];
    self.timer=nil;
    [super dealloc];
}

#pragma mark

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib. Do not call super loadview
//- (void)loadView {
//    
//    self.view=[[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]]autorelease];
//    UILabel *label=[[UILabel alloc] init];
//    label.frame=CGRectMake(60, 14, 200, 21);
//    label.textColor=[UIColor whiteColor];
//    label.backgroundColor=[UIColor blackColor];
//    label.text=@"Tile Puzzle";
//    [self.view addSubview:label];
//    [label release];
//}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i=0; i<9 ; i++) {
        TileObject *tileView=[self.board.tiles objectAtIndex:i];
        if (tileView.tileNumber==9) tileView.hidden=YES;
        [self.view addSubview:tileView];
        
    }
    
    [self.board.tiles removeAllObjects];
    
    int j=0;
    //load the newly created subviews to the board tiles array
    for (UIView *oneView in self.view.subviews) {
        if ([oneView isMemberOfClass:[TileObject class]]) {
            TileObject *tileObj=(TileObject *) oneView;
            [self addGestureRecognizersToPiece:tileObj];
            [self.board.tiles addObject:tileObj];
            
            if (tileObj.tileNumber==9) {
                self.board.noTileRow=tileObj.row;
                self.board.noTileCol=tileObj.column;
                self.board.noTileIndex=j;  //will not change throughout the duration of the apps.
            }
            j++;
        }
    }
    
    
    [self.board randomizeTile];
    
    while ([self.board isPuzzleSolvable]==NO) {
        [self.board randomizeTile];
    }
    
    
    [self.board enableUserEnabledInteraction];
    
    //invoke Timer
    self.timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel:) userInfo:nil repeats:YES];
    
    //Initialize and build the tick sound
    NSString *soundPath = [[NSBundle mainBundle] 
                            pathForResource:@"start" ofType:@"wav"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &tickSoundID_);
    

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.timerLabel=nil;
    [self.timer invalidate];
    self.timer=nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Add GestureRecognizer method

-(void)addGestureRecognizersToPiece:(TileObject *)tilePiece {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveTilePiece:)];
    [tilePiece addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panTilePiece:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setDelegate:self];
    [tilePiece addGestureRecognizer:panGesture];
    [panGesture release];
    
}

#pragma mark - Tile Management

-(IBAction)reShuffleTile:(id)sender {
    
    [self rearrangeTile];
}

- (void)moveTilePiece:(UITapGestureRecognizer *)gestureRecognizer
{
    TileObject *piece = (TileObject *) [gestureRecognizer view];
    [self.board tilePieceTapped:piece];    
    if (self.soundSwitch==YES) AudioServicesPlaySystemSound(tickSoundID_);
    [self checkPuzzleSolved];

}

// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)panTilePiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    TileObject *tilePiece = (TileObject *)[gestureRecognizer view];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged || [gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gestureRecognizer translationInView:[tilePiece superview]];
        
        [self.board tilePiecePanned:tilePiece translation:translation state:[gestureRecognizer state]];
        [gestureRecognizer setTranslation:CGPointZero inView:[tilePiece superview]];
    }
    
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        if (self.soundSwitch==YES) AudioServicesPlaySystemSound(tickSoundID_);
        [self checkPuzzleSolved];
    }
    
}

#pragma mark 

-(void) checkPuzzleSolved {
    BOOL puzzleSolved=[self.board isPuzzleSolved];
    if (puzzleSolved==YES) {
        
        ////Initialize and build the tick sound
        SystemSoundID clapSoundID;
        NSString *soundPath = [[NSBundle mainBundle] 
                               pathForResource:@"clap" ofType:@"wav"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &clapSoundID);
        if (self.soundSwitch==YES) AudioServicesPlaySystemSound(clapSoundID);
        
        
        TileObject *tileObj=[self.board.tiles objectAtIndex:self.board.noTileIndex];
        tileObj.hidden=NO;
        
        tileObj.alpha=0.0;
        
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             
                             tileObj.alpha=1.0;
                             
                         } 
                         completion:^(BOOL finished){
                             [self.timer invalidate];
                             self.timer=nil;
                             [self.board disableUserEnabledInteraction];
                             UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Congratulations" message:[NSString stringWithFormat:@"You Solved the Puzzle in %@",self.timerLabel.text] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil]autorelease];
                             [alert show];
                         }];
    
        
    }
    
}

-(void) updateTimerLabel:(id)sender; {
    self.timerLabel.text=[self.board calculateElapseTime];
}

- (IBAction)presentMenu:(id)sender;
{
    
    if (![self.menuView superview]) {
    
        UINib *imageSourceNib = [UINib nibWithNibName:@"MenuIphone" bundle:nil];
        [imageSourceNib instantiateWithOwner:self options:nil];
    
    
        //set image source view frame further down the screen
        CGRect animatedViewFrame = self.menuView.frame;
        animatedViewFrame.origin.y = 0;
        animatedViewFrame.origin.x = -38;
        self.menuView.frame = animatedViewFrame;
        self.menuView.alpha=0.0;
        
        if (self.soundSwitch==YES)
            [self.soundButton setTitle:@"Sound Off" forState:UIControlStateNormal];
        else [self.soundButton setTitle:@"Sound On" forState:UIControlStateNormal];
    
        [self.view addSubview:self.menuView];
    
    
        animatedViewFrame.origin.y = 44;
        animatedViewFrame.origin.x = 0.5;

    
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{_menuView.alpha = 1.0; _menuView.frame = animatedViewFrame;
        } completion:nil];
    }
        
    else {
        
        CGRect animatedViewFrame = self.menuView.frame;
        animatedViewFrame.origin.y = 0;
        animatedViewFrame.origin.x = -38;

        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
            _menuView.alpha = 0.0; 
            _menuView.frame = animatedViewFrame;
        } completion:^(BOOL finished){ [_menuView removeFromSuperview]; }];
        
    }
    
}

- (IBAction)toggleSound:(id)sender;
{
        self.soundSwitch=!self.soundSwitch;
        
        CGRect animatedViewFrame = self.menuView.frame;
        animatedViewFrame.origin.y = 0;
        animatedViewFrame.origin.x = -38;
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
            _menuView.alpha = 0.0; 
            _menuView.frame = animatedViewFrame;
        } completion:^(BOOL finished){ [_menuView removeFromSuperview]; }];
}


- (IBAction)selectImage:(id)sender {
    
    //Remove imageSourceView from superView
    CGRect animatedViewFrame = self.menuView.frame;
    animatedViewFrame.origin.y = 0;
    animatedViewFrame.origin.x = -38;
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        _menuView.alpha = 0.0; 
        _menuView.frame = animatedViewFrame;
    } completion:^(BOOL finished){ [_menuView removeFromSuperview]; }];
    
    // Create an instance of UIImagePickerController
    UIImagePickerController *imagePickerController = [[[UIImagePickerController alloc] init]autorelease];

    //Get photo from the photo Library
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Become the delegate of the image picker so we're informed when it has cancelled or taken a new photo
    imagePickerController.delegate = self;
    
    // Present the image picker
    [self presentViewController:imagePickerController animated:YES completion:NULL];

}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    
    // Extract the new image from the picker
    UIImage *photoImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CustomImageViewController *imageSelector = [[[CustomImageViewController alloc] init]autorelease];
    imageSelector.image=photoImage;
    
    [picker presentViewController:imageSelector animated:YES completion:NULL];
    
    
    //[self dismissModalViewControllerAnimated:YES];
    
    
    
    [self.board updateImageViews:photoImage];
    
    //reshuffle tile
    [self rearrangeTile];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) rearrangeTile {
    
    //invalidate timer
    [self.timer invalidate];
    self.timer=nil;
    self.timerLabel.text=@"00:00:00";
    
    
    [self.board enableUserEnabledInteraction];
    
    [self.board randomizeTile];
    while ([self.board isPuzzleSolvable]==NO) {
        [self.board randomizeTile];
    }
    
    
    //invoke Timer
    self.timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel:) userInfo:nil repeats:YES];
}


@end
