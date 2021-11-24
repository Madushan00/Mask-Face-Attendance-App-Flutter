import '../../dialogs/add_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_colors.dart';
import '../../themes/text.dart';
import 'members_list.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                /* <---- Header ----> */
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Members',
                    style: AppText.h6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const MembersList(),
              ],
            ),
            /* <---- Member Add ----> */
            Positioned(
              bottom: 20,
              right: Get.width * 0.07,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Get.dialog(const AddUserDialog());
                },
                icon: const Icon(
                  Icons.person_add_rounded,
                ),
                label: const Text('Add'),
                backgroundColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
