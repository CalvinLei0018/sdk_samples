//
//  ConferenceViewController.m
//  TeeVidSample
//
//  Copyright © 2016-2019 cloudAYI. All rights reserved.
//

#import "ConferenceViewController.h"
#import "SmartJoinViewController.h"
#import "Utils.h"

@interface ConferenceViewController () <SmartJoinViewControllerDelegate>

@property (strong, nonatomic) SmartJoinViewController *smartJoinView;

@end



@implementation ConferenceViewController {
@private
    UIView *conferenceView;
    TeeVidClient *teeVidClient;
    NSMutableDictionary *videoViews;
    NSMutableDictionary *screenSharingViews;
    BOOL clientManagedLayout;
    BOOL disconnecing;
}
@synthesize serverAddress, roomId;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize TeeVidClient
    // Two modes are available: video layout is managed by client, or by application
    // To use mode when video layout is managed by application, set clientManagedLayout to NO
    clientManagedLayout = YES;
    
    if (clientManagedLayout) {
        // Pass whatever view you want video to be rendered in
        CGRect bounds   = self.view.frame;
        CGRect frame    = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
        conferenceView  = [[UIView alloc] initWithFrame:frame];
        conferenceView.autoresizingMask = self.view.autoresizingMask;
        [self.view addSubview:conferenceView];
        [self.view sendSubviewToBack:conferenceView];
        teeVidClient    = [[TeeVidClient alloc] initWithView:conferenceView server:serverAddress room:roomId userName:@"TeeVidSample iOS" options:nil andDelegate:self];
    }
    else {
        // Create client without passing view, instead get and manage individual participant video views directly
        teeVidClient    = [[TeeVidClient alloc] initWithView:nil server:serverAddress room:roomId userName:@"TeeVidSample iOS" options:nil andDelegate:self];
        videoViews      = [[NSMutableDictionary alloc] init];
        screenSharingViews = [[NSMutableDictionary alloc] init];
    }
        
}

#pragma mark - TeeVidClientDelegate
- (void)client:(TeeVidClient *)client didRequestAccessPIN:(NSString *)roomId {
    // Prompt for access PIN
}

- (void)client:(TeeVidClient *)client didEnterWaitingRoom:(NSString *)roomId {
    // Prompt for owner PIN to unlock waiting room, or wait until owner joins
}

- (void)client:(TeeVidClient *)client didLeaveWaitingRoom:(NSString *)roomId {
    // Dismiss prompt for owner PIN if still shown
}

- (void)client:(TeeVidClient *)client didConnect:(NSString *)roomId {
    // Client has connected to the conference room
    // Perform any appropriate actions - enable controls, etc.
    
    self.disconnectButton.hidden = NO;
    // prevent screen from dimming while in a call
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [self closeSmartJoinViewWithAnimation:YES];
}

- (void)client:(TeeVidClient *)client didDisconnect:(NSString *)roomId reason:(NSString *)reason {
    // Client has disconnected from the conference room
    // Note that this can be result of disconnect segue, or disconnect on remote end
    // If disconnected remotely, need to perform disconnect seque to return to entry screen
    if (!disconnecing) {
        [self quitMeeting];
    }
}

- (void)client:(TeeVidClient *)client showSmartJoinWithPublisherCount:(NSInteger)publisherCount {
    [self showSmartJoinWithPublisherCount:publisherCount];
}

- (void)client:(TeeVidClient *)client showPreEventScreenWithParams:(NSDictionary *)params credentialRequirements:(NSArray<NSString *> *)credentialRequirements {
    
}

- (void)client:(TeeVidClient *)client didUpdateEventStateWithParams:(NSDictionary *)params {
    
}

- (void)clientEventPersonVerificationPassed:(TeeVidClient *)client {
    
}

- (void)client:(TeeVidClient *)client didUpdatePollWithParams:(NSDictionary *)params {
    
}

- (void)client:(TeeVidClient *)client didReceiveError:(NSString *)error {
    [Utils showMessage:error withTitle:@"Error" handler:^(UIAlertAction *action) {
        [self quitMeeting];
    }];
}

