//
//  SettingsViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsViewController : UIViewController {
    AppDelegate *appDelegate;
}
@property (retain, nonatomic) IBOutlet UILabel *maxDistanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *matchesNeededLabel;
@property (retain, nonatomic) IBOutlet UILabel *imageDimensionsLabel;

@property (retain, nonatomic) IBOutlet UISlider *setMaxDistance;
@property (retain, nonatomic) IBOutlet UISlider *setMatchesNeeded;
@property (retain, nonatomic) IBOutlet UISlider *setImageDimensions;

- (IBAction)applyChanges:(id)sender;
- (IBAction)resetToDefaults:(id)sender;

- (void) setDefaultValues;



@end
