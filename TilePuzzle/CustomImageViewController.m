
//
//  CustomImageViewController.m
//  TilePuzzle
//
//  Created by Marvin Galang on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomImageViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface CustomImageViewController()

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (void)prepareForScrollingWithImage:(UIImage *)image;
- (void)prepareForZoomingWithImage:(UIImage *)image;

@end

@implementation CustomImageViewController

@synthesize imageView=_imageView;
@synthesize image=_image;
@synthesize overlayView=_overlayView;
@synthesize scrollView=_scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.imageView.image=self.image;
    self.overlayView.layer.borderColor=[UIColor redColor].CGColor;
    self.overlayView.layer.borderWidth=3.0;
    
    [self prepareForScrollingWithImage:self.image];
    [self prepareForZoomingWithImage:self.image];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidLayoutSubviews;
{
    [super viewDidLayoutSubviews];
    
    // Center the imageView within the scroll view's bounds
    CGRect imageViewFrame = self.imageView.frame;
    
    CGSize scrollViewBoundsSize = self.scrollView.bounds.size;
    
    if (imageViewFrame.size.width < scrollViewBoundsSize.width) {
        imageViewFrame.origin.x = floorf((scrollViewBoundsSize.width - imageViewFrame.size.width) / 2);
    }
    
    if (imageViewFrame.size.height < scrollViewBoundsSize.height) {
        imageViewFrame.origin.y = floorf((scrollViewBoundsSize.height - imageViewFrame.size.height) / 2);
    }
    
    self.imageView.frame = imageViewFrame;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    NSLog(@"Scrolled to %@", NSStringFromCGPoint(scrollView.contentOffset));
}

// This is only required if you need to implement zooming
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
{
    return self.imageView;
}


- (void)prepareForScrollingWithImage:(UIImage *)image;
{
    // Set image
    self.imageView.image = image;
    
    // Make image view match image size
    //CGSize imageSize = image.size;
    
    CGSize imageSize=self.imageView.frame.size;
    
    CGRect imageViewFrame = self.imageView.frame;
    
    imageViewFrame.size = imageSize;
    
    self.imageView.frame = imageViewFrame;
    
    // Set content size
    self.scrollView.contentSize = imageSize;
}

- (void)prepareForZoomingWithImage:(UIImage *)image;
{
    CGSize scrollViewBoundsSize = self.scrollView.bounds.size;
    CGSize imageSize = image.size;
    
    // Calculate the min scale
    CGFloat xScale = scrollViewBoundsSize.width / imageSize.width;
    CGFloat yScale = scrollViewBoundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    // Calculate the max scale
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
    
    // Clamp the min scale to the max scale
    if (minScale > maxScale)
        {
        minScale = maxScale;
        }
    
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.minimumZoomScale = minScale;
    
    // Set the initial zoom scale to be the minimum (to show the whole image)
    self.scrollView.zoomScale = self.scrollView.maximumZoomScale;
}


@end
