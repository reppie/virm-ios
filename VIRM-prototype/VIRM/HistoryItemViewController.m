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
        if([self.historyItem.name isEqualToString: @"Mona Lisa"]) {
            self.textView.text = @"De Mona Lisa (in sommige Romaanse talen zoals het Italiaans als La Gioconda of Monna Lisa aangeduid; Frans: La Joconde) is een olieverfschilderij dat Leonardo da Vinci schilderde tussen 1503 en 1507. De gebruikte techniek is olieverf op paneel (populierenhout), de afmetingen zijn 77 × 53 cm. Het is waarschijnlijk het bekendste schilderij ter wereld Het schilderij is vooral beroemd geworden vanwege de glimlach van de Mona Lisa, die vaak als 'mysterieus' omschreven wordt. De beschrijving van kunstenaarsbiograaf Giorgio Vasari ligt hier waarschijnlijk aan ten grondslag. Hij omschreef de glimlach als eerder goddelijk dan menselijk. Anderen zijn van mening dat de geportretteerde heel neutraal kijkt. Bij vergelijking van dit schilderij met andere schilderijen uit het begin van de 16e eeuw blijkt hoe ver Da Vinci zijn tijd vooruit was, vooral door het gebruik van zijn sfumato-schildertechniek. Ook opvallend is dat de linkerhorizon lager ligt dan de rechter. Dit optische middel is waarschijnlijk gebruikt om de contraposto-houding van het model te benadrukken. Er zijn opvallende gelijkenissen tussen het gezicht van Da Vinci en het gezicht op het schilderij; sommige mensen menen dat de Mona Lisa een verhuld zelfportret is.[3] De opdrachtgever heeft het schilderij waarschijnlijk nooit in ontvangst genomen; tot nu toe is onduidelijk wat de reden daarvan is. Da Vinci nam het schilderij mee toen hij aan het hof van de Franse koning Frans I ging werken.Na de dood van Da Vinci is het schilderij waarschijnlijk in handen van de Franse koning gekomen. Het hing gedurende de 16e eeuw in het kasteel van Fontainebleau. In de loop van de tijd heeft het vele hoogte- en dieptepunten gekend. Het hing in de slaapkamer van Napoleon Bonaparte, maar heeft ook enkele decennia op een stoffige zolder gelegen. Sinds de 18e eeuw bevindt het schilderij zich in het Franse nationale museum, het Musée du Louvre in Parijs. Op 21 augustus 1911 werd de Mona Lisa op klaarlichte dag gestolen. De volgende dag ontdekte de schilder Louis Béroud de diefstal. Op de plaats in de Salon Carré waar de Mona Lisa had moeten hangen, bevonden zich nu slechts vier ijzeren haakjes. Béroud informeerde bij de bewaking waar het schilderij was en zij dachten dat het gefotografeerd werd. Een paar uur later bleek dat het schilderij niet bij de fotografen was en het Musée du Louvre werd een week gesloten om in alle rust onderzoek te kunnen doen. Het onderzoek liep al snel dood en men ging ervan uit dat het schilderij voorgoed verdwenen was. Pas twee jaar later werd de dief gevonden. Vincenzo Peruggia, medewerker van het Louvre, had zich in een bezemkast verstopt en was op de sluitingsdag van het Louvre met het schilderij onder zijn jas het museum uitgelopen. Peruggia was een Italiaanse patriot die vond dat het schilderij in een Italiaans museum hoorde te hangen. Het is ook mogelijk dat hij een vriend had die kopieën van het schilderij verkocht. Nadat Peruggia het schilderij twee jaar in zijn appartement had bewaard, werd hij ongeduldig en probeerde het te verkopen aan de directie van het Uffizi in Florence. Hij werd gepakt en het schilderij maakte een tournee door Italië voordat het in 1913 werd teruggegeven aan het Louvre. Peruggia werd een Italiaanse held en bracht slechts een paar maanden in de gevangenis door. R.A. Scotti schreef een boek over de geschiedenis van de diefstal, De verdwenen Mona Lisa. In 2004 maakten medewerkers van het Louvre zich zorgen over de staat waarin het paneel verkeert. Dit paneel, van populierenhout, trekt krom. Om de oorzaak te achterhalen is in april 2004 begonnen met een wetenschappelijke en technische studie van het schilderij. Detail van de kanttekening die zou bewijzen dat Lisa del Giocondo model stond voor de Mona Lisa: ut est Caput lisę del gio / condo (Dit is het hoofd van lisę del gio / cond. In januari 2008 vonden onderzoekers van de Universiteit van Heidelberg het bewijs dat het om Lisa del Giocondo gaat. Zij vonden dit in aantekeningen in de kantlijn van een oud boek, die twee jaar eerder al waren gevonden door Dr. Armin Slechter. Het boek was ooit eigendom van Agostino Vespucci, een kennis van Da Vinci die voor het stadsbestuur in Firenze werkte. Volgens Silvano Vinceti en zijn team, dat gespecialiseerd is in het oplossen van kunstmysteries, echter, was het model voor de Mona Lisa Salai (Gian Giacomo Caprotti), de leerling uit Florence en mogelijke minnaar van Da Vinci.[5] Onder andere zou er in de ogen een piepkleine L(eonardo) en S(alai) zijn geschilderd. Het Louvre betwist dit, omdat het team van Vinceti een hoogwaardige digitale kopie van het schilderij had bestudeerd. In januari 2012 werd een kopie van de Mona Lisa gevonden die lang in een depot van het Prado-museum lag. Deze kopie is waarschijnlijk tegelijkertijd met het origineel gemaakt.";
        }
        else if([self.historyItem.name isEqualToString: @"De Nachtwacht"]) {
            self.textView.text = @"Al in de 16e eeuw organiseerden vrijwilligers, op de manier van de beroepsgilden, zich in burgerwachten, zogenoemde schutterscompagnieën, om in tijden van oorlog of oproer ook werkelijk in actie te komen om de veiligheid van de republiek te waarborgen. Later verloren zij hun functie, al bleef het decorum. De schutterscompagnieën verwerden tot ceremoniële gezelschappen met een niet onaanzienlijke invloed: politieke machtsuitoefening en functies werden er vergeven. Zij beschikten over een eigen gebouw, doelen geheten, waar zij oefenden en bijeenkwamen bij feestelijke gelegenheden. De schutterscompagnieën dienden ook als erewacht, zoals bij de feestelijke intocht in 1638 van Maria de' Medici in Amsterdam.De compagnie van Frans Banning Cocq was een van de schutterscompagnieën van Amsterdam. Vanaf het eind van de 16e eeuw had elke stadswijk in Amsterdam zo'n compagnie, die was onderverdeeld in vier korporaalschappen. De schutterscompagnieën waren met de verdediging van de stad belast. Aan het hoofd van elke compagnie stonden een kapitein, en diens plaatsvervangende luitenant. Verder kende elke compagnie een vaandeldrager. Het was een voornaam gezelschap waarvan de officieren en de leden er alle belang bij hadden om zich mooi uitgedost te laten portretteren.In 1638 besloot een groep schutters zichzelf te laten vereeuwigen door hun wijkgenoot Rembrandt van Rijn die aan de Breestraat woonde, niet ver van de Kloveniersdoelen. Het motief of het eigenlijke onderwerp van het grote doek staat kort beschreven in het latere familiealbum van Banning Cocq, naast een kleine aquarel van het schilderij; de heren dragen hier hun chique naam als landjonker: Schets van de schilderije op de groote Sael van de Cleveniers Doelen, daerinne de Jonge Heer van Purmerlandt als Capiteijn, geeft last aen zijnen Lieutenant, de Heer van Vlaerdingen, om sijn Compaignie burgers te doen marcheren.Rembrandt hield het schilderij tamelijk donker waardoor hij met lichteffecten de aandacht op bepaalde partijen kon vestigen. Door verkleuring van het vernis werd het schilderij nog veel donkerder, waardoor onterecht werd aangenomen dat het scenario op het schilderij zich 's nachts afspeelt. Zo kreeg het in de 18e eeuw als bijnaam De Nachtwacht.Rembrandt heeft het enorme doek waarschijnlijk in een galerij op de binnenplaats van zijn woning geschilderd.[3] Toen het doek klaar was, klaagden sommige geportretteerden over hun onherkenbaarheid op het werk. Daarop heeft later een andere schilder een medaillon bijgeschilderd, rechts in de boog van de poort, met de namen van al de 18 geportretteerden.Bas Dudok van Heel ontrafelde de onderlinge familiebetrekkingen van de 18 personen, afgebeeld op De Nachtwacht.[4] [5] Bovendien reconstrueerde hij de situering van de verschillende schuttersstukken in de grote zaal van de Kloveniersdoelen.";
        }
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
