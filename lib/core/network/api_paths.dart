class ApiPaths {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String requestChangePasswordOtp = '/auth/change-password/request-otp';
  static const String confirmChangePasswordOtp = '/auth/change-password/confirm-otp';

  // Profile / User
  static const String myProfile = '/profile/me';
  static const String updateMyProfile = '/profile/me';
  static const String myReadingHistory = '/profile/me/reading-history';
  static const String myFollowedComics = '/profile/me/follows';
  static const String myProfileGuild = '/profile/me/guild';

  // Cultivation / Realms
  static const String myCultivation = '/cultivation/me';
  static const String cultivationRealms = '/cultivation/realms';
  static const String cultivationLevels = '/cultivation/levels';
  static const String cultivationBreakthroughRules = '/cultivation/breakthrough-rules';
  static const String attemptBreakthrough = '/cultivation/breakthrough';

  // Comics / Chapters
  static const String comics = '/comics';
  static const String comicGenres = '/comics/genres';
  static const String comicRankings = '/comics/rankings';
  static String comicDetail(int id) => '/comics/$id';
  static String followComic(int id) => '/comics/$id/follow';
  static String chaptersByComic(int comicId) => '/chapters/comic/$comicId';
  static String chapterDetail(int chapterId) => '/chapters/$chapterId';
  static String saveChapterProgress(int chapterId) => '/chapters/$chapterId/read-progress';

  // Comments
  static const String comments = '/comments';
  static String comicComments(int comicId) => '/comments/comic/$comicId';
  static String chapterComments(int chapterId) => '/comments/chapter/$chapterId';
  static String updateComment(int id) => '/comments/$id';
  static String deleteComment(int id) => '/comments/$id';

  // Guild
  static const String guilds = '/guilds';
  static const String myGuild = '/guilds/me';

  static String guildDetail(int id) => '/guilds/$id';
  static String guildMembers(int id) => '/guilds/$id/members';
  static String guildJoinRequests(int id) => '/guilds/$id/join-requests';
  static String guildDonations(int id) => '/guilds/$id/donations';
  static String joinGuild(int id) => '/guilds/$id/join';
  static String cancelGuildJoinRequest(int id) => '/guilds/$id/join/cancel';

  static String guildLeave(int guildId) => '/guilds/$guildId/leave';
  static String guildDisband(int guildId) => '/guilds/$guildId/disband';
  static String guildCheckin(int guildId) => '/guilds/$guildId/checkin';
  static String guildContribute(int guildId) => '/guilds/$guildId/contribute';
  static String guildUpdate(int guildId) => '/guilds/$guildId';
  static String guildMemberRole(int guildId, int memberId) => '/guilds/$guildId/members/$memberId/role';
  static String guildMemberKick(int guildId, int memberId) => '/guilds/$guildId/members/$memberId/kick';

  static String leaveGuild(int guildId) => guildLeave(guildId);
  static String disbandGuild(int guildId) => guildDisband(guildId);
  static String checkinGuild(int guildId) => guildCheckin(guildId);
  static String contributeGuild(int guildId) => guildContribute(guildId);
  static String updateGuild(int guildId) => guildUpdate(guildId);
  static String updateGuildAnnouncement(int guildId) => '/guilds/$guildId/announcement';
  static String updateGuildMemberRole(int guildId, int memberId) => guildMemberRole(guildId, memberId);
  static String kickGuildMember(int guildId, int memberId) => guildMemberKick(guildId, memberId);

  static String approveGuildJoinRequest(int first, [int? second]) {
    if (second == null) return '/guilds/join-requests/$first/approve';
    return '/guilds/$first/join-requests/$second/approve';
  }

  static String rejectGuildJoinRequest(int first, [int? second]) {
    if (second == null) return '/guilds/join-requests/$first/reject';
    return '/guilds/$first/join-requests/$second/reject';
  }

  // Chat
  static const String chatRooms = '/chat/rooms';
  static String chatMessages(int roomId) => '/chat/rooms/$roomId/messages';

  // Notifications
  static const String myNotifications = '/notifications/me';
  static String markNotificationRead(int id) => '/notifications/$id/read';

  // Rankings
  static const String rankingTypes = '/rankings/types';
  static String rankingByType(String typeCode) => '/rankings/$typeCode';
  static String myRankingByType(String typeCode) => '/rankings/$typeCode/me';

  // AFK
  static const String afkConfigs = '/afk/configs';
  static const String afkSessions = '/afk/sessions';
  static const String runningAfkSession = '/afk/sessions/running';
  static String finishAfkSession(int id) => '/afk/sessions/$id/finish';
  static String claimAfkSession(int id) => '/afk/sessions/$id/claim';

  // Shop / Economy
  static const String shopItems = '/shop/items';
  static String buyShopItem(int id) => '/shop/items/$id/buy';

  // Missions
  static const String myMissions = '/missions/me';
  static String claimMissionReward(int missionId) => '/missions/$missionId/claim';

  // VIP
  static const String vipLevels = '/vip/levels';
  static const String vipFeatures = '/vip/features';
  static const String vipMe = '/vip/me';

  // Inventory
  static const String myInventory = '/inventory/me';
  static const String useInventoryItem = '/inventory/use';

  // Checkin / Payments
  static const String checkin = '/checkin';
  static const String inventory = '/inventory';
  static const String payments = '/payments';
}
