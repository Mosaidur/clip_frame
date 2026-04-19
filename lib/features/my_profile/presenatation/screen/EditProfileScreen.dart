import 'dart:io';
import 'package:clip_frame/core/model/user_model.dart';
import 'package:clip_frame/features/my_profile/presenatation/screen/MyProfileController.dart';
import 'package:clip_frame/shared/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clip_frame/core/widgets/custom_back_button.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final MyProfileController controller = Get.find<MyProfileController>();
  final TextEditingController _nameTEController = TextEditingController();
  final TextEditingController _phoneTEController = TextEditingController();
  final TextEditingController _businessNameTEController =
      TextEditingController();
  final TextEditingController _businessCategoryTEController =
      TextEditingController();
  final TextEditingController _businessDescriptionTEController =
      TextEditingController();
  final TextEditingController _businessTypeTEController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = controller.userModel.value;
    if (user != null) {
      _nameTEController.text = user.name;
      _phoneTEController.text = user.phone;
      _businessNameTEController.text = user.businessName ?? "";
      _businessCategoryTEController.text = user.businessCategory ?? "";
      _businessDescriptionTEController.text = user.businessDescription ?? "";
      _businessTypeTEController.text = user.businessType;
    }
    // Reset selected image after build to avoid setState during build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedImage.value = null;
      controller.selectedLogo.value = null;
    });
  }

  @override
  void dispose() {
    _nameTEController.dispose();
    _phoneTEController.dispose();
    _businessNameTEController.dispose();
    _businessCategoryTEController.dispose();
    _businessDescriptionTEController.dispose();
    _businessTypeTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Edit Profile".tr,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: CustomBackButton(
          onPressed: () => Get.back(),
          iconColor: Colors.white,
          size: 52.0,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBC794), Color(0xFFB38FFC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Image Picker
                Center(
                  child: Stack(
                    children: [
                      Obx(() {
                        return Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: controller.selectedImage.value != null
                                ? Image.file(
                                    controller.selectedImage.value!,
                                    fit: BoxFit.cover,
                                  )
                                : (controller.userModel.value?.image != null &&
                                      controller
                                          .userModel
                                          .value!
                                          .image!
                                          .isNotEmpty)
                                ? Image.network(
                                    controller.userModel.value!.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                          ),
                        );
                      }),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: controller.pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFB38FFC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Card Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          "Full Name".tr,
                          _nameTEController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name'.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          "Phone Number".tr,
                          _phoneTEController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number'.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          "Business Name".tr,
                          _businessNameTEController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter business name'.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          "Business Category".tr,
                          _businessCategoryTEController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter business category'.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          "Business Type".tr,
                          _businessTypeTEController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter business type'.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          "Business Description".tr,
                          _businessDescriptionTEController,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter business description'.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Branding Section (Logo & Colors)
                        _buildLabel("Branding (Logo & Colors)".tr),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Logo Edit
                            Column(
                              children: [
                                Text(
                                  "Logo".tr,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Stack(
                                  children: [
                                    Obx(() {
                                      return Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child:
                                            controller.selectedLogo.value !=
                                                null
                                            ? Image.file(
                                                controller.selectedLogo.value!,
                                                fit: BoxFit.cover,
                                              )
                                            : (controller
                                                          .onboardingData
                                                          .value
                                                          ?.logo !=
                                                      null &&
                                                  controller
                                                      .onboardingData
                                                      .value!
                                                      .logo
                                                      .isNotEmpty)
                                            ? Image.network(
                                                controller
                                                    .onboardingData
                                                    .value!
                                                    .logo,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.business,
                                                      size: 30,
                                                      color: Colors.grey,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.business,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                      );
                                    }),
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: InkWell(
                                        onTap: controller.pickLogo,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFB38FFC),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 30),
                            // Colors Edit
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Brand Colors".tr,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildColorPicker(
                                        "Primary".tr,
                                        controller.primaryColor,
                                      ),
                                      const SizedBox(width: 20),
                                      _buildColorPicker(
                                        "Secondary".tr,
                                        controller.secondaryColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Current Target Audience (with remove option)
                        // Target Audience Selection
                        _buildLabel("Target Audience".tr),
                        const SizedBox(height: 8),
                        Obx(
                          () => DropdownButtonFormField<String>(
                            key: UniqueKey(), // Force fresh widget on each rebuild to clear internal value state
                            isExpanded: true,
                            value: null,
                            hint: Text("Add Target Audience".tr),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            items: controller.availableAudiences
                                .where((a) => !controller.selectedAudiences.contains(a))
                                .map((a) => DropdownMenuItem(
                                      value: a,
                                      child: Text(a.tr),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.addTargetAudience(val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.selectedAudiences.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: controller.selectedAudiences.map((audience) {
                              return Chip(
                                label: Text(audience.tr),
                                onDeleted: () =>
                                    controller.removeTargetAudience(audience),
                                deleteIcon: const Icon(
                                  Icons.close,
                                  size: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: const Color(0xFFB38FFC).withOpacity(0.1),
                                labelStyle: const TextStyle(fontSize: 12),
                              );
                            }).toList(),
                          );
                        }),
                        const SizedBox(height: 24),


                        // Timezone Selection
                        _buildLabel("Timezone".tr),
                        const SizedBox(height: 8),
                        Obx(
                          () => DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: controller.availableTimezones.contains(
                                    controller.selectedTimezone.value)
                                ? controller.selectedTimezone.value
                                : controller.availableTimezones.first,
                            items: controller.availableTimezones
                                .map(
                                  (tz) => DropdownMenuItem(
                                    value: tz,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        tz,
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.setTimezone(val);
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Password and Subscription Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Membership Plan:".tr,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB38FFC).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (controller.userModel.value?.membership ??
                                        "Free Plan")
                                    .tr,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFFB38FFC),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            Get.toNamed(AppRoutes.forgotPassword);
                          },
                          icon: const Icon(Icons.lock_reset),
                          label: Text("Change Password".tr),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Save Button
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isUpdating.value
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        controller.updateProfile(
                                          name: _nameTEController.text.trim(),
                                          phone: _phoneTEController.text.trim(),
                                          businessCategory:
                                              _businessCategoryTEController.text
                                                  .trim(),
                                          businessName:
                                              _businessNameTEController.text
                                                  .trim(),
                                          businessDescription:
                                              _businessDescriptionTEController
                                                  .text
                                                  .trim(),
                                          businessType:
                                              _businessTypeTEController.text
                                                  .trim(),
                                          timezone:
                                              controller.selectedTimezone.value,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB38FFC),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: controller.isUpdating.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Save Changes".tr,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildColorPicker(String label, Rx<Color> colorObs) {
    return Column(
      children: [
        Obx(() {
          return GestureDetector(
            onTap: () {
              _showColorPickerDialog(label, colorObs);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorObs.value,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colorObs.value.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showColorPickerDialog(String title, Rx<Color> colorObs) {
    Color pickerColor = colorObs.value;
    Get.dialog(
      AlertDialog(
        title: Text('Pick $title Color'.tr),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(child: Text('Cancel'.tr), onPressed: () => Get.back()),
          TextButton(
            child: Text('Select'.tr),
            onPressed: () {
              colorObs.value = pickerColor;
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: "Enter $label",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.purple),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}
