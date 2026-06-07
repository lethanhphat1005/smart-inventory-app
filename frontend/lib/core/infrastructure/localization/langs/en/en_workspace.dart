import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enWorkspace = {
  // -- Workspace Selection
  TTexts.workspaceSelectionTitle: "Select Your Workspace",
  TTexts.workspaceSelectionSubtitle:
      "Choose the environment you want to work in today.",
  TTexts.joinAWorkspace: "Click",
  TTexts.createYourWorkspace: "Create New Store",
  TTexts.requestAccess: "Request Access",
  TTexts.requestAccessDesc: "Enter a store code to join an existing team.",
  TTexts.needHelp: "Need Help?",
  TTexts.whatIsWorkspace: "What is a Workspace?",
  TTexts.workspaceDescription:
      "A Workspace (or Store) is a shared environment where you and your team manage inventory, track shipments, and view reports.\n\n• To join an existing workspace, you need a 6-digit Store Code provided by your Manager.\n• If you are a business owner, you can create a new workspace to start managing your own inventory.",
  TTexts.understood: "Understood",
  TTexts.storeSelectionSuccessTitle: "Store Selected",
  TTexts.storeSelectionSuccessMessage: "Successfully joined",
  TTexts.activeStoreBadge: "Current",

  // -- Create Workspace
  TTexts.createStoreTitle: "Create New Store",
  TTexts.createStoreSubtitle:
      "Set up your store to start managing inventory and team members.",
  TTexts.storeNameLabel: "Workspace Name *",
  TTexts.storeNameHint: "e.g., HQ Branch, Main Warehouse",
  TTexts.storeAddressLabel: "Address (Optional)",
  TTexts.storeAddressHint: "Enter the physical address",
  TTexts.storeNameEmptyError: "Workspace name cannot be empty.",
  TTexts.confirmCreateStoreTitle: "Confirm Creation",
  TTexts.confirmCreateStoreMessage:
      "Are you sure you want to create a new workspace named",
  TTexts.workspaceCreatedTitle: "Workspace Created!",
  TTexts.workspaceCreatedDesc: "is ready for business.",
  TTexts.youAreManager: "Store Manager",
  TTexts.addMembers: "Add Members",
  TTexts.goToDashboard: "Go to Dashboard",
  TTexts.searchAddressHint: "Search for address...",
  TTexts.useCurrentLocation: "Current Location",
  TTexts.locationStr: "Location",
  TTexts.creatingYourWorkspace: "Creating...",
  TTexts.creatingWorkspace: "Creating your workspace...",
  TTexts.backToWorkspaces: "Back to Workspaces",
  TTexts.gpsOffTitle: "GPS Disabled",
  TTexts.gpsOffMessage:
      "Please turn on location services in your system settings.",
  TTexts.locationErrorMessage:
      "Could not fetch location. Please try again or type manually.",
  TTexts.warningEmptyName: "Please enter a workspace name.",
  TTexts.warningStoreExists:
      "A workspace with this name or address already exists. Please try another.",
  TTexts.storeCurrencyLabel: "Store Currency *",
  TTexts.loadingCurrency: "Loading currencies...",

  // -- Invite Code & Join Store
  TTexts.inviteCodeTitle: "Your Invite Code",
  TTexts.inviteCodeSubtitle:
      "Share this code with your staff so they can join this store.",
  TTexts.inviteCodeCopiedTitle: "Copied!",
  TTexts.inviteCodeCopiedMessage: "Invite code has been copied to clipboard.",

  TTexts.joinWorkspaceTitle: "Join Workspace",
  TTexts.joinWorkspaceSubtitle:
      "Enter the invite code provided by your Owner to connect to the system.",
  TTexts.enterInviteCodeLabel: "Invite Code",
  TTexts.enterInviteCodeHint: "e.g., ABCD-EFGH",
  TTexts.joinBtn: "Join Now",
  TTexts.joiningBtn: "Joining...",
  TTexts.checkingInviteCode: "Checking invite code...",

  TTexts.joinMissingCodeTitle: "Missing Information",
  TTexts.joinMissingCodeMessage:
      "Please enter a valid 6-character invite code.",
  TTexts.joinInvalidCodeTitle: "Invalid Code",
  TTexts.joinInvalidCodeMessage: "The invite code is incorrect or has expired.",
  TTexts.joinAlreadyMemberTitle: "Already a Member",
  TTexts.joinAlreadyMemberMessage:
      "You are already a member of this workspace.",
  TTexts.joinSuccessTitle: "Successfully Joined!",
  TTexts.joinSuccessMessage: "Welcome to the workspace.",

  // -- Add Members Screen
  TTexts.addMembersTitle: "Manage Members",
  TTexts.addMembersSubtitle:
      "View and manage your team members and their roles within this workspace.",
  TTexts.membersCount: "Members",
  TTexts.roleManager: "Manager",
  TTexts.roleOwner: 'Owner',
  TTexts.roleStaff: "Staff",
  TTexts.youBadge: "You",

  TTexts.generateInviteCodeBtn: "Generate Invite Code",
  TTexts.generateCodeDialogTitle: "Generate New Code?",
  TTexts.generateCodeDialogMessage:
      "Are you sure you want to generate a new invite code? Any previous unredeemed codes will be invalidated.",
  TTexts.confirmGenerate: "Generate",
  TTexts.generatingCode: "Generating secure code...",
  TTexts.generatedAt: "Generated: ",
  TTexts.expiresAt: "Expires in: 24 hours",
  TTexts.activeInviteCodeTitle: "Active Invite Code",
  TTexts.emptyMemberTitle: "No Members Yet",
  TTexts.emptyMemberSubtitle:
      "Generate an invite code and share it with your team to start collaborating.",
  TTexts.confirmChangeRoleTitle: "Change Role?",
  TTexts.confirmChangeRoleMessage:
      "Are you sure you want to change the role for",
  TTexts.updatingRole: "Updating role...",
  TTexts.roleUpdatedSuccess: "Member role updated successfully.",
  TTexts.inviteCodeGeneratedSuccess:
      "New invite code has been generated successfully!",
  TTexts.plsGenerateNewCode: "Pls, generate new code!",
  TTexts.copyTooltip: "Copy",
  TTexts.shareTooltip: "Share",
  TTexts.generateNewCodeTooltip: "Generate new code",
};
