//
//  IdentifierConstant.swift
//  WhosNext
//
//  Created by Pooja Gandhi on 12/07/22.
//

import Foundation

struct IdentifiableKeys {
    //MARK: - Navigationbar Titles
    struct NavigationbarTitles {
        static let kPrivacypolicy                               = "Privacy Policy"
        static let kTermsandCondition                           = "Terms & Condition"
        static let kEditProfile                                 = "Edit Profile"
        static let kMyProfile                                   = "My Profile"
        static let kCity                                        = "City"
        static let kCategory                                    = "Category"
        static let kFeaturedProfiles                            = "Featured Profiles"
        static let kComments                                    = "Comments"
        static let kAddNewSnippets                              = "Add New Snippets"
        static let kAddRequestSnippets                          = "Add Request Snippets"
        static let kSnippetUploadAccessRequest                  = "Snippet Upload Access Request"
        static let kRecordAudio                                 = "Record Audio"
        static let kNotification                                = "Notification"
        static let kFollowers                                   = "Followers"
        static let kFollowing                                   = "Following"
        static let kPosts                                       = "Posts"
        static let kVideos                                      = "Videos"
        static let kSendTo                                      = "Send To"
        static let kBreastCancerLegacies                        = "Breast Cancer Legacies"
        static let kDiscoverPeople                              = "Discover People"
        static let kMessages                                    = "Messages"
        static let kAddNew                                      = "Add New"
        static let kShareTo                                     = "Share To"
        static let kPost                                        = "Post"
        static let kSendPushNotification                        = "Send Push Notification"
        static let kSnippets                                    = "Snippets"
        static let kFollowRequest                               = "Follow Request"
    }
    
    // MARK: - AlertMessages
    struct AlertMessages {
        static let kLogout                                      = "Are you sure you want to logout?"
        static let kDeleteAccount                               = "Are you sure you want to delete your account?"
        static let kDeleteImage                                 = "Are you sure you want to delete this image?"
        static let kDeactivateAccount                           = "Are you sure you want to deactivate your profile?"
    }
    
    // MARK: - Alert Titles
    struct AlertTitles {
        static let Logout                                       = "Logout"
    }
    
    // MARK: - Action Sheet Key
    struct ActionSheetKey {
        static let kChoose_an_option                            = "Choose an option"
        static let kTake_Photo                                  = "Take Photo"
        static let kChoose_Photo                                = "Choose Photo"
        static let kCancel                                      = "Cancel"
    }
    
    // MARK: - Validation Messages
    struct ValidationMessages {
        /// `login`
        static let kEmptyProfileImage                           = "Please select profile image."
        static let kEmptyUserName                               = "Please enter your user."
        static let kEmptyPassword                               = "Please enter your password."
        static let kInvalidEmail                                = "Please enter your valid email ID."
        
        /// `registration`
        static let kEmptyFirstName                              = "Please enter your first name."
        static let kEmptyLastName                               = "Please enter your last name."
        static let kEmptyEmail                                  = "Please enter your email."
        static let kEmptyUser                                   = "Please select user type."
        static let kEmptyUsername                               = "Please enter your username"
        static let kInvalidPhone                                = "Please enter valid work phone number."
        static let kConfirmedEmailID                            = "Please enter your confirmed email ID."
        static let kDoesNotMatchEmailID                         = "Your confirmed email ID does not match to email ID."
        static let kDoesNotMatchConfirmPassword                 = "Your confirmed passsword does not match to password."
        static let kPasswordMaximumCharcter                     = "Password should be maximum 6 Characters."
        static let kSelectTalentError                           = "Please select at least one talent of you"
        static let kIntroductionVideoError                      = "Please attach your introduction video"
        static let kEmptyConfiremPassword                       = "Please enter your confirmed password."
        static let kEmptyCategories                             = "Please select at least one talent of you"
        static let kEmptyIntroductionVideo                      = "Please attach your introduction video"
        static let kEmptyTermsAndCondition                      = "Please accept our terms & condition and privacy policy"
        
        /// `change password`
        static let kCurrentPassword                             = "Please enter your old password"
        static let kNewPassword                                 = "Please enter your new password"
        static let kConfirmPassword                             = "Please retype your new password"
        static let kDoesNotMatchNewPassword                     = "New password and retype password don't match"
       
