//
//  ViewController.m
//  Example
//
//  Created by dave.trudes on 29.10.12.
//  Copyright (c) 2012 David Renoldner <hello@davetrudes.com>. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
}


- (void)openImagePicker:(id)sender
{
	self.imageView.image = nil;
	DTImagePickerController *picker = [[DTImagePickerController alloc] init];
	picker.showFullscreen = YES;
	picker.delegate = self;
	[self presentViewController:picker animated:YES completion:nil];
	//[self presentModalViewController:_picker animated:YES];
}

#pragma mark - DTImagePickerControllerDelegate methods
- (void)imagePickerController:(DTImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	DLog(@"imageinfo: %@", info);
	[self dismissViewControllerAnimated:YES completion:nil];
	UIImage *img = info[UIImagePickerControllerOriginalImage];
	self.imageView.image = img;
	DLog(@"img: %@", NSStringFromCGSize(img.size));
}

- (void)imagePickerControllerDidCancel:(DTImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


@end
