import 'dart:typed_data';
import '../../widgets/member_image_leading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_sizes.dart';
import '../../../controllers/members/member_controller.dart';
import '../../../controllers/verifier/verify_controller.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_defaults.dart';
import '../../../constants/app_images.dart';
import '../../../controllers/camera/camera_controller.dart';
import 'static_verifier_sheet_lock.dart';
import '../../themes/text.dart';

class StaticVerifierScreen extends StatefulWidget {
  const StaticVerifierScreen({Key? key}) : super(key: key);

  @override
  State<StaticVerifierScreen> createState() => _StaticVerifierScreenState();
}

class _StaticVerifierScreenState extends State<StaticVerifierScreen> {
  /* <---- We should wait a little bit to finish the build,
  because on lower end device it takes time to start the device,
  so the controller doesn't start immedietly.Then we see some white screen, that's why we should wait a little bit.
   -----> */

  final RxBool _isScreenReady = false.obs;

  Future<void> _waitABit() async {
    await Future.delayed(
      const Duration(seconds: 1),
    ).then((value) {
      Get.put(AppCameraController());
      Get.put(MembersController());
      Get.put(VerifyController());
    });
    _isScreenReady.trigger(true);
  }

  @override
  void initState() {
    super.initState();
    _waitABit();
  }

  @override
  void dispose() {
    Get.delete<AppCameraController>(force: true);
    _isScreenReady.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: SafeArea(
          child: Column(
            children: [
              Obx(
                () => _isScreenReady.isFalse
                    ? const _LoadingCamera()
                    : const _CameraSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCamera extends StatelessWidget {
  const _LoadingCamera({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: Get.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: Get.width * 0.5,
              child: Hero(
                  tag: AppImages.mainLogo,
                  child: Image.asset(AppImages.mainLogo)),
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _CameraSection extends StatelessWidget {
  const _CameraSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppCameraController>(
      init: AppCameraController(),
      builder: (controller) => controller.activatingCamera == true
          ? const Expanded(child: Center(child: CircularProgressIndicator()))
          : Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // CameraPreview(controller.controller),
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CameraPreview(controller.cameraController),
                  ),

                  /* <---- Verifier Button ----> */
                  Positioned(
                    width: Get.width * 0.9,
                    bottom: Get.height * 0.04,
                    child: const _UnlockButton(),
                  ),
                  /* <---- Camera Switch Button ----> */
                  Positioned(
                    top: Get.height * 0.1,
                    right: 10,
                    child: FloatingActionButton(
                      onPressed: controller.toggleCameraLens,
                      child: const Icon(Icons.switch_camera_rounded),
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ),

                  /// MESSAGE SHOWING
                  Positioned(
                    bottom: Get.height * 0.15,
                    left: 0,
                    right: 0,
                    child: const _ShowMessage(),
                  ),

                  /// TEMPORARY
                  const _TemporaryFunctionToCheckMethod(),
                ],
              ),
            ),
    );
  }
}

class _UnlockButton extends StatelessWidget {
  const _UnlockButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDefaults.defaulBorderRadius,
        boxShadow: AppDefaults.defaultBoxShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () async {
              String _url = 'https://turingtech.vip';
              // Launch Website
              await canLaunch(_url)
                  ? await launch(_url)
                  : throw 'Could not launch $_url';
            },
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(
                AppImages.mainLogo,
              ),
            ),
          ),
          Text(
            'Verifier',
            style: AppText.h6.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          IconButton(
            onPressed: () {
              Get.bottomSheet(const StaticVerifierLockUnlock(),
                  isScrollControlled: true);
            },
            icon: const Icon(Icons.lock),
          ),
        ],
      ),
    );
  }
}