        /// `otp`
        static let kOtpVerify                                   = "Please enter your otp code"
        static let kValidOtp                                    = "Please enter valid otp"

        /// `profile`
        static let kEmptyCity                                   = "Please select your city."
        static let kEmptyCategory                               = "Please select your talent or business category."
        static let kEmptyAboutYourSelf                          = "Please enter something about yourself."
    }
    
    //MARK: - API Failure messages
    struct FailureMessage {
        static let kNoInternetConnection                        = "Please check your internet connection"
        static let kCommanErrorMessage                          = "Something went wrong. please try again later"
        static let kDataNotFound                                = "No Result Found"
    }
    
    //MARK: - Label
    struct Labels {
        //Login
        static let kUsername                                    = "Username"
        static let kPassword                                    = "Password"
        static let kPrivacyPolicy                               = "Privacy Policy"
        static let kTermsandCondition                           = "Terms & Condition"
        static let kVerifyOtp                                   = "Please enter your otp "
        
        //Register
        static let kFirstName                                   = "First Name"
        static let kLastName                                    = "Last Name"
        static let kEmail                                       = "Email"
        static let kConfirmEmail                                = "Confirm Email"
        static let kConfirmPassword                             = "Confirm Password"
        static let kAddIntroductionVideo                        = "Add Introduction Video (Max 30 Sec.)"
        static let kIAccept                                     = " I Accept "
        static let kCurrentPassword                             = "current password"
        static let kNewPassword                                 = "new password"
        static let kRetypeNewPassword                           = "retype new password"
        
        //Profile
        static let kUserName                                    = "Username"
        static let kCity                                        = "City"
        static let kWebsite                                     = "Website"
        static let kCategory                                    = "Category"
        static let kAboutSelf                                   = "About Self"
        static let kIntroductionBioVideo                        = "Introduction Bio Video"
        static let kWebsite1                                    = "website-1"
        static let kWebsite2                                    = "website-2"
        static let kWebsite3                                    = "website-3"
        static let kWebsite4                                    = "website-4"
        static let kWebsite5                                    = "website-5"
        static let kDescribeyourself                            = "Describe yourself in 1 word"
        static let kSubscriptionDetails                         = "Subscription Details"
        static let kMakethisprofileprivate                      = "Make this profile private"
        static let kWhenyourprofileisprivate                    = "When your profile is private.Only pepole you approve can see your photos and videos.Your exsiting followers won't be affected"
        static let kGroupVideo                                  = "Group Video"
        static let kFeedVideo                                   = "Feed Video"
        static let kPleaseTapIconToSelect                       = "Please tap icon to select image, video or audio"
        static let kWriteSnippetDetails                         = "WRITE SNIPPET DETAILS"
        
        //BCL View
        static let kAddPicture                                  = "Add Picture"
        static let kAddName                                     = "Add Name"
        static let kAddDescription                              = "Add Description"
        static let kAddCarnationduringupload                    = "Add Carnation during upload."
        static let kDateofBirth                                 = "Date of Birth"
        static let kDateofPassing                               = "Date of Passing"
        static let kWhileCarnationsloveandgoodluckfightingcancer  = "While Carnations -love and good luck fighting cancer"
        static let kPinkandWhiteCarnationsmeansyouhavebeatcancer  = "Pink and White Carnations - means you have beat cancer"
        static let kStrippedCarnationssomeonepassedawayformcancer = "Stripped Carnations - someone passed away form cancer"
        
        
    }
    
    //MARK: - Button
    struct Buttons {
        
