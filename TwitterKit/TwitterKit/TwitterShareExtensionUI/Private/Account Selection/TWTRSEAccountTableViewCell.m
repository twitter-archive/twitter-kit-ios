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

#import "TWTRSEAccountTableViewCell.h"
#import "TWTRImages.h"
#import "TWTRSEAccount.h"
#import "TWTRSEColors.h"
#import "TWTRSEFonts.h"
#import "TWTRSEImageDownloader.h"
#import "TWTRSENetworking.h"
#import "TWTRSETwitterUser.h"
#import "TWTRSEUIBundle.h"
#import "UIView+TSEExtensions.h"

static const CGFloat kAvatarImageViewSideLength = 40.0;
static const CGFloat kUsernameLeadingPadding = 8.0;
static const CGFloat kCircleCornerRadiusDivisor = 2.0;
static const CGFloat kContentLayoutMarginPaddingAdjustment = 3.0;
static const CGFloat kNameLabelsContainerLayoutVerticalCompressionPriority = UILayoutPriorityRequired - 3;
static const CGFloat kNameLabelsFontPointSizeMultiplier = (CGFloat)1.25;

@interface TWTRSEAccountTableViewCellAvatarImageView : UIImageView
@end

@implementation TWTRSEAccountTableViewCellAvatarImageView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.height / kCircleCornerRadiusDivisor;
}

@end

@interface TWTRSEAccountTableViewCell ()

@property (nonatomic, readonly) TWTRSEAccountTableViewCellAvatarImageView *avatarImageView;
@property (nonatomic, readonly) UILabel *fullNameLabel;
@property (nonatomic, readonly) UILabel *usernameLabel;

@property (nonatomic, readonly) UIView *nameLabelsContainer;

@property (nonatomic, nullable) id<TWTRSEImageDownloader> imageDownloader;
@property (nonatomic, nullable) id lastImageDownloadToken;

@property (nonatomic, nullable) id lastProvidedAccountOrUser;

@end

@implementation TWTRSEAccountTableViewCell

- (instancetype)init
{
    if ((self = [super init])) {
        _nameLabelsContainer = [[UIView alloc] init];

        _avatarImageView = [[TWTRSEAccountTableViewCellAvatarImageView alloc] initWithFrame:CGRectZero];
        _fullNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        if (@available(iOS 11.0, *)) {
            _avatarImageView.accessibilityIgnoresInvertColors = YES;
        }
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.backgroundColor = TWTRSEUITwitterColorImagePlaceholder();
        _avatarImageView.layer.masksToBounds = YES;

        _usernameLabel.numberOfLines = 0;

        _fullNameLabel.font = [TWTRSEFonts userFullNameFont];
        _usernameLabel.font = [TWTRSEFonts userUsernameFont];

        _fullNameLabel.textColor = [TWTRSEFonts userFullNameColor];
        _usernameLabel.textColor = [TWTRSEFonts userUsernameColor];

        [self.contentView addSubview:_avatarImageView];
        [self.nameLabelsContainer addSubview:_fullNameLabel];
        [self.nameLabelsContainer addSubview:_usernameLabel];
        [self.contentView addSubview:self.nameLabelsContainer];

        [self setUpConstraints];
    }

    return self;
}

