/*
 * Copyright (C) 2017 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "TWTRSEAccount.h"
#import "TWTRSEScribe.h"
#import "TWTRSESheetPresentationController.h"
#import "TWTRSETweetComposerViewController.h"
#import "TWTRSETweetShareConfiguration.h"
#import "TWTRSETweetShareNavigationController.h"
#import "TWTRSETweetShareViewController.h"
#import "TWTRSEUIScribeEvent+Private.h"

@interface TWTRSETweetShareViewController ()

@property (nonatomic, readonly) TWTRSETweetShareConfiguration *configuration;
@property (nonatomic, readonly) TWTRSETweetShareNavigationController *navigationController;
@property (nonatomic, readonly) TWTRSETweetComposerViewController *composerViewController;

@property (nonatomic, readonly) TWTRSESheetPresentationManager *sheetPresentationManager;

@end

@implementation TWTRSETweetShareViewController

- (instancetype)initWithConfiguration:(TWTRSETweetShareConfiguration *)configuration
{
    NSParameterAssert(configuration);

    if ((self = [super initWithNibName:nil bundle:nil])) {
        _configuration = configuration;

        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalPresentationCapturesStatusBarAppearance = YES;

        _sheetPresentationManager = [[TWTRSESheetPresentationManager alloc] init];
        self.transitioningDelegate = _sheetPresentationManager;
    }

    return self;
}

- (void)_tseui_scribeAction:(NSString *)action
{
    id<TWTRSEScribe> scribe = _configuration.scribe;
    id<TWTRSEAccount> account = _configuration.initiallySelectedAccount;
    if (scribe && account) {
        [scribe scribeEvent:[[TWTRSEUIScribeEvent alloc] initWithUser:@(account.userID)
                                                           element:@""
                                                            action:action]];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _composerViewController = [[TWTRSETweetComposerViewController alloc] initWithConfiguration:_configuration];
    _navigationController = [[TWTRSETweetShareNavigationController alloc] initWithRootViewController:_composerViewController];

    // This controller acts as a façade to hide the navigation controller.
    // Embed as a child:
    [self addChildViewController:_navigationController];
    [self.view addSubview:_navigationController.view];
    [_navigationController didMoveToParentViewController:self];
    [self _tseui_scribeAction:@"load"];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    _navigationController.view.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _tseui_scribeAction:@"impression"];
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    if (container == self.navigationController) {
        self.preferredContentSize = self.navigationController.preferredContentSize;
    }
}

@end