        static let kGetStarted                                  = "Get Started"
        static let kLogin                                       = "LOGIN"
        static let kForgotPassword                              = "Forgot Your Password?"
        static let kCreateAccount                               = "Create Your Account?"
        static let kSelectyourtalentorbusinessplease            = "Select your talent or business please"
        static let kRegister                                    = "REGISTER"
        static let kSubmit                                      = "SUBMIT"
        static let kResetPassword                               = "RESET PASSWORD"
        static let kDone                                        = "DONE"
        static let kCancel                                      = "CANCEL"
        static let kUpdate                                      = "UPDATE"
        static let kSave                                        = "SAVE"
        static let kVerifyOtp                                   = "VERIFY OTP"
        // Profile
        static let kReplaceVideo                                = "Replace Video"
        static let kSelectVideo                                 = "Select Video"
        static let kEditProfile                                 = "Edit Profile"
        static let kDeactiveAccount                             = "Deactive Account"
        static let kFollowers                                   = "Followers"
        static let kFollowing                                   = "Following"
        static let kPosts                                       = "Posts"
        static let kUnfollow                                    = "Unfollow"
        static let kShare                                       = "SHARE"
        static let kSend                                        = "SEND"
        static let kRequest                                     = "Request"
        static let kRequested                                   = "Requested"
        static let kcancel                                      = "Cancel"
        //Alert Buttom
        static let kNo                                          = "No"
        static let kYes                                         = "Yes"
    }
    
    //MARK: - Assets Image name
    struct ImageName {
        
        static let kAvatar                                      = "Avatar"
        static let kCheked                                      = "checked"
        static let kUnchecked                                   = "unchecked"
        static let kUncheckedWhite                           = "unchecked_white"
        static let kVideoupload                                 = "videoupload"
        static let kDropdown                                    = "dropdown"
        static let kCancel                                      = "cancel"
        static let kAppTitleText                                = "apptitletext"
        static let kSearch                                      = "searchwhite"
        static let kMenuBar                                     = "BlackMenuBar"
        static let kNotification                                = "blackBell"
        static let kRibbonSelected                              = "ribbonselected"
        static let kBlackSearch                                 = "searchblack"
        static let kBlackRefresh                                = "BlackRefresh"
        static let kAppBanner                                   = "appBanner"
        static let kQuestionMark                                = "questionMark"
        
        static let kNature                                      = "nature"
        static let kMikegray                                    = "mikegray"
        static let kSharegray                                   = "sharegray"
        static let kDotgray                                     = "dotgray"
        static let kLikehandblackselected                       = "likehandblackselected"
        static let kLikehandblack                               = "likehandblack"
        static let kSendBtn                                     = "send_btn"
        static let kOneStar                                     = "one_star"
        static let kBackArrowBlack                              = "back_arrow_black"
        static let kMute                                        = "mute"
        static let kUnMute                                      = "unmute"
        static let kVideoinBlack                                = "videoinBlack"
        static let kNoPostUserLogo                              = "noPostUserLogo"
        static let kCameraBlack                                 = "cameraBlack"
        static let kCircleBlank                                 = "circleBlank"
        static let kCircleFill                                  = "circleFill"
        static let kClose                                       = "close"
        static let kCloseDark                                   = "closeDark"
        static let kDiscoverBackgroundImage                     = "DiscoverBackgroundImage"
        static let kDotpink                                     = "dot_pink"
        static let kMikepink                                    = "mikepink"
        static let kPlus                                        = "plus"
        static let kSharepink                                   = "sharepink"
        static let kRibbon                                      = "ribbon"
        static let kCameraupload                                = "cameraupload"
        static let kBackarrowwhite                              = "backarrowwhite"
        static let kBellwhite                                   = "bellwhite"
        static let kCheckedpink                                 = "checked_pink"
        static let kUncheckedBox                                = "un_checked"
        static let kFlower1                                     = "flower1"
        static let kFlower2                                     = "flower2"
        static let kFlower3                                     = "flower3"
        static let kFlower4                                     = "flower4"
        static let kRadioUnchecked                              = "radio_unchecked"
        static let kRadioChecked                                = "radio_checked"
        static let kTriagleupArrowtag                           = "triagle_up_Arrow_tag"
        static let kTrashblack                                  = "trash_black"
        static let kAudioBanner                                 = "audioBanner"
        static let kAudioDefault                                = "audioDefault"
        static let kGroupVideoBanner                            = "select_group_video_banner"
    }
    
    //MARK: - ConstantString
    struct ConstantString {
        static let kEmailRegex                  = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+\\.[A-Za-z]{1,}(\\.[A-Za-z]{1,}){0,}"
    }
}
