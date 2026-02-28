/// ProjekWatch - Centralized String Constants
/// No hardcoded strings in UI code
class AppStrings {
  AppStrings._();

  // ─────────────────────────────────────────────────────────────────────────
  // APP
  // ─────────────────────────────────────────────────────────────────────────
  static const String appName = 'ProjekWatch';
  static const String appTagline = 'Community Project Tracking';

  // ─────────────────────────────────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────────────────────────────────
  static const String navDiscover = 'Discover';
  static const String navSaved = 'Saved';
  static const String navExplore = 'Explore';
  static const String navProfile = 'Profile';
  static const String tabProjects = 'Projects';
  static const String tabCategories = 'Categories';
  static const String tabInsights = 'Insights';

  // ─────────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────────────────────────────────
  static const String contribute = 'Contribute';
  static const String addCheckin = 'Add Check-in';
  static const String showAllPhotos = 'Show all photos';
  static const String save = 'Save';
  static const String share = 'Share';
  static const String seeAll = 'See all';
  static const String showMore = 'Show more';
  static const String showLess = 'Show less';
  static const String clear = 'Clear';
  static const String cancel = 'Cancel';
  static const String submit = 'Submit';

  // ─────────────────────────────────────────────────────────────────────────
  // SECTIONS
  // ─────────────────────────────────────────────────────────────────────────
  static const String activeProjectsNearYou = 'Active Projects Near You';
  static const String recentlyFlaggedAsStalled = 'Recently Flagged as Stalled';
  static const String publicInfrastructure = 'Public Infrastructure';
  static const String privateDevelopments = 'Private Developments';
  static const String searchResults = 'Search Results';
  static const String projectInsights = 'Project Insights';
  static const String statusBreakdown = 'Status Breakdown';
  static const String confidenceLevels = 'Confidence Levels';

  // ─────────────────────────────────────────────────────────────────────────
  // PROJECT DETAILS
  // ─────────────────────────────────────────────────────────────────────────
  static const String aboutThisProject = 'About this project';
  static const String projectDetails = 'Project Details';
  static const String whereYoullFindIt = "Where you'll find it";
  static const String managedBy = 'Managed by';
  static const String communityCheckIns = 'Community Check-ins';
  static const String communityReports = 'Community Reports';
  static const String timeline = 'Timeline';
  static const String expectedCompletion = 'Expected Completion';
  static const String lastActivity = 'Last Activity';
  static const String lastVerified = 'Last Verified';
  static const String notSpecified = 'Not specified';
  static const String noDeadline = 'No deadline';
  static const String verified = 'Verified';

  // ─────────────────────────────────────────────────────────────────────────
  // STATUS
  // ─────────────────────────────────────────────────────────────────────────
  static const String active = 'Active';
  static const String slowing = 'Slowing';
  static const String stalled = 'Stalled';
  static const String unverified = 'Unverified';

  // ─────────────────────────────────────────────────────────────────────────
  // CONFIDENCE
  // ─────────────────────────────────────────────────────────────────────────
  static const String highConfidence = 'High';
  static const String mediumConfidence = 'Medium';
  static const String lowConfidence = 'Low';
  static const String confidenceSuffix = ' confidence';

  // ─────────────────────────────────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────────────────────────────────
  static const String housing = 'Housing';
  static const String road = 'Road';
  static const String drainage = 'Drainage';
  static const String school = 'School';
  static const String publicLabel = 'Public';
  static const String privateLabel = 'Private';

  // ─────────────────────────────────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────────────────────────────────
  static const String searchProjects = 'Search projects...';
  static const String searchByNameOrLocation = 'Search by name or location';
  static const String filterByCategory = 'Filter by category';
  static const String filterByStatus = 'Filter by status';
  static const String allCategories = 'All Categories';
  static const String allStatuses = 'All Statuses';

  // ─────────────────────────────────────────────────────────────────────────
  // EMPTY STATES
  // ─────────────────────────────────────────────────────────────────────────
  static const String noProjectsFound = 'No projects found';
  static const String noCheckIns = 'No check-ins yet';
  static const String comingSoon = 'Coming soon';

  // ─────────────────────────────────────────────────────────────────────────
  // DISCLAIMERS & INFO
  // ─────────────────────────────────────────────────────────────────────────
  static const String communityDataDisclaimer = 
      'Community-reported data. Not a legal finding. Information is provided as-is and may not reflect the official project status.';
  static const String insightsDisclaimer = 
      'Community-reported data. Not a legal finding. Help improve accuracy by contributing check-ins.';
  static String overviewOfProjects(int count) => 'Overview of $count tracked projects';
  static String checkInsCount(int count) => '$count check-ins';
  static String communityCheckInsCount(int count) => '$count community check-ins';

  // ─────────────────────────────────────────────────────────────────────────
  // CHECK-IN FORM
  // ─────────────────────────────────────────────────────────────────────────
  static const String addNewCheckin = 'Add New Check-in';
  static const String whatDidYouObserve = 'What did you observe?';
  static const String selectStatus = 'Select current status';
  static const String addNote = 'Add a note about your observation...';
  static const String yourName = 'Your name';
  static const String optionalPhoto = 'Add photo (optional)';
}
