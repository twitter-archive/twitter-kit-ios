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

#import "TSEAccount.h"
#import "TSEScribe.h"
#import "TSESheetPresentationController.h"
#import "TSETweetComposerViewController.h"
#import "TSETweetShareConfiguration.h"
#import "TSETweetShareNavigationController.h"
#import "TSETweetShareViewController.h"
#import "TSEUIScribeEvent+Private.h"

@interface TSETweetShareViewController ()

@property (nonatomic, readonly) TSETweetShareConfiguration *configuration;

@property (nonatomic, readonly) TSETweetShareNavigationController *navigationController;
@property (nonatomic, readonly) TSETweetComposerViewController *composerViewController;

@property (nonatomic, readonly) TSESheetPresentationManager *sheetPresentationManager;

@end

@implementation TSETweetShareViewController

- (instancetype)initWithConfiguration:(TSETweetShareConfiguration *)configuration
{
    NSParameterAssert(configuration);

    if ((self = [super initWithNibName:nil bundle:nil])) {
        _configuration = configuration;

        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalPresentationCapturesStatusBarAppearance = YES;

        _sheetPresentationManager = [[TSESheetPresentationManager alloc] init];
        self.transitioningDelegate = _sheetPresentationManager;
    }

    return self;
}

- (void)_tseui_scribeAction:(NSString *)action
{
    id<TSEScribe> scribe = _configuration.scribe;
    id<TSEAccount> account = _configuration.initiallySelectedAccount;
    if (scribe && account) {
        [scribe scribeEvent:[[TSEUIScribeEvent alloc] initWithUser:@(account.userID)
                                                           element:@""
                                                            action:action]];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _composerViewController = [[TSETweetComposerViewController alloc] initWithConfiguration:_configuration];
    _navigationController = [[TSETweetShareNavigationController alloc] initWithRootViewController:_composerViewController];

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