class _ShowMessage extends StatelessWidget {
  /// This will show up when verification started
  const _ShowMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyController>(
      builder: (controller) {
        return Center(
          child: AnimatedOpacity(
            // IF We Should show the card
            opacity: controller.showProgressIndicator ? 1.0 : 0.0,
            duration: AppDefaults.defaultDuration,
            child: AnimatedContainer(
              duration: AppDefaults.defaultDuration,
              margin: const EdgeInsets.all(AppSizes.defaultMargin),
              padding: const EdgeInsets.all(10),
              width: Get.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDefaults.defaulBorderRadius,
                boxShadow: AppDefaults.defaultBoxShadow,
              ),
              child: controller.isVerifyingNow
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          AppSizes.wGap10,
                          Text('Verifying'),
                        ],
                      ),
                    )
                  : controller.verifiedMember == null
                      ? const ListTile(
                          title: Text('No Member Found'),
                          trailing: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                        )
                      : ListTile(
                          leading: MemberImageLeading(
                            imageLink: controller.verifiedMember!.memberPicture,
                          ),
                          title: Text(controller.verifiedMember!.memberName),
                          subtitle: Text(controller.verifiedMember!.memberNumber
                              .toString()),
                          trailing: const Icon(
                            Icons.check_box_rounded,
                            color: AppColors.appGreen,
                          ),
                        ),
            ),
          ),
        );
      },
    );
  }
}

class _TemporaryFunctionToCheckMethod extends GetView<AppCameraController> {
  const _TemporaryFunctionToCheckMethod({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: Get.height * 0.12,
      child: Column(
        children: [
          FloatingActionButton.extended(
            onPressed: () async {
              XFile _image = await controller.cameraController.takePicture();
              Uint8List _file = await _image.readAsBytes();

              bool _isPersonPresent = await Get.find<VerifyController>()
                  .isPersonDetected(capturedImage: _file);

              if (_isPersonPresent) {
                Get.snackbar(
                  'A Face is detected',
                  'This is a dummy function, you should return the real value',
                  colorText: Colors.white,
                  backgroundColor: Colors.green,
                );
              }
            },
            label: const Text('Detect Person'),
            icon: const Icon(Icons.camera),
            backgroundColor: AppColors.primaryColor,
          ),
          AppSizes.hGap20,
          /* <----  -----> */
          FloatingActionButton.extended(
            onPressed: () async {
              XFile _image = await controller.cameraController.takePicture();
              Uint8List _uin8file = await _image.readAsBytes();
              // File _file = File.fromRawPath(_uin8file);

              String? user = await Get.find<VerifyController>()
                  .verifyPersonList(memberToBeVerified: _uin8file);

              if (user != null) {
                Get.snackbar(
                  'Person Verified: $user',
                  'Verified Member',
                  colorText: Colors.white,
                  backgroundColor: Colors.green,
                );
              }
            },
            label: const Text('Verify From All'),
            icon: const Icon(Icons.people_alt_rounded),
            backgroundColor: AppColors.primaryColor,
          ),
          AppSizes.hGap20,
          /* <----  -----> */
          // FloatingActionButton.extended(
          //   onPressed: () async {
          //     XFile _image = await controller.cameraController.takePicture();
          //     Uint8List _file = await _image.readAsBytes();

          //     String _currentUserImageUrl =
          //         Get.find<AppUserController>().currentUser.userProfilePicture!;
          //     File _currentUserImage =
          //         await AppPhotoService.fileFromImageUrl(_currentUserImageUrl);

          //     bool _isVerified =
          //         await Get.find<VerifyController>().verfiyPersonSingle(
          //       capturedImage: _file,
          //       personImage: _currentUserImage,
          //     );

          //     if (_isVerified) {
          //       Get.snackbar(
          //         'Person Verified Successfull',
          //         'Verified Member',
          //         colorText: Colors.white,
          //         backgroundColor: Colors.green,
          //       );
          //     }
          //   },
          //   label: Text('Verify Single'),
          //   icon: Icon(Icons.person),
          //   backgroundColor: AppColors.PRIMARY_COLOR,
          // ),
        ],
      ),
    );
  }
}
