import 'package:equatable/equatable.dart';

class JobEntity extends Equatable {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type; // Full-time, Internship, etc.
  final String description;
  final String postedByUid;
  final String postedByName;
  final DateTime postedAt;
  final bool isReferral;
  final String? externalLink;
  final bool isActive;
  final List<String> interestedUserIds;
  final String postType; // "referral" or "post"
  final List<String> likedByUids;

  const JobEntity({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    required this.postedByUid,
    required this.postedByName,
    required this.postedAt,
    this.isReferral = false,
    this.externalLink,
    this.isActive = true,
    this.interestedUserIds = const [],
    this.postType = "post",
    this.likedByUids = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        company,
        location,
        type,
        description,
        postedByUid,
        postedByName,
        postedAt,
        isReferral,
        externalLink,
        isActive,
        interestedUserIds,
        postType,
        likedByUids,
      ];
}
