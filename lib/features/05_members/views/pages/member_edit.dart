import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/data/helpers/form_verify.dart';
import '../../../../core/models/member.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/picture_display.dart';
import '../controllers/member_controller.dart';
import '../dialogs/camera_or_gallery.dart';
import '../dialogs/delete_user.dart';

class MemberEditScreen extends StatefulWidget {
  const MemberEditScreen({Key? key, required this.member}) : super(key: key);

  final Member member;

  @override
  _MemberEditScreenState createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  /* <---- Dependency ----> */
  final MembersController _controller = Get.find();
  static const MethodChannel _channel = MethodChannel('turingtech');

  _addDataToFields() {
    _name.text = widget.member.memberName;
    _phoneNumber.text = widget.member.memberNumber.toString();
    _fullAddress.text = widget.member.memberFullAdress;
  }

  /* <---- Input Fields ----> */
  late TextEditingController _name;
  late TextEditingController _phoneNumber;
  late TextEditingController _fullAddress;
  // Initailize
  void _initializeTextController() {
    _name = TextEditingController();
    _phoneNumber = TextEditingController();
    _fullAddress = TextEditingController();
  }

  // Dispose
  void _disposeTextController() {
    _name.dispose();
    _phoneNumber.dispose();
    _fullAddress.dispose();
  }

  // Other
  final RxBool _updatingMember = false.obs;

  // Image
  File? _userImage;
  // Uint8List? _userFeat;
  final RxBool _userPickedImage = false.obs;

  // Form Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// When user clicks update button
  Future<void> _onUserUpdate() async {
    bool _isFormOkay = _formKey.currentState!.validate();
    if (_isFormOkay) {
      _updatingMember.value = true;
      await _controller.updateMember(
        name: _name.text,
        memberPicture: _userImage,
        phoneNumber: int.parse(_phoneNumber.text),
        fullAddress: _fullAddress.text,
        member: widget.member,
        isCustom: true,
      );
      _updatingMember.value = false;
      Get.back();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeTextController();
    _addDataToFields();
  }

  @override
  void dispose() {
    _disposeTextController();
    _updatingMember.close();
    _userPickedImage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Member',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Get.dialog(DeleteUserDialog(
                memberID: widget.member.memberID!,
              ));
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.defaultPadding),
            width: Get.width,
            child: Column(
              children: [
                Obx(
                  () => ProfilePictureWidget(
                      onTap: () async {
                        _userImage =
                            await Get.dialog(const CameraGallerySelectDialog());
                        // If the user has picked an image then we will show
                        // the file user has picked
                        if (_userImage != null) {
                          _userPickedImage.trigger(true);

                          Uint8List _capturedImage =
                              _userImage!.readAsBytesSync();
                          Uint8List? _feats =
                              await _channel.invokeMethod('getFeature', {
                            'image': _capturedImage,
                            'mode': 1 //1 -> enroll mode, 0 -> verify mode
                          });
                          if (_feats != null) {
                            print("get feature feat: " +
                                _feats.length.toString());
                          } else {
                            //failed getFeature process
                          }
                        }
                      },
                      isLocal: _userPickedImage.value,
                      profileLink: widget.member.memberPicture,
                      localImage: _userImage),
                ),
                /* <---- Form INFO ----> */
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_rounded),
                            hintText: 'John Doe',
                          ),
                          controller: _name,
                          autofocus: true,
                          validator: (fullName) {
                            return AppFormVerify.name(fullName: fullName);
                          },
                        ),
                        AppSizes.hGap20,
                        TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: Icon(Icons.phone_rounded),
                              hintText: '+852 XXX-XXX',
                            ),
                            controller: _phoneNumber,
                            validator: (phone) {
                              return AppFormVerify.phoneNumber(phone: phone);
                            }),
                        AppSizes.hGap20,
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Full Address',
                            prefixIcon: Icon(Icons.location_on_rounded),
                            hintText: 'Ocean Centre, Tsim Sha Tsui, Hong Kong',
                          ),
                          controller: _fullAddress,
                          validator: (address) {
                            return AppFormVerify.address(address: address);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                AppSizes.hGap10,
                Obx(
                  () => AppButton(
                    width: Get.width * 0.6,
                    label: 'Update',
                    isLoading: _updatingMember.value,
                    onTap: _onUserUpdate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}