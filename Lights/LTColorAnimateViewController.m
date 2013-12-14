//
//  LTColorAnimateViewController.m
//  Lights
//
//  Created by Evan Coleman on 12/12/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTColorAnimateViewController.h"
#import "LTAppDelegate.h"

@interface LTColorAnimateViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UISlider *speedSlider;
@property (nonatomic) UISlider *brightnessSlider;

@property (nonatomic) NSArray *animations;
@property (nonatomic) NSInteger currentAnimation;

@end

@implementation LTColorAnimateViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _speedSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        _brightnessSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        _currentAnimation = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)/2);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.speedSlider.frame = CGRectMake(15, CGRectGetMaxY(self.tableView.frame) + 35, CGRectGetWidth(self.view.frame) - 30, 20);
    self.speedSlider.minimumValueImage = [UIImage imageNamed:@"turtle"];
    self.speedSlider.maximumValueImage = [UIImage imageNamed:@"rabbit"];
    self.speedSlider.minimumValue = 1.0f;
    self.speedSlider.maximumValue = 200.0f;
    self.speedSlider.continuous = NO;
    [self.speedSlider addTarget:self action:@selector(speedChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.speedSlider];
    
    self.brightnessSlider.frame = CGRectMake(20, CGRectGetMaxY(self.speedSlider.frame) + 45, CGRectGetWidth(self.view.frame) - 40, 20);
    self.brightnessSlider.minimumValueImage = [UIImage imageNamed:@"dark"];
    self.brightnessSlider.maximumValueImage = [UIImage imageNamed:@"now"];
    self.brightnessSlider.minimumValue = 100.0f;
    self.brightnessSlider.maximumValue = 255.0f;
    self.brightnessSlider.continuous = NO;
    [self.brightnessSlider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.brightnessSlider];
    
    LKSession *session = [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
    [session queryAnimationsWithBlock:^(NSArray *animations) {
        self.animations = animations;
        [self.tableView reloadData];
        
        [self getCurrentState];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getCurrentState];
}

- (void)getCurrentState {
    LKSession *session = [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
    [session queryStateWithBlock:^(LKEvent *event) {
        if (event.type != LKEventTypeSolid) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"animationId == %@", @(event.type)];
            NSArray *matches = [self.animations filteredArrayUsingPredicate:predicate];
            if ([matches count] > 0) {
                LKAnimation *anim = [matches firstObject];
                self.currentAnimation = [self.animations indexOfObject:anim];
                self.speedSlider.value = (self.speedSlider.maximumValue - anim.speed);
                self.brightnessSlider.value = anim.brightness;
                
                [self.tableView reloadData];
            }
        }
    }];
}

- (void)sendAnimationEvent {
    LKSession *session = [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
    LKAnimation *animation = self.animations[self.currentAnimation];
    [session sendEvent:[LKEvent animationEventWithType:animation.animationId speed:(self.speedSlider.maximumValue - self.speedSlider.value) brightness:self.brightnessSlider.value]];
}

#pragma mark - Interface actions

- (void)speedChanged:(id)sender {
    [self sendAnimationEvent];
}

- (void)brightnessChanged:(id)sender {
    [self sendAnimationEvent];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.animations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    LKAnimation *animation = self.animations[indexPath.row];
    cell.textLabel.text = animation.name;
    if(self.currentAnimation == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentAnimation = indexPath.row;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    LKAnimation *animation = self.animations[indexPath.row];
    
    self.speedSlider.value = animation.speed;
    self.brightnessSlider.value = animation.brightness;
    
    [self sendAnimationEvent];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
