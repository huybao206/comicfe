class ApiPaths {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Profile
  static const String myProfile = '/profile/me';
  static const String updateMyProfile = '/profile/me';
  static const String myReadingHistory = '/profile/me/reading-history';
  static const String myFollowedComics = '/profile/me/follows';

  // Comics
  static const String comics = '/comics';
  static String comicDetail(int id) => '/comics/$id';
  static String followComic(int id) => '/comics/$id/follow';
  static String chaptersByComic(int comicId) => '/chapters/comic/$comicId';
  static String chapterDetail(int chapterId) => '/chapters/$chapterId';

  // Guild
  static const String guilds = '/guilds';
  static String guildDetail(int id) => '/guilds/$id';
  static String guildMembers(int id) => '/guilds/$id/members';
  static String guildJoinRequests(int id) => '/guilds/$id/join-requests';
  static String guildDonations(int id) => '/guilds/$id/donations';

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
  static String finishAfkSession(int id) => '/afk/sessions/$id/finish';
  static String claimAfkSession(int id) => '/afk/sessions/$id/claim';

  // Shop
  static const String shopItems = '/shop/items';
  static String buyShopItem(int id) => '/shop/items/$id/buy';

  // VIP
  static const String vipLevels = '/vip/levels';
  static const String vipFeatures = '/vip/features';
  static const String vipMe = '/vip/me';

  // Comments
  static const String comments = '/comments';
  static String comicComments(int comicId) => '/comments/comic/$comicId';
  static String chapterComments(int chapterId) => '/comments/chapter/$chapterId';
  static String updateComment(int id) => '/comments/$id';
  static String deleteComment(int id) => '/comments/$id';

  // TODO API

  static const String missions = '/missions';
  static const String checkin = '/checkin';
  static const String inventory = '/inventory';
  static const String payments = '/payments';
}