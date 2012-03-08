//
//  MainViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"

@implementation MainViewController

- (void)goToTwo {
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate displayView:2];
}

- (void)viewDidLoad {
	printf("[MainVC] View loaded.\n");
	UIButton *btnOne = [UIButton buttonWithType:UIButtonTypeRoundedRect]; 
	btnOne.frame = CGRectMake(40, 40, 240, 30);
	[btnOne setTitle:@"One!" forState:UIControlStateNormal];
	[btnOne addTarget:self action:@selector(goToTwo) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnOne];
	
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