- (void)setUpConstraints
{
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabelsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.fullNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.nameLabelsContainer setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.nameLabelsContainer setContentCompressionResistancePriority:kNameLabelsContainerLayoutVerticalCompressionPriority forAxis:UILayoutConstraintAxisVertical];

    [self.nameLabelsContainer setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.nameLabelsContainer setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    UIEdgeInsets newMargins = self.contentView.layoutMargins;
    newMargins.top -= kContentLayoutMarginPaddingAdjustment;
    newMargins.bottom -= kContentLayoutMarginPaddingAdjustment;
    self.contentView.layoutMargins = newMargins;
    UILayoutGuide *contentMarginsGuide = self.contentView.layoutMarginsGuide;

    [self.avatarImageView.leadingAnchor constraintEqualToAnchor:contentMarginsGuide.leadingAnchor].active = YES;
    [self.avatarImageView.widthAnchor constraintEqualToConstant:kAvatarImageViewSideLength].active = YES;
    [self.avatarImageView.heightAnchor constraintEqualToConstant:kAvatarImageViewSideLength].active = YES;
    [self.avatarImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.avatarImageView.topAnchor constraintGreaterThanOrEqualToAnchor:contentMarginsGuide.topAnchor].active = YES;

    [self.nameLabelsContainer.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.nameLabelsContainer.leadingAnchor constraintEqualToAnchor:self.avatarImageView.trailingAnchor constant:kUsernameLeadingPadding].active = YES;
    [self.nameLabelsContainer.trailingAnchor constraintEqualToAnchor:contentMarginsGuide.trailingAnchor].active = YES;
    [self.nameLabelsContainer.topAnchor constraintLessThanOrEqualToAnchor:contentMarginsGuide.topAnchor].active = YES;
    [self.nameLabelsContainer.bottomAnchor constraintGreaterThanOrEqualToAnchor:contentMarginsGuide.bottomAnchor].active = YES;
    [self.nameLabelsContainer.heightAnchor constraintGreaterThanOrEqualToConstant:(_fullNameLabel.font.pointSize + _usernameLabel.font.pointSize) * kNameLabelsFontPointSizeMultiplier].active = YES;

    tse_requireContentCompressionResistanceAndHuggingPriority(self.fullNameLabel);
    tse_requireContentCompressionResistanceAndHuggingPriority(self.usernameLabel);

    [self.fullNameLabel.leadingAnchor constraintEqualToAnchor:self.nameLabelsContainer.leadingAnchor].active = YES;
    [self.fullNameLabel.trailingAnchor constraintEqualToAnchor:self.nameLabelsContainer.trailingAnchor].active = YES;
    [self.fullNameLabel.topAnchor constraintEqualToAnchor:self.nameLabelsContainer.topAnchor].active = YES;
    [self.fullNameLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.nameLabelsContainer.centerYAnchor].active = YES;

    [self.usernameLabel.leadingAnchor constraintEqualToAnchor:self.fullNameLabel.leadingAnchor].active = YES;
    [self.usernameLabel.trailingAnchor constraintEqualToAnchor:self.nameLabelsContainer.trailingAnchor].active = YES;
    [self.usernameLabel.topAnchor constraintEqualToAnchor:self.fullNameLabel.bottomAnchor].active = YES;
    [self.usernameLabel.topAnchor constraintLessThanOrEqualToAnchor:self.nameLabelsContainer.centerYAnchor].active = YES;
    [self.usernameLabel.bottomAnchor constraintEqualToAnchor:self.nameLabelsContainer.bottomAnchor].active = YES;
    [self.usernameLabel.heightAnchor constraintLessThanOrEqualToAnchor:self.fullNameLabel.heightAnchor].active = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.fullNameLabel.text = nil;
    self.usernameLabel.text = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.lastProvidedAccountOrUser = nil;
    self.avatarImageView.image = nil;

    [self cancelLastDownload];
}

- (void)cancelLastDownload
{
    if (self.lastImageDownloadToken) {
        [self.imageDownloader cancelImageDownloadWithToken:self.lastImageDownloadToken];

        self.lastImageDownloadToken = nil;
    }
}

#pragma mark - Public

- (void)configureWithHydratedUser:(id<TWTRSETwitterUser>)user isSelected:(BOOL)isSelected imageDownloader:(id<TWTRSEImageDownloader>)imageDownloader
{
    NSParameterAssert(user);
    NSParameterAssert(imageDownloader);

    self.lastProvidedAccountOrUser = user;

    self.fullNameLabel.text = user.fullName;
    self.usernameLabel.text = TWTRSEAccountDisplayUsername(user);
    if (isSelected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
        self.accessoryView = nil;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.accessoryView = (user.verified) ? [[UIImageView alloc] initWithImage:[TWTRImages verifiedIcon]] : nil;
    }
    self.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    [self cancelLastDownload];

    self.imageDownloader = imageDownloader;

    __weak typeof(self) weakSelf = self;
    self.lastImageDownloadToken = [imageDownloader downloadImageFromURL:user.avatarURL
                                                             completion:^(UIImage *_Nullable image, NSError *_Nullable error) {
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     typeof(self) strongSelf = weakSelf;

                                                                     if (!strongSelf) {
                                                                         return;
                                                                     }

                                                                     // Prevent race-condition with cell reuse
                                                                     if (strongSelf.lastProvidedAccountOrUser != user) {
                                                                         return;
                                                                     }

                                                                     strongSelf.avatarImageView.image = image;
                                                                 });
                                                             }];
}

- (void)configureWithAccount:(id<TWTRSEAccount>)account isSelected:(BOOL)isSelected imageDownloader:(id<TWTRSEImageDownloader>)imageDownloader networking:(id<TWTRSENetworking>)networking
{
    NSParameterAssert(account);
    NSParameterAssert(imageDownloader);
    NSParameterAssert(networking);

    self.lastProvidedAccountOrUser = account;

    self.fullNameLabel.text = nil;
    self.usernameLabel.text = TWTRSEAccountDisplayUsername(account);
    self.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    __weak typeof(self) weakSelf = self;
    [networking loadHydratedTwitterUserForAccount:account
                                       completion:^(id<TWTRSETwitterUser> _Nullable hydratedUser) {
                                           typeof(self) strongSelf = weakSelf;
                                           if (!strongSelf) {
                                               return;
                                           }

                                           if (!hydratedUser) {
                                               return;
                                           }

                                           // Prevent race-condition with cell reuse
                                           if (strongSelf.lastProvidedAccountOrUser != account) {
                                               return;
                                           }

                                           [strongSelf configureWithHydratedUser:hydratedUser isSelected:isSelected imageDownloader:imageDownloader];
                                       }];
}

@end
