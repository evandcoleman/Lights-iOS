//
//  LTSettingsViewController.m
//  Lights
//
//  Created by Evan Coleman on 11/27/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTSettingsViewController.h"
#import "LTAppDelegate.h"
#import "LTLoadingViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <SSKeychain/SSKeychain.h>

@interface LTSettingsViewController ()

@property (nonatomic) UITextField *serverField;

@end

@implementation LTSettingsViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
	
    CGFloat width = CGRectGetWidth(self.view.frame);
    
    self.serverField = [[UITextField alloc] initWithFrame:CGRectMake(10, 80, width-20, 24)];
    self.serverField.textAlignment = NSTextAlignmentCenter;
    UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *reconnectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    reconnectButton.frame = CGRectMake(width/4, CGRectGetMaxY(self.serverField.frame) + 10, width/2, 20);
    toggleButton.frame = CGRectMake(width/4, CGRectGetMaxY(reconnectButton.frame) + 10, width/2, 20);
    
    self.serverField.placeholder = @"Enter Server Address";
    self.serverField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"LTServerKey"];
    [reconnectButton setTitle:@"Reconnect" forState:UIControlStateNormal];
    [reconnectButton addTarget:self action:@selector(reconnect) forControlEvents:UIControlEventTouchUpInside];
    [toggleButton setTitle:@"Logout" forState:UIControlStateNormal];
    [toggleButton addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.serverField];
    [self.view addSubview:reconnectButton];
    [self.view addSubview:toggleButton];
}

- (void)toggle {
    [SSKeychain deletePasswordForService:@"edc-lights" account:[[NSUserDefaults standardUserDefaults] objectForKey:@"LTUsername"]];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"LTUsername"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    exit(0);
}

- (void)reconnect {
    [[(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session] suspendSession];
    [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] setSession:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.serverField.text forKey:@"LTServerKey"];
    
    [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] loginAndOpenSession];
}

@end