- (void)client:(TeeVidClient *)client didRequestLayoutRefresh:(NSString *)reason {
    // Conference view layout changed - instruct client to show new layout
    // Note that client will request layout refresh only if video layout is managed by client
    // Add any animatiom you want while refreshind layout
    [UIView transitionWithView:conferenceView duration:0.3 options:(UIViewAnimationOptionLayoutSubviews) animations:^{
        [client refreshLayout];
    } completion:nil];
}

- (void)client:(TeeVidClient *)client didEnterLectureMode:(NSString *)roomId {
    // Any action specific to lecture mode, e.g. disable microphone
    // Note that client will mute local audio and change layout to lecturer video automatically
}

- (void)client:(TeeVidClient *)client didLeaveLectureMode:(NSString *)roomId {
    // Restore to non-lecture mode
    // Note that client will unmute local audio and change layout to automatic
}

- (void)client:(TeeVidClient *)client didEnterWaitingForLecturer:(NSString *)roomId {
    // Wait for lecturer
    // Note that no video will be shown until lecturer arrives
}

- (void)client:(TeeVidClient *)client didReceiveLecturerDisconnectEvent:(NSString *)roomId {
    // Lecturer has disconnected. Perform whatever action is appropriate or ask user what to do
}

- (void)client:(TeeVidClient *)client didRecieveUnmuteRequest:(NSDictionary*)request completionHandler:(void (^)(BOOL allowUnmute))completionHandler {
    // completionHandler should called when a user make a choice about approving or discard the request. allowUnmute is a BOOL value that represent a user's answer
    completionHandler(YES);
}

- (void)client:(TeeVidClient *)client didAddParticipants:(NSDictionary *)participants {
    if (!clientManagedLayout) {
        for (NSString *participantId in participants) {
            NSDictionary *attributes = participants[participantId];
            [self addViewForParticipant:participantId withAttributes:attributes];
        }
    }
}

- (void)client:(TeeVidClient *)client didUpdateParticipant:(NSString *)participantId withAttributes:(NSDictionary *)attributes {
    // Participant has been updated
    // Application can use this call to update participant list
    // If video layout is managed by application, application is also responsible to manage view for each participant
    if (!clientManagedLayout) {
        [self addViewForParticipant:participantId withAttributes:attributes];
    }
}

- (void)client:(TeeVidClient *)client didRemoveParticipant:(NSString *)participantId {
    // Participant has been removed
    // Application can use this call to update participant list
    // If video layout is managed by application, application is also responsible to manage view for each participant
    if (!clientManagedLayout) {
        [self removeView:nil forParticipant:participantId];
    }
}

- (void)client:(TeeVidClient *)client didChangeVideoSize:(CGSize)videoSize forParticipant:(NSString *)participantId {
    // Note that client will notify about video size change only if video layout is managed by application
    // Application must use this event to set correct aspect ratio of rendered video by adjusting view size, and,
    // hiding/masking part of the view or using any other appropriate technique
}

- (void)client:(TeeVidClient *)client didRemoveVideoView:(UIView *)view forParticipant:(NSString *)participantId {
    // Note that client will notify about video view removed only if video layout is managed by application
    // Application should use this call to remove view from video layout
    [self removeView:view forParticipant:participantId];
}


#pragma mark - Navigation
- (IBAction)disconnectButtonTapped:(id)sender {
    [self quitMeeting];
}


- (void)quitMeeting {
    if (self.roomDelegate && [self.roomDelegate respondsToSelector:@selector(didExitRoom:)]) {
        disconnecing = YES;
        [teeVidClient disconnect];
        
        // Restore application idle timer
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        
        [self.roomDelegate didExitRoom:self];
    }
}



