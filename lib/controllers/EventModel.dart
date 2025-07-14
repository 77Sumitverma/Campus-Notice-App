import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';


class EventModel {
  final String title;
  final String description;
  final String date;
  final List<String> fileUrls;
  final List<String> fileTypes;
  final String uploaderUID;
  final String uploaderName;
  final Timestamp createdAt;
  final String eventID;


  EventModel({
    required this.title,
    required this.description,
    required this.date,
    required this.fileUrls,
    required this.fileTypes,
    required this.uploaderUID,
    required this.uploaderName,
    required this.createdAt,
    required this.eventID,

  });

  factory EventModel.fromMap(Map<String, dynamic> map, String docId) {
    return EventModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      fileUrls: List<String>.from(map['fileUrls'] ?? []),
      fileTypes: List<String>.from(map['fileTypes'] ?? []),
      uploaderUID: map['uploaderUID'] ?? '',
      uploaderName: map['uploaderName'] ?? '',
      createdAt: map['createdAt'],
      eventID: docId,
    );
  }
}
