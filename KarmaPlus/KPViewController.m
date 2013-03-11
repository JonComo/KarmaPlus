//
//  KPViewController.m
//  KarmaPlus
//
//  Created by Jon Como on 3/10/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "KPViewController.h"
#import <Social/Social.h>
#import <Parse/Parse.h>

@interface KPViewController () <PF_FBFriendPickerDelegate>
{
    PF_FBFriendPickerViewController *friendPickerController;
}

@end

@implementation KPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [PFFacebookUtils logInWithPermissions:@[@"publish_stream"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else {
            
            // After logging in with Facebook
            PF_FBRequest *request = [PF_FBRequest requestForMe];
            [request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSString *facebookId = [result objectForKey:@"id"];
                    [[PFUser currentUser] setObject:facebookId forKey:@"facebookId"];
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        //saved
                    }];
                }
            }];
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newGroup:(id)sender
{
    // Initialize the friend picker
    friendPickerController =
    [[PF_FBFriendPickerViewController alloc] init];
    // Set the friend picker title
    friendPickerController.title = @"Pick Friends";
    
    // TODO: Set up the delegate to handle picker callbacks, ex: Done/Cancel button
    
    // Load the friend data
    [friendPickerController loadData];
    
    [friendPickerController setDelegate:self];
    // Show the picker modally
    [friendPickerController presentModallyFromViewController:self animated:YES handler:nil];
}

-(void)facebookViewControllerDoneWasPressed:(id)sender
{
    NSLog(@"Friends: %@", friendPickerController.selection);
    
    NSMutableArray *requestIds = [NSMutableArray array];
    
    for (PF_FBGraphObject *object in friendPickerController.selection)
    {
        [requestIds addObject:object[@"id"]];
    }
    
    PFQuery *requestedUsers = [PFUser query];
    [requestedUsers whereKey:@"facebookId" containedIn:requestIds];
    
    [requestedUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Found some shiz: %@", objects);
    }];
    
    PFObject *group = [PFObject objectWithClassName:@"Group"];
    [group addObjectsFromArray:requestIds forKey:@"facebookIds"];
    [group saveInBackground];
}

@end