#pragma mark - Private
- (void)addViewForParticipant:(NSString *)participantId withAttributes:(NSDictionary *)attributes {
    BOOL refresh = NO;
    
    id videoAttribute = attributes[TEEVID_ATTRIBUTE_VIDEO];
    if (videoAttribute && [videoAttribute boolValue]) {
        // Is there already video view for this participant?
        if (!videoViews[participantId]) {
            // No cached video view, check if participant added video stream
            UIView *videoView = [teeVidClient getViewForParticipant:participantId video:YES];
            // Participant might not have video stream yet
            if (videoView) {
                videoViews[participantId] = videoView;
                [self.view addSubview:videoView];
                refresh = YES;
            }
        }
    }
    
    id screenSharingAttribute = attributes[TEEVID_ATTRIBUTE_SCREEN_SHARING];
    if (screenSharingAttribute && [screenSharingAttribute boolValue]) {
        if (!screenSharingViews[participantId]) {
            // No cached video view, check if participant added screen sharing stream
            UIView *screenSharingView = [teeVidClient getViewForParticipant:participantId video:NO];
            // Participant might not have video stream yet
            if (screenSharingView) {
                screenSharingViews[participantId] = screenSharingView;
                [self.view addSubview:screenSharingView];
                refresh = YES;
            }
        }
    }
    
    if (refresh) {
        [UIView transitionWithView:conferenceView duration:0.3 options:(UIViewAnimationOptionLayoutSubviews) animations:^{
            [self refreshLayout];
        } completion:nil];
    }
}


- (void)removeView:(UIView *)view forParticipant:(NSString *)participantId {
    BOOL refresh = NO;
    
    UIView *videoView = videoViews[participantId];
    if (videoView) {
        // if specific view passed to this method, check for match
        if (!view || [videoView isEqual:view]) {
            [videoViews removeObjectForKey:participantId];
            [videoView removeFromSuperview];
            refresh = YES;
        }
    }
    
    UIView *screenSharingView = screenSharingViews[participantId];
    if (screenSharingView) {
        // if specific view passed to this method, check for match
        if (!view || [screenSharingView isEqual:view]) {
            [screenSharingViews removeObjectForKey:participantId];
            [screenSharingView removeFromSuperview];
            refresh = YES;
        }
    }
    
    if (refresh) {
        [UIView transitionWithView:conferenceView duration:0.3 options:(UIViewAnimationOptionLayoutSubviews) animations:^{
            [self refreshLayout];
        } completion:nil];
    }
}


// only used when video layout is managed by application
// otherwise, [client refreshLayout] must be used
- (void)refreshLayout {
    // for demo purposes, just split screen in 4 quadrants and put up to 4 videos there
    // note that code below does not deal with aspect ratio! It must be dealt with in didChangeVideoSize event
    CGRect windowRect = self.view.window.frame;
    CGFloat singleViewWidth = windowRect.size.width / 2;
    CGFloat singleViewHeight = (windowRect.size.height - 80) / 2;
    
    NSArray *keys = [videoViews allKeys];
    unsigned long count = keys.count;
    // if there is screen sharing, use bottom two quandrants for it
    UIView *screenSharingView = screenSharingViews.count > 0 ? screenSharingViews[[screenSharingViews allKeys][0]] : nil;
    if (screenSharingView) {
        unsigned long start = count > 2 ? count - 2 : 0;
        for (unsigned long i = 0; i < count; ++i) {
            UIView *videoView = videoViews[keys[i]];
            if (i < start) {
                videoView.hidden = YES;
            } else {
                videoView.bounds = CGRectMake(0, 0, singleViewWidth, singleViewHeight);
                switch(i - start) {
                    case 0:
                        videoView.frame = CGRectMake(0, 40, singleViewWidth, singleViewHeight);
                        break;
                    case 1:
                        videoView.frame = CGRectMake(singleViewWidth, 40, singleViewWidth, singleViewHeight);
                        break;
                }
                videoView.hidden = NO;
                [self.view bringSubviewToFront:videoView];
            }
        }
        screenSharingView.bounds = CGRectMake(0, 0, singleViewWidth * 2, singleViewHeight);
        screenSharingView.frame = CGRectMake(0, singleViewHeight + 40, singleViewWidth * 2, singleViewHeight);
        screenSharingView.hidden = NO;
        [self.view bringSubviewToFront:screenSharingView];
    }
    else {
        unsigned long start = count > 4 ? count - 4 : 0;
        for (unsigned long i = 0; i < count; ++i) {
            UIView *videoView = videoViews[keys[i]];
            if (i < start) {
                videoView.hidden = YES;
            } else {
                videoView.bounds = CGRectMake(0, 0, singleViewWidth, singleViewHeight);
                switch(i - start) {
                    case 0:
                        videoView.frame = CGRectMake(0, 40, singleViewWidth, singleViewHeight);
                        break;
                    case 1:
                        videoView.frame = CGRectMake(singleViewWidth, 40, singleViewWidth, singleViewHeight);
                        break;
                    case 2:
                        videoView.frame = CGRectMake(0, singleViewHeight + 40, singleViewWidth, singleViewHeight);
                        break;
                    case 3:
                        videoView.frame = CGRectMake(singleViewWidth, singleViewHeight + 40, singleViewWidth, singleViewHeight);
                        break;
                }
                videoView.hidden = NO;
                [self.view bringSubviewToFront:videoView];
            }
        }
    }
}

