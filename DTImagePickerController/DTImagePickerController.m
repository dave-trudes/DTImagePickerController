// DTImagePickerController.m
// 
// Copyright (c) 2012 David Renoldner <hello@davetrudes.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DTImagePickerController.h"

@implementation DTImagePickerController {
	
	BOOL _isPhotoLibraryOpening, _isPhotoLibraryOpened;
}

#pragma mark - Synthesizers
@synthesize controlBar = _controlBar;
@synthesize captureView = _captureView;

#pragma mark - Initialization & setup
- (id)init
{
	self = [super init];
	if (self) {
		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		self.showFullscreen = YES;
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor greenColor];
	
	//DTCaptureView
	if (self.hasRearCamera) {
		DTCaptureView *captureView = self.captureView;
		CGRect frame = self.view.frame;
		frame.origin = CGPointZero;
		[self.view addSubview:captureView];
	}
	
	//ControlBar
	DTImagePickerControlBar *controlBar = self.controlBar;
	CGRect frame = controlBar.frame;
	frame.origin.y = self.view.frame.size.height - frame.size.height;
	controlBar.frame = frame;
	[self.view addSubview:controlBar];

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (_showFullscreen) {
		[[UIApplication sharedApplication] setStatusBarHidden:YES
												withAnimation:animated ? UIStatusBarAnimationFade : 0];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	DLog(@"frame: %@", NSStringFromCGRect(_captureView.frame));
	if (_captureView) [_captureView startCamera];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	if (_showFullscreen) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO
												withAnimation:animated ? UIStatusBarAnimationFade : 0];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	//Don't stop camera session if we are opening the library picker
	if (_captureView && !_isPhotoLibraryOpening) [_captureView stopCamera];
}


#pragma mark - Property setter / getter
- (DTCaptureView *)captureView
{
	if (_captureView == nil) {
		self.captureView = [[DTCaptureView alloc] initWithFrame:self.view.frame];
	}
	return _captureView;
}

- (void)setCaptureView:(DTCaptureView *)captureView
{
	_captureView = captureView;
	_captureView.delegate = self;
	_captureView.backgroundColor = [UIColor yellowColor];
	_captureView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
}

- (DTImagePickerControlBar *)controlBar
{
	if (_controlBar == nil) {
		self.controlBar = [DTImagePickerControlBar newFromNib];
	}
	return _controlBar;
}

//Sets and configures the control bar
- (void)setControlBar:(DTImagePickerControlBar *)controlBar
{
	_controlBar = controlBar;
	_controlBar.alpha = 0.5;
	//Configure controlBar
	_controlBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	
	//Add event listener
	[_controlBar.cancelButton addTarget:self action:@selector(cancel)
					   forControlEvents:UIControlEventTouchUpInside];
	[_controlBar.takePictureButton addTarget:self action:@selector(takePicture)
							forControlEvents:UIControlEventTouchUpInside];
	[_controlBar.libraryButton addTarget:self action:@selector(openImageLibrary)
						forControlEvents:UIControlEventTouchUpInside];
	

}

#pragma mark - Feature detection getter
- (BOOL)hasRearCamera
{
	return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL)hasFrontCamera
{
	return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL)hasFlash
{
	return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
}

#pragma mark - Public
- (IBAction)takePicture
{
	if (_isPhotoLibraryOpened) return;
	if (_captureView) {
		[_captureView captureImage];
	}
}

- (IBAction)openImageLibrary
{
	if (_isPhotoLibraryOpened) return; //Cannot be opened twice
	
	UIImagePickerController *libraryController = [[UIImagePickerController alloc] init];
	libraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	libraryController.delegate = self;
	libraryController.allowsEditing = NO;
	
	_isPhotoLibraryOpening = YES;
	[self presentViewController:libraryController
					   animated:YES
					 completion:^(){
						 _isPhotoLibraryOpening = NO;
						 _isPhotoLibraryOpened = YES;
					 }];
}

- (IBAction)closeImageLibrary
{
	if (!_isPhotoLibraryOpened) return;
	
	[self dismissViewControllerAnimated:YES
							 completion:^(){
								 _isPhotoLibraryOpened = NO;
							 }];
}

- (void)cancel
{
	//Close library
	if (_isPhotoLibraryOpened) [self closeImageLibrary];
	
	if ([_delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
		[_delegate imagePickerControllerDidCancel:self];
	}
	
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	_isPhotoLibraryOpened = NO;
	//Stop camera since if a image is picked
	if (_captureView) [_captureView stopCamera];
	
	[self captureViewDidFinishCaptureImageWithInfo:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self closeImageLibrary];
}

#pragma mark - DTCaptureViewDelegate methods
- (void)captureViewDidFinishCaptureImageWithInfo:(NSDictionary *)mediaInfo
{
	if ([_delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
		[_delegate imagePickerController:self didFinishPickingMediaWithInfo:mediaInfo];
	}
}

- (void)captureViewDidFailCaptureImageWithError:(NSError *)error
{
	DLog(@"Error: %@", error.localizedDescription);
}
@end
