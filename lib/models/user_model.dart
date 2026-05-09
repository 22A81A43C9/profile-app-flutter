import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoUrl;
  final Education education;
  final ProfessionalDetails professional;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
    required this.education,
    required this.professional,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      photoUrl: data['photoUrl'],
      education: Education.fromMap(data['education'] ?? {}),
      professional: ProfessionalDetails.fromMap(data['professional'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'education': education.toMap(),
      'professional': professional.toMap(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    Education? education,
    ProfessionalDetails? professional,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      education: education ?? this.education,
      professional: professional ?? this.professional,
    );
  }
}

class Education {
  final String degree;
  final String institution;
  final String yearOfPassing;

  Education({
    required this.degree,
    required this.institution,
    required this.yearOfPassing,
  });

  factory Education.fromMap(Map<String, dynamic> data) {
    return Education(
      degree: data['degree'] ?? '',
      institution: data['institution'] ?? '',
      yearOfPassing: data['yearOfPassing'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'degree': degree,
      'institution': institution,
      'yearOfPassing': yearOfPassing,
    };
  }
}

class ProfessionalDetails {
  final String jobTitle;
  final String company;
  final String experience;
  final List<String> skills;
  final String bio;

  ProfessionalDetails({
    required this.jobTitle,
    required this.company,
    required this.experience,
    required this.skills,
    required this.bio,
  });

  factory ProfessionalDetails.fromMap(Map<String, dynamic> data) {
    return ProfessionalDetails(
      jobTitle: data['jobTitle'] ?? '',
      company: data['company'] ?? '',
      experience: data['experience'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      bio: data['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobTitle': jobTitle,
      'company': company,
      'experience': experience,
      'skills': skills,
      'bio': bio,
    };
  }
}
