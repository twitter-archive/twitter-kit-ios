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

#import "TWTRSETweetShareViewController.h"
#import "TWTRSEAccount.h"
#import "TWTRSESheetPresentationController.h"
#import "TWTRSETweetComposerViewController.h"
#import "TWTRSETweetShareConfiguration.h"
#import "TWTRSETweetShareNavigationController.h"

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
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    _navigationController.view.frame = self.view.bounds;
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    if (container == self.navigationController) {
        self.preferredContentSize = self.navigationController.preferredContentSize;
    }
}

@end
