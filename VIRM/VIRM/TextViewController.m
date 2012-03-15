//
//  TextViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextViewController.h"
#import "AppDelegate.h"

@interface TextViewController ()

@end

@implementation TextViewController
@synthesize textView;

- (void)updateText {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    textView.text = appDelegate.text;
    printf("[TextVC] Text updated.\n");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    printf("[TextVC] Initialized.\n");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    printf("[TextVC] View appearing.\n");
    
    [self updateText];
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [textView release];
    [super dealloc];
}
@end
