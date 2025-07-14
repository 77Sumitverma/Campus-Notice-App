import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_notice_app/controllers/update_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:readmore/readmore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Home Screen/Widgets/EditNoticeScreen.dart';


class NoticeCard extends StatefulWidget {
  @override
  _NoticeCardState createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> with TickerProviderStateMixin {
  final updateController = Get.find<UpdateController>();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  double _height = 200;
  bool _isExpanded = false;
  int _selectedCardIndex = -1;

  void _toggleHeight(int index) {
    setState(() {
      if (_selectedCardIndex == index && _isExpanded) {
        _isExpanded = false;
        _height = 200;
        _selectedCardIndex = -1;
      } else {
        _isExpanded = true;
        _height = 500;
        _selectedCardIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          height: _height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: updateController.updatesList.length,
            itemBuilder: (context, index) {
              final notice = updateController.updatesList[index];
              final bool isThisCardExpanded =
                  _isExpanded && _selectedCardIndex == index;

              final currentUser = FirebaseAuth.instance.currentUser;
              final isUploader = notice.uploaderUID == currentUser?.uid;
              final isAdmin = notice.uploaderName.toLowerCase() == 'admin';
              final showOptions = isUploader || isAdmin;

              return Transform.scale(
                scale: 0.95,
                child: GestureDetector(
                  onTap: () => _toggleHeight(index),
                  onLongPress: () {
                    if (showOptions) {
                      setState(() {
                        _selectedCardIndex = index;
                      });
                    } else {
                      Get.snackbar("Access Denied",
                          "Only uploader or admin can edit/delete this notice.");
                    }
                  },
                  child: Stack(
                    children: [
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.deepPurple,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.all(20.0),
                          child: SingleChildScrollView(
                            physics: isThisCardExpanded
                                ? const BouncingScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "👤 ${notice.uploaderName}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          "📅 ${DateFormat.yMMMd().add_jm().format(notice.createdAt.toDate())}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (showOptions)
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.white),
                                            onPressed: () {
                                              final noticeId = notice.noticeID;
                                              Get.to(() => EditNoticeScreen(
                                                noticeId: noticeId,
                                                initialTitle: notice.title,
                                                initialDescription: notice.description,
                                                fileType:notice.fileTypes?? [],
                                                fileUrl: notice.fileUrls?? [],

                                                // fileUrls: notice.fileUrls,
                                                // fileTypes: notice.fileTypes,
                                              ));
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.redAccent),
                                            onPressed: () {
                                              updateController
                                                  .deleteFromFirestore(
                                                  notice.noticeID);
                                              setState(() {
                                                _selectedCardIndex = -1;
                                                _isExpanded = false;
                                                _height = 200;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    notice.title,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ReadMoreText(
                                  notice.description,
                                  trimLines: 3,
                                  colorClickableText: Colors.blueAccent,
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: 'Read more',
                                  trimExpandedText: 'Read less',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                  moreStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                  lessStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (notice.fileUrls.isNotEmpty)
                                  Column(
                                    children: List.generate(
                                      notice.fileUrls.length,
                                          (i) {
                                        final fileUrl =
                                        notice.fileUrls[i];
                                        final fileType =
                                        notice.fileTypes[i];
                                        if (fileType == 'image') {
                                          return Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                bottom: 10),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => Dialog(
                                                      backgroundColor:
                                                      Colors.black,
                                                      insetPadding:
                                                      const EdgeInsets
                                                          .all(10),
                                                      child:
                                                      InteractiveViewer(
                                                        panEnabled: true,
                                                        minScale: 0.5,
                                                        maxScale: 4,
                                                        child: Image.network(
                                                          fileUrl,
                                                          fit: BoxFit
                                                              .contain,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Image.network(
                                                  fileUrl,
                                                  height: 150,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (fileType == 'pdf') {
                                          return Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                bottom: 10),
                                            child: InkWell(
                                              onTap: () async {
                                                final url =
                                                Uri.parse(fileUrl);
                                                bool launched =
                                                await launchUrl(url,
                                                    mode: LaunchMode
                                                        .externalApplication);
                                                if (!launched) {
                                                  launched =
                                                  await launchUrl(url,
                                                      mode: LaunchMode
                                                          .inAppWebView);
                                                }
                                                if (!launched) {
                                                  Get.snackbar("Error",
                                                      "Cannot open PDF");
                                                }
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                children: const [
                                                  Icon(
                                                      Icons
                                                          .picture_as_pdf,
                                                      color:
                                                      Colors.white),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Open Attached PDF",
                                                    style: TextStyle(
                                                      color:
                                                      Colors.white70,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Obx(() => SmoothPageIndicator(
          controller: _pageController,
          count: updateController.updatesList.length,
          effect: JumpingDotEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Colors.deepPurple,
            dotColor: Colors.grey.shade300,
          ),
        )),
      ],
    ));
  }
}





/// 🔥 PDF Viewer Screen

class PdfViewerScreen extends StatelessWidget {
  final String? filePath; // Local file path
  final String? url;      // Online URL

  const PdfViewerScreen({super.key, this.filePath, this.url});

  @override
  Widget build(BuildContext context) {
    File? file = filePath != null ? File(filePath!) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
        backgroundColor: Colors.deepPurple.shade200,
      ),
      body: url != null
          ? SfPdfViewer.network(url!)
          : (file != null && file.existsSync()
          ? SfPdfViewer.file(file)
          : const Center(
        child: Text(
          "File not found!",
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      )),
    );
  }
}