#pragma mark - SmartJoinScreen, SmartJoinViewControllerDelegate
- (void)showSmartJoinWithPublisherCount:(NSInteger)countOfPublisers {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.disconnectButton.hidden = YES;
        UIStoryboard *storyboard    = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.smartJoinView          = [storyboard instantiateViewControllerWithIdentifier:@"smartjoinView"];
        self.smartJoinView.delegate = self;
        self.smartJoinView.view.backgroundColor = [UIColor clearColor];
        [self.smartJoinView setRoomName:self.roomId];
                
        [self->teeVidClient connectToSmartJoinScreenAs:@"TeeVid sample iOS"];
        [self addChildViewController:self.smartJoinView];
        [self.view addSubview:self.smartJoinView.view];
        [self.smartJoinView didMoveToParentViewController:self];
        
    });
}

- (void)refreshSmartJoinMicLevel:(float)inputLevel {
    [self.smartJoinView updateMicLevelIndicator:inputLevel];
}


- (void)closeSmartJoinViewWithAnimation:(BOOL)withAnimation {
    [self.smartJoinView willMoveToParentViewController:self];
    [self.smartJoinView.view removeFromSuperview];
    [self.smartJoinView removeFromParentViewController];
    
    self.smartJoinView.delegate = nil;
    self.smartJoinView          = nil;
}

- (void)smartJoinScreen:(SmartJoinViewController *)smartJoinScreen deviceRotationRefreshRequested:(id)sender {
    //[self.client refreshLayout];
}


- (void)smartJoinScreen:(SmartJoinViewController *)smartJoinScreen userImageRefreshRequested:(id)sender {
    [teeVidClient userImageUpdateRequested];
}


- (void)smartJoinScreen:(SmartJoinViewController *)smartJoinScreen closeButtonTapped:(id)sender {
    [self closeSmartJoinViewWithAnimation:NO];
    [self quitMeeting];
}

- (void)smartJoinScreen:(SmartJoinViewController *)smartJoinScreen closeAndDisconnect:(id)sender {
    [self closeSmartJoinViewWithAnimation:NO];
    [self quitMeeting];
}


- (void)smartJoinScreen:(SmartJoinViewController *)smartJoinScreen joinButtonTapped:(id)sender {
    [teeVidClient connectToServer:serverAddress room:roomId asUser:@"TeeVidSample iOS" meetingType:MeetingTypeRegularRoom withAccessPin:nil];
}


- (void)smartJoinScreen:(SmartJoinViewController *)smartJoinScreen switchCamButtonTapped:(id)sender {
    [teeVidClient smartJoinSwitchCamera];
}


- (void)smartJoinScreen:(SmartJoinViewController *)smartJoinScreen camButtonTapped:(id)sender {
    if (teeVidClient.videoStopped) { // resume video
        [teeVidClient smartJoinResumeVideo];
        [self.smartJoinView unmuteCamera];
    }
    else { // stop video
        [teeVidClient smartJoinStopVideo];
        [self.smartJoinView muteCamera];
    }
}


- (void)smartJoinScreen:(SmartJoinViewController *)smartJoinScreen micButtonTapped:(id)sender {
    if (teeVidClient.muted) { // unmute audio
        [teeVidClient smartJoinUnmuteMic];
        [self.smartJoinView unmuteMicrophone];
    }
    else { // mute audio
        [teeVidClient smartJoinMuteMic];
        [self.smartJoinView muteMicrophone];
    }
}


- (void)smartJoinScreen:(SmartJoinViewController *)smartJoinScreen connectWithPin:(NSString *)pin {
    
}

@end
