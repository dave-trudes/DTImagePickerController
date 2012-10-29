// DTCaptureView.m
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

#import "DTCaptureView.h"

@implementation DTCaptureView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)setup
{

}

#pragma mark - Settings
- (void)setFocusMode:(AVCaptureFocusMode)focusMode
{
	AVCaptureDevice *device = self.device;
	
	if ([device isFocusModeSupported:focusMode]) {
		
		NSError *error = nil;
		if ([device lockForConfiguration:&error]){
			device.focusMode = focusMode;
			[device unlockForConfiguration];
			_focusMode = focusMode;
		} else {
			DLog(@"Setting focusMode failed: %@", error.localizedDescription);
		}
	}
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
	AVCaptureDevice *device = self.device;
	
	if ([device isFlashModeSupported:flashMode]) {
		
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) {
			device.flashMode = flashMode;
			[device unlockForConfiguration];
			_flashMode = flashMode;
		} else {
			DLog(@"Setting flashMode failed: %@", error.localizedDescription);
		}
	}
}

- (AVCaptureDevice *)device
{
	return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

#pragma mark - Camera session handling
- (void)startCamera
{
	if (_isCameraRunning) return;
	
	_previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
	
}

- (void)stopCamera
{
	
}

-

@end
