//
//  ViewController.h
//  Example
//
//  Created by dave.trudes on 29.10.12.
//  Copyright (c) 2012 David Renoldner <hello@davetrudes.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTImagePickerController.h"

@interface ViewController : UIViewController <DTImagePickerControllerDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (IBAction)openImagePicker:(id)sender;

@end
