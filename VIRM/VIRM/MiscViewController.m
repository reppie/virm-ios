//
//  MiscViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MiscViewController.h"
#import "AppDelegate.h"

@implementation MiscViewController

-(id)init
{
    printf("[MiscVC] Initialized.");
    return self;
}

- (void)goToOne {
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate displayView:1];
}

- (void)viewDidLoad {
	printf("[MiscVC] View loaded.\n");
	UIButton *btnOne = [UIButton buttonWithType:UIButtonTypeRoundedRect]; 
	btnOne.frame = CGRectMake(40, 40, 240, 30);
	[btnOne setTitle:@"Two!" forState:UIControlStateNormal];
	[btnOne addTarget:self action:@selector(goToOne) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnOne];
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
