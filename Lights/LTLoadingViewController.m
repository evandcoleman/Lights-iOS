//
//  LTLoadingViewController.m
//  Lights
//
//  Created by Evan Coleman on 11/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTLoadingViewController.h"

@interface LTLoadingViewController ()

@property (nonatomic) UIActivityIndicatorView *progressIndicator;

@end

@implementation LTLoadingViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _progressIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.progressIndicator.center = self.view.center;
    
    [self.view addSubview:self.progressIndicator];
    
    [self.progressIndicator startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
