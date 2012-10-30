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
#import "DTCaptureViewUtils.h"

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
	//Settting defaults
	self.focusMode = AVCaptureFocusModeAutoFocus;
	self.flashMode = AVCaptureFlashModeAuto;
	self.devicePosition = AVCaptureDevicePositionFront;
}

#pragma mark - Settings
- (void)setFocusMode:(AVCaptureFocusMode)focusMode
{
	_focusMode = focusMode;
	if (!_session) return;
	
	
	AVCaptureDevice *device = self.device;
	
	if ([device isFocusModeSupported:focusMode]) {
		
		NSError *error = nil;
		if ([device lockForConfiguration:&error]){
			device.focusMode = focusMode;
			[device unlockForConfiguration];
		} else {
			DLog(@"Setting focusMode failed: %@", error.localizedDescription);
		}
	}
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
	_flashMode = flashMode;
	if (!_session) return;
	
	AVCaptureDevice *device = self.device;
	
	if ([device isFlashModeSupported:flashMode]) {
		
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) {
			device.flashMode = flashMode;
			[device unlockForConfiguration];
		} else {
			DLog(@"Setting flashMode failed: %@", error.localizedDescription);
		}
	}
}

- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
	_whiteBalanceMode = whiteBalanceMode;
	if (!_session) return;
	
	AVCaptureDevice *device = self.device;
	if ([device isWhiteBalanceModeSupported:whiteBalanceMode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) {
			device.whiteBalanceMode = whiteBalanceMode;
			[device unlockForConfiguration];
		} else {
			DLog(@"Setting whiteBalanceMode failed: %@", error.localizedDescription);
		}
	}
}

- (void)setOrientation:(AVCaptureVideoOrientation)orientation
{
	AVCaptureConnection *conn = self.connection;
	
	if ([conn isVideoOrientationSupported]) {
		conn.videoOrientation = orientation;
	}
}

- (void)setDevicePosition:(AVCaptureDevicePosition)devicePosition
{
	//Save new position
	_devicePosition = devicePosition;
	if (!_session) return;
	
	//Get input with given position
	AVCaptureDeviceInput *newInput = [DTCaptureViewUtils deviceInputWithPosition:devicePosition];
	
	//beginConfiguration ensures that pending changes are not applied immediately
	[_session beginConfiguration];
	[_session removeInput:_currentInput];
	[_session addInput:newInput];
	[_session commitConfiguration];
	
	_currentInput = newInput;
	
}

#pragma mark - Getter 
- (AVCaptureDevice *)device
{
	return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (AVCaptureConnection *)connection
{
	return [DTCaptureViewUtils connectionWithMediaType:AVMediaTypeVideo
									   fromConnections:_stillImageOutput.connections];
}

#pragma mark - Public methods
- (void)startCamera
{
	if (_isCameraRunning) return;
	
	//Setup capture session
	[self setupCaptureSession];
	
	//Preview layer
	_previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
	_previewLayer.frame = self.bounds;
	_previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.layer addSublayer:_previewLayer];
	
	_isCameraRunning = true;
}

- (void)stopCamera
{
	if (!_isCameraRunning) return;
	[_session stopRunning];
	[_previewLayer removeFromSuperlayer];
}

- (void)swapCameraPosition
{
	self.devicePosition = (_devicePosition == AVCaptureDevicePositionFront) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

#pragma mark - Capture session methods
- (void)setupCaptureSession
{
	//Create session
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	
	//Create input device
	AVCaptureDeviceInput *input = [DTCaptureViewUtils deviceInputWithPosition:_devicePosition];
	
	if (input) {
		[session addInput:input];
		_currentInput = input;
	} 
	
	//Create & configure output -> StillImage
	AVCaptureStillImageOutput *output = [[AVCaptureStillImageOutput alloc] init];
	output.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
	[session addOutput:output];
	
	
	//Start session
	[session startRunning];
	
	//Setup settings
	AVCaptureDevice *device = self.device;
	if ([device lockForConfiguration:nil]) {
		
		if ([device isFlashModeSupported:_flashMode]) {
			device.flashMode = _flashMode;
		}
		
		if ([device isFocusModeSupported:_focusMode]) {
			device.focusMode = _focusMode;
		}
		
		if ([device isWhiteBalanceModeSupported:_whiteBalanceMode]) {
			device.whiteBalanceMode = _whiteBalanceMode;
		}
		
		[device unlockForConfiguration];
	}
	
	_session = session;
	_stillImageOutput = output;
}


@end
