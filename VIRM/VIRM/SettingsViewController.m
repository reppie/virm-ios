//
//  SettingsViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize maxDistanceLabel;
@synthesize matchesNeededLabel;
@synthesize imageDimensionsLabel;
@synthesize setMaxDistance;
@synthesize setMatchesNeeded;
@synthesize setImageDimensions;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];    
    
    [self setDefaultValues];
}

- (void)viewDidUnload
{
    [self setSetMaxDistance:nil];
    [self setSetMatchesNeeded:nil];
    [self setSetImageDimensions:nil];
    [self setMaxDistanceLabel:nil];
    [self setMatchesNeededLabel:nil];
    [self setImageDimensionsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [setMaxDistance release];
    [setMatchesNeeded release];
    [setImageDimensions release];
    [maxDistanceLabel release];
    [matchesNeededLabel release];
    [imageDimensionsLabel release];
    [super dealloc];
}
- (IBAction)applyChanges:(id)sender {
    appDelegate.maxDistance = (int) setMaxDistance.value;
    maxDistanceLabel.text = [NSString stringWithFormat:@"%i", (int) setMaxDistance.value];
    
    appDelegate.matchesNeeded = (int) setMatchesNeeded.value;
    matchesNeededLabel.text = [NSString stringWithFormat:@"%i", (int) setMatchesNeeded.value];

    imageDimensionsLabel.text = [NSString stringWithFormat:@"%i * %i", (int) setImageDimensions.value, (int) setImageDimensions.value];    
    appDelegate.imageDimensions = (int) setImageDimensions.value;     
}

- (IBAction)resetToDefaults:(id)sender {
    [appDelegate setDefaultValues];
    [self setDefaultValues];
}

- (void) setDefaultValues {
    setMaxDistance.value = (float) appDelegate.maxDistance;
    setMatchesNeeded.value = (float) appDelegate.matchesNeeded;
    setImageDimensions.value = (float) appDelegate.imageDimensions;
    
    maxDistanceLabel.text = [NSString stringWithFormat:@"%i", appDelegate.maxDistance];
    matchesNeededLabel.text = [NSString stringWithFormat:@"%i", appDelegate.matchesNeeded];
    imageDimensionsLabel.text = [NSString stringWithFormat:@"%i * %i", appDelegate.imageDimensions, appDelegate.imageDimensions];    
}
@end
