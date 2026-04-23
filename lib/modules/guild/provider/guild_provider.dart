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
  List<GuildMember> members = [];

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

      guildDetail = await guildService.getGuildDetail(guildId);

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
    required String slug,
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

  void clearDetail() {
    guildDetail = null;
    members = [];
    errorMessage = null;
    notifyListeners();
  }
}