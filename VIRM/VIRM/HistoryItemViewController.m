//
//  HistoryItemViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryItemViewController.h"
#import "HistoryItem.h"

@interface HistoryItemViewController()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation HistoryItemViewController

@synthesize historyItem = _historyItem, textView = _textView;
@synthesize masterPopoverController = _masterPopoverController;


#pragma mark - Managing the detail item

- (void)setHistoryItem:(HistoryItem *)newHistoryItem
{
    printf("[History] Setting new history item.\n");
    
    if (_historyItem != newHistoryItem) {
        _historyItem = newHistoryItem;
    
        // Update the view.
        [self configureView];
    }        
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PaintingIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell.
    cell.textLabel.text = self.historyItem.name;
    cell.detailTextLabel.text = self.historyItem.painter;
    
    UIGraphicsBeginImageContext(CGSizeMake(50, 50));
    [self.historyItem.image drawInRect:CGRectMake(0,0,50,50)];
    UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.imageView.image = thumb;
    
    return cell;
}

- (void)configureView
{
    HistoryItem *theHistoryItem = self.historyItem;
    
    if (theHistoryItem) {
        self.textView.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. In quis ligula sit amet purus convallis iaculis. Nam blandit diam nec nibh pretium ut interdum arcu pharetra. Ut non odio velit. Integer convallis porttitor dolor, a malesuada nulla convallis et. Pellentesque tortor est, interdum eget hendrerit sit amet, imperdiet vitae ipsum. Fusce ultrices leo et justo varius dignissim. Sed in fringilla nunc. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Ut luctus scelerisque eleifend. Donec nec nulla libero. Vivamus varius lorem eu sem dictum id accumsan leo rutrum. Sed odio arcu, viverra eu sagittis sed, pharetra quis nulla. Nam purus metus, ullamcorper vitae imperdiet a, posuere ac risus. Etiam sagittis, purus eget fermentum adipiscing, eros felis cursus lectus, non pulvinar arcu diam at urna. Etiam nec diam tortor. Praesent pulvinar ante eu est euismod sed gravida ipsum dapibus. Duis non metus ut ipsum porttitor sollicitudin. Nulla sit amet nibh eu quam elementum dictum et non sapien. Nunc ultrices nibh et eros aliquam interdum. Etiam vel lorem vitae neque mollis auctor quis et urna. Phasellus vitae orci neque, sit amet suscipit nulla. In hac habitasse platea dictumst. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean vestibulum, elit a tincidunt fermentum, urna libero pulvinar erat, vel semper eros urna vel est. Nam vitae felis massa, id iaculis orci. Vivamus in purus nec dolor mollis posuere quis eget felis. Etiam sed faucibus augue. Proin sollicitudin, lectus in pulvinar mattis, lacus tellus porttitor risus, fermentum tempus purus lorem vitae massa. Aenean rhoncus pharetra elit feugiat interdum. Duis at lobortis tellus. Nulla congue erat quam, ut varius magna. Aliquam erat volutpat. Phasellus nec ante non diam suscipit lacinia eget nec felis. Sed ultricies, elit aliquet vestibulum interdum, turpis est commodo velit, sit amet iaculis enim augue sit amet lorem. Sed porttitor ultricies arcu, in convallis felis lobortis sed. Sed ultrices ornare nibh ac venenatis. Aenean fringilla laoreet libero nec gravida. Cras a enim ut arcu aliquet fringilla ac quis mi. Curabitur iaculis porta augue, nec ultricies enim venenatis et. Curabitur consequat quam sed ipsum pulvinar ultricies. Curabitur posuere quam dictum magna pretium tincidunt. Pellentesque mattis vulputate quam et egestas. Aenean euismod elementum tellus, sit amet iaculis odio tempor nec. Donec ut nisi at lorem pellentesque consectetur. Donec dapibus mauris nunc, a mollis felis. Aliquam vestibulum quam rhoncus turpis consequat tincidunt. Etiam porttitor sem dignissim nunc tempor ut porttitor lacus luctus. Vestibulum ut enim velit, nec mattis augue. Nam non turpis eu libero venenatis pellentesque. Praesent ut augue non leo dignissim porttitor et at urna. In mi ante, rhoncus pretium mattis ut, vestibulum in lorem. Cras mi ipsum, porta eget elementum vitae, tincidunt eget arcu. Maecenas lacinia dapibus leo eu euismod. Sed diam dui, fermentum eu faucibus eu, interdum nec mi. Vivamus sed risus id nunc gravida pharetra. Pellentesque dignissim egestas libero, et fermentum nisl elementum ac. Aliquam sollicitudin massa ac massa ultrices tincidunt. Aenean gravida viverra ante, sed volutpat augue accumsan porttitor. Integer massa erat, fermentum sed congue eget, bibendum vel lorem. Maecenas vehicula elit ut neque posuere luctus ac eu justo. Pellentesque sed sem eu felis suscipit fringilla vitae et sem.";
    }   
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)dealloc {
    [_textView release];
    [_historyItem release];
    [super dealloc];
}
@end
