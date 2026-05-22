import 'dart:io';

import 'package:flutter/material.dart';

import '../model/guild.dart';
import '../model/guild_member.dart';
import '../service/guild_service.dart';

class GuildProvider extends ChangeNotifier {
  GuildProvider({
    required this.guildService,
  });

  final GuildService guildService;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  List<Guild> guilds = [];
  Guild? guildDetail;
  Guild? myGuild;
  List<GuildMember> members = [];
  Map<String, dynamic>? myMembership;
  int? myGuildChatRoomId;

  bool get hasJoinedGuild => myGuild != null;

  bool get isMyGuildLeader {
    final membership = myMembership;
    if (membership == null) return false;

    final roleCode = (membership['role_code'] ?? membership['roleCode'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final roleName = (membership['role_name'] ?? membership['roleName'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    final permissions = membership['permissions'];
    bool canManageGuild = false;
    if (permissions is Map) {
      canManageGuild = permissions['can_manage_guild'] == true ||
          permissions['canManageGuild'] == true ||
          permissions['can_manage_guild'] == 1 ||
          permissions['canManageGuild'] == 1;
    }

    return roleCode == 'leader' ||
        roleCode == 'owner' ||
        roleName.contains('bang chủ') ||
        canManageGuild;
  }

  bool isCurrentUserGuild(int guildId) {
    return myGuild != null && myGuild!.id == guildId;
  }

  Future<void> loadGuildHome() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final profile = await guildService.getMyGuildProfile();

      if (profile != null && profile['guild'] is Map) {
        final guild = Guild.fromMap(profile);
        myGuild = guild;
        guildDetail = guild;
        myMembership = profile['my_membership'] is Map
            ? Map<String, dynamic>.from(profile['my_membership'] as Map)
            : null;
        myGuildChatRoomId = guild.chatRoomId;
        guilds = [];

        try {
          members = await guildService.getGuildMembers(guild.id);
        } catch (_) {
          members = [];
        }
      } else {
        myGuild = null;
        guildDetail = null;
        myMembership = null;
        myGuildChatRoomId = null;
        members = [];
        guilds = await guildService.getGuilds();
      }
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGuilds() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      guilds = await guildService.getGuilds();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGuildDetailFull(int guildId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final profile = await guildService.getGuildProfile(guildId);
      guildDetail = Guild.fromMap(profile);

      if (profile['my_membership'] is Map) {
        final membership = Map<String, dynamic>.from(profile['my_membership'] as Map);
        if (membership['is_member'] == true && guildDetail != null) {
          myGuild = guildDetail;
          myMembership = membership;
          myGuildChatRoomId = guildDetail!.chatRoomId;
        }
      }

      try {
        members = await guildService.getGuildMembers(guildId);
      } catch (_) {
        members = [];
      }
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGuild({
    required String name,
    String? slug,
    String? description,
  }) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await guildService.createGuild(
        name: name,
        slug: slug,
        description: description,
      );

      await loadGuildHome();
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> joinGuild(int guildId) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await guildService.joinGuild(guildId);
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }


  Future<bool> leaveMyGuild() async {
    final guild = myGuild ?? guildDetail;
    if (guild == null) return false;

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await guildService.leaveGuild(guild.id);
      myGuild = null;
      guildDetail = null;
      myMembership = null;
      myGuildChatRoomId = null;
      members = [];
      await loadGuildHome();
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> disbandMyGuild() async {
    final guild = myGuild ?? guildDetail;
    if (guild == null) return false;

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await guildService.disbandGuild(guild.id);
      myGuild = null;
      guildDetail = null;
      myMembership = null;
      myGuildChatRoomId = null;
      members = [];
      await loadGuildHome();
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> checkinMyGuild() async {
    final guild = myGuild ?? guildDetail;
    if (guild == null) return null;

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      final data = await guildService.checkinGuild(guild.id);
      await loadGuildDetailFull(guild.id);
      return data;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> contributeMyGuild() async {
    final guild = myGuild ?? guildDetail;
    if (guild == null) return null;

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      final data = await guildService.contributeGuild(guild.id);
      await loadGuildDetailFull(guild.id);
      return data;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }



  Future<bool> updateGuildLogo({
    required int guildId,
    required File logoFile,
  }) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      final updatedGuild = await guildService.updateGuildLogo(
        guildId: guildId,
        logoFile: logoFile,
      );

      guildDetail = updatedGuild;
      if (myGuild?.id == guildId) {
        myGuild = updatedGuild;
      }

      await loadGuildDetailFull(guildId);
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateMyGuildProfile({
    required String name,
    String? logoUrl,
    String? description,
    String? announcement,
    int? memberLimit,
    String? joinRequirementText,
    int? joinMinLevel,
    int? joinMinPower,
  }) async {
    final guild = myGuild ?? guildDetail;
    if (guild == null) return false;

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await guildService.updateGuildProfile(
        guildId: guild.id,
        name: name,
        logoUrl: logoUrl,
        description: description,
        announcement: announcement,
        memberLimit: memberLimit,
        joinRequirementText: joinRequirementText,
        joinMinLevel: joinMinLevel,
        joinMinPower: joinMinPower,
      );

      await loadGuildDetailFull(guild.id);
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateMemberRole({
    required int memberId,
    required String roleCode,
  }) async {
    final guild = myGuild ?? guildDetail;
    if (guild == null) return false;

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await guildService.updateMemberRole(
        guildId: guild.id,
        memberId: memberId,
        roleCode: roleCode,
      );

      await loadGuildDetailFull(guild.id);
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void clearDetail() {
    guildDetail = null;
    members = [];
    errorMessage = null;
    notifyListeners();
  }
}
