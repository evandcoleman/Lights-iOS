//
//  LTFirstViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/17/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTColorViewController.h"
#import "KZColorPicker.h"
#import "LTAppDelegate.h"

@interface LTColorViewController ()

@property (nonatomic) KZColorPicker *colorPicker;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIPageControl *pageControl;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UISlider *speedSlider;
@property (nonatomic) UISlider *brightSlider;

@property (nonatomic) NSInteger currentOption;
@property (nonatomic, readonly) LKSession *session;

@end

@implementation LTColorViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Colors", @"Colors");
        self.tabBarItem.image = [UIImage imageNamed:@"flower"];
        self.currentOption = -1;
        _colorPicker = [[KZColorPicker alloc] initWithFrame:CGRectZero];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        self.scrollView.delegate = self;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [(UIControl *)self.colorPicker.alphaSlider setHidden:YES];
        
        _speedSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        self.speedSlider.minimumValueImage = [UIImage imageNamed:@"turtle"];
        self.speedSlider.maximumValueImage = [UIImage imageNamed:@"rabbit"];
        self.speedSlider.minimumValue = 1.0f;
        self.speedSlider.maximumValue = 200.0f;
        self.speedSlider.continuous = NO;
        [self.speedSlider addTarget:self action:@selector(speedChanged:) forControlEvents:UIControlEventValueChanged];
        _brightSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        self.brightSlider.minimumValueImage = [UIImage imageNamed:@"dark"];
        self.brightSlider.maximumValueImage = [UIImage imageNamed:@"now"];
        self.brightSlider.minimumValue = 100.0f;
        self.brightSlider.maximumValue = 255.0f;
        self.brightSlider.continuous = NO;
        [self.brightSlider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.frame = self.view.bounds;
    self.pageControl.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame)-60, CGRectGetWidth(self.view.frame), 37);
    self.scrollView.backgroundColor = self.colorPicker.backgroundColor;
    self.scrollView.delaysContentTouches = NO;
    
    self.scrollView.contentSize = CGSizeMake(640, self.scrollView.frame.size.height);
    self.tableView.frame = CGRectMake(320.0f, 0, 320.0f, self.scrollView.frame.size.height/1.5);
    
    self.colorPicker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.scrollView.frame.size.height);
	[self.colorPicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
	[self.scrollView addSubview:self.colorPicker];
    [self.scrollView addSubview:self.tableView];
    
    self.speedSlider.frame = CGRectMake(340.0f, (self.scrollView.frame.size.height/1.5) + 40.0f, 280.0f, 20);
    self.brightSlider.frame = CGRectMake(340.0f, self.speedSlider.frame.origin.y + 55.0f, 280.0f, 20);
    self.brightSlider.value = 255.0f;
    [self.scrollView addSubview:self.speedSlider];
    [self.scrollView addSubview:self.brightSlider];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.session queryStateWithBlock:^(LKResponse *response) {
        NSLog(@"%@", response.event);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *serverString = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTServerKey"];
    if ([serverString rangeOfString:@"home"].location != NSNotFound) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.view.frame];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.text = @"Not Available";
        [self.view addSubview:label];
        self.colorPicker.alpha = 0.5;
        self.scrollView.alpha = 0.5;
        self.view.userInteractionEnabled = NO;
    }
}

//- (void)didReceiveQueryResponse:(NSNotification *)notification {
//    NSDictionary *dict = notification.userInfo;
//    if([[dict objectForKey:@"event"] integerValue] == LTEventTypeSolid) {
//        NSArray *rgb = [dict objectForKey:@"color"];
//        UIColor *color = [UIColor colorWithRed:[[rgb objectAtIndex:0] floatValue]/255.0f green:[[rgb objectAtIndex:1] floatValue]/255.0f blue:[[rgb objectAtIndex:2] floatValue]/255.0f alpha:1.0f];
//        self.colorPicker.selectedColor = color;
//    } else if(dict == nil) {
//        self.colorPicker.selectedColor = [UIColor blackColor];
//    } else {
//        self.speedSlider.value = (self.speedSlider.maximumValue - [[dict objectForKey:@"speed"] integerValue]);
//        self.brightSlider.value = [[dict objectForKey:@"brightness"] integerValue];
//        self.currentOption = [[dict objectForKey:@"event"] integerValue];
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//        
//        [self.scrollView setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
//    }
//}
//
//- (void)connectionDidOpen:(NSNotification *)notification {
//    [[LTNetworkController sharedInstance] queryColor];
//}

#pragma mark - Sliders

- (void)brightnessChanged:(id)sender {
    if(self.currentOption >= 0) {
        LKEvent *event = [LKEvent animationEventWithType:self.currentOption speed:(self.speedSlider.maximumValue - self.speedSlider.value) brightness:self.brightSlider.value];
        [self.session sendEvent:event];
    }
}

- (void)speedChanged:(id)sender {
    if(self.currentOption >= 0) {
        LKEvent *event = [LKEvent animationEventWithType:self.currentOption speed:(self.speedSlider.maximumValue - self.speedSlider.value) brightness:self.brightSlider.value];
        [self.session sendEvent:event];
    }
}

#pragma mark - Color Picker

- (void)pickerChanged:(id)sender {
    self.currentOption = -1;
    [self.tableView reloadData];
    CGFloat red; CGFloat green; CGFloat blue; CGFloat alpha;
    [self.colorPicker.selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    LKColor *color = [LKColor colorWithRGB:@[@(red), @(green), @(blue)]];
    [self.session sendEvent:[LKEvent colorEventWithColor:color]];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

#pragma mark - Table View Delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.currentOption = [[@[] objectAtIndex:indexPath.row] integerValue];
//    switch (self.currentOption) {
//        case LKEventTypeAnimateColorWipe:
//            self.speedSlider.value = (self.speedSlider.maximumValue - 50.0f);
//            break;
//        case LKEventTypeAnimateRainbow:
//            self.speedSlider.value = (self.speedSlider.maximumValue - 20.0f);
//            break;
//        case LKEventTypeAnimateRainbowCycle:
//            self.speedSlider.value = (self.speedSlider.maximumValue - 20.0f);
//            break;
//        case LKEventTypeAnimateBounce:
//            self.speedSlider.value = (self.speedSlider.maximumValue - 20.0f);
//            break;
//        default:
//            break;
//    }
//    [[LTNetworkController sharedInstance] animateWithOption:self.currentOption brightness:self.brightSlider.value speed:(self.speedSlider.maximumValue - self.speedSlider.value)];
//    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;//[[[LTNetworkController sharedInstance] animationOptions] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
//    cell.textLabel.text = [[[LTNetworkController sharedInstance] animationOptions] objectAtIndex:indexPath.row];
//    if([[[LTNetworkController sharedInstance] animationIndexes] indexOfObject:[NSNumber numberWithInt:self.currentOption]] == indexPath.row) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
    return cell;
}

#pragma mark - Helpers

- (LKSession *)session {
    return [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
}

@end
