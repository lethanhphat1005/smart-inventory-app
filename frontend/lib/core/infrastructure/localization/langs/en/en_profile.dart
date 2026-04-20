import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enProfile = {
  //--Profile
  TTexts.profileTitle: 'Profile',
  //--User
  TTexts.profileNameUser: '',
  TTexts.profileEmailUser: '',
  TTexts.profilePhoneNumber: '',
  TTexts.profileNameStore: '',
  //--Section
  TTexts.profileAccount: "Account",
  TTexts.profileManagement: "Management",
  //--Actions
  TTexts.profileChangePassword: 'Change password',
  TTexts.profileMyAccount: 'My profile',
  TTexts.profileUserManagement: 'User management',
  //--Btn
  TTexts.profileBtnSwitchStore: "Switch store",
  TTexts.profileBtnLogout: "Logout",
  //--Dialog
  TTexts.profileDialogTitleLogout: 'Logout Confirmation',
  TTexts.profileDialogDescriptionLogout:
      'Are you sure you want to log out of your account?',
  TTexts.profileDialogBtnLogout: 'Yes',

  //-------------------------------------------------------------
  //Edit profile
  TTexts.editTitle: 'Edit Profile',
  TTexts.editLoading: 'Loading',
  TTexts.editEmail: 'Email',
  TTexts.editName: 'Full Name',
  TTexts.editHintName: 'Enter full name',
  TTexts.editHintEmail: 'Enter email',
  TTexts.editUpdate: 'Update',
  TTexts.editPhoneNumberEmpty: 'Please enter your phone number.',
  TTexts.editPhoneNumberInvalid: 'Please enter a valid phone number.',
  TTexts.editPhoneNumber: 'Phone Number',
  TTexts.editPhoneNumberHint: 'Enter phone number',
  TTexts.editErrorEmptyFieldsTitle: 'Input Error',
  TTexts.confirmUpdate: 'Confirm Update',
  TTexts.confirmUpdateDescription:
      'Are you sure you want to update your profile?',

  //Change Password
  TTexts.changePasswordTitle: 'Change Password',
  TTexts.changePasswordOldPassword: 'Old Password',
  TTexts.changePasswordNewPassword: 'New Password',
  TTexts.changePasswordConfirm: 'Confirm',
  TTexts.changePasswordBtnConfirm: "Confirm",
  TTexts.changePasswordHintOldPassword: 'Enter Old Password',
  TTexts.changePasswordHintNewPassword: 'Enter New Password',
  TTexts.changePasswordHintConfirmPassword: 'Enter Confirm Password',
  TTexts.passwordNotMatch: 'New password and confirmation do not match.',
  TTexts.passwordSameAsOld:
      'New password cannot be the same as your current password.',
  TTexts.passwordChangedSuccess: 'Your password has been updated successfully.',
  TTexts.oldPasswordIncorrect: 'The current password you entered is incorrect.',
  TTexts.authSessionExpired: 'Session expired. Please log in again.',
  TTexts.systemError: 'A system error occurred. Please try again later.',
  TTexts.authError: 'Authentication failed',
  TTexts.changePasswordDialogDescription:
      'Are you sure you want to change your password?',
  TTexts.fillAllFields: 'Please enter full information',

  //Edit Store
  TTexts.editStoreTitle: 'My Stores',
  TTexts.editStoreSubtitle: 'Manage and Edit your stores',
  TTexts.editStoreNameLabel: 'Store Name',
  TTexts.editStoreNameHint: 'Enter store name',
  TTexts.editStoreAddressLabel: 'Address *',
  TTexts.editStoreAddressHint: 'Enter store address',
  TTexts.editStoreAmountMember: 'Members',
  TTexts.editStoreBtnEdit: 'Edit',
  TTexts.profileUpdateStoreSuccess: 'Store updated successfully',
  TTexts.profileUpdateSuccess: 'Profile updated successfully',
  TTexts.loadingTitle: 'Loading',
  TTexts.editStoreCurrentStore: 'Current Store',
  TTexts.profileNoStoreSelected: 'No store selected',
  TTexts.profileUpdateErrorTitle: 'Profile Update Failed',
  TTexts.loggingOut: 'Logging out...',
  TTexts.logoutErrorTitle: 'Logout Failed',
  TTexts.editStoreTitleDialog: 'Edit Store',
  TTexts.editStoreSubtitleDialog: 'You can update the store information here.',
  TTexts.editStoreDialogDescription:
      'Are you sure you want to update your store profile?',
  TTexts.profileUpdateError: 'Failed to update profile',

  //Assign Role
  TTexts.assignsRoleTitle: 'Assigns Role',
  TTexts.assignsRoleSubtitle: 'Manage user roles and permissions',
  TTexts.assignsRoleBtnSave: 'Save',
  TTexts.assignsRoleSearchHint: 'Search by name',
  TTexts.assignsRoleAll: 'All',
  TTexts.assignsRoleOwner: 'Owner',
  TTexts.assignsRoleManager: 'Manager',
  TTexts.assignsRoleStaff: 'Staff',

  //Member List
  TTexts.profileNoMembers: 'No members found',
  TTexts.profileNoMembersSubtitle: 'There are no members in this store.',
};
