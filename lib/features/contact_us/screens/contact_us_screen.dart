import 'package:flutter/material.dart';
import 'package:hexacom_user/common/enums/footer_type_enum.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/common/widgets/custom_app_bar_widget.dart';
import 'package:hexacom_user/common/widgets/custom_button_widget.dart';
import 'package:hexacom_user/common/widgets/custom_text_field_widget.dart';
import 'package:hexacom_user/common/widgets/footer_web_widget.dart';
import 'package:hexacom_user/common/widgets/osm_iframe_map_widget.dart';
import 'package:hexacom_user/common/widgets/web_app_bar_widget.dart';
import 'package:hexacom_user/features/contact_us/providers/contact_us_provider.dart';
import 'package:hexacom_user/features/profile/providers/profile_provider.dart';
import 'package:hexacom_user/features/splash/providers/splash_provider.dart';
import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/helper/custom_snackbar_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/routes.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:provider/provider.dart';

/// Subject options sent as text in the API subject field.
enum ContactSubject {
  inquiry,
  complaint,
  suggestion,
  orderIssue,
  other,
}

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _messageFocus = FocusNode();
  ContactSubject? _selectedSubject;

  double? _tryParseDouble(String? v) => v == null ? null : double.tryParse(v);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromUser());
  }

  void _prefillFromUser() {
    if (!mounted) return;
    final profile = context.read<ProfileProvider>().userInfoModel;
    if (profile != null) {
      if (_nameController.text.isEmpty && (profile.fName != null || profile.lName != null)) {
        _nameController.text = '${profile.fName ?? ''} ${profile.lName ?? ''}'.trim();
      }
      if (_emailController.text.isEmpty && profile.email != null && profile.email!.isNotEmpty) {
        _emailController.text = profile.email!;
      }
      if (_phoneController.text.isEmpty && profile.phone != null && profile.phone!.isNotEmpty) {
        _phoneController.text = profile.phone!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  String _subjectToText(ContactSubject s) {
    switch (s) {
      case ContactSubject.inquiry:
        return getTranslated('subject_inquiry', context);
      case ContactSubject.complaint:
        return getTranslated('subject_complaint', context);
      case ContactSubject.suggestion:
        return getTranslated('subject_suggestion', context);
      case ContactSubject.orderIssue:
        return getTranslated('subject_order_issue', context);
      case ContactSubject.other:
        return getTranslated('subject_other', context);
    }
  }

  String? _getFieldError(ContactUsProvider provider, String field) {
    final err = provider.lastFieldErrors[field];
    if (err != null && err.isNotEmpty) return err;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final config = context.read<SplashProvider>().configModel;
    final branch = (config?.branches != null && config!.branches!.isNotEmpty) ? config.branches!.first : null;
    final lat = _tryParseDouble(branch?.latitude) ?? _tryParseDouble(config?.ecommerceLocationCoverage?.latitude);
    final lng = _tryParseDouble(branch?.longitude) ?? _tryParseDouble(config?.ecommerceLocationCoverage?.longitude);

    return Scaffold(
      appBar: isDesktop
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120),
              child: WebAppBarWidget(),
            )
          : CustomAppBarWidget(
              title: getTranslated('contact_us', context),
              onBackPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  RouteHelper.getMainRoute(context, action: RouteAction.pushNamedAndRemoveUntil);
                }
              },
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Center(
                child: SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeExtraLarge,
                                        vertical: Dimensions.paddingSizeDefault,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.18),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 44,
                                            width: 44,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            child: const Icon(Icons.support_agent_rounded, color: Colors.white),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeDefault),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  getTranslated('contact_us', context),
                                                  style: rubikBold.copyWith(fontSize: Dimensions.fontSizeLarge + 2),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  getTranslated('contact_us_subtitle', context),
                                                  style: rubikRegular.copyWith(
                                                    fontSize: Dimensions.fontSizeSmall,
                                                    color: Theme.of(context).hintColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                                    Consumer<ContactUsProvider>(
                                      builder: (context, contactUsProvider, _) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            CustomTextFieldWidget(
                                              title: getTranslated('first_name', context),
                                              isRequired: true,
                                              hintText: getTranslated('first_name', context),
                                              isShowBorder: true,
                                              controller: _nameController,
                                              focusNode: _nameFocus,
                                              nextFocus: _emailFocus,
                                              inputType: TextInputType.name,
                                              capitalization: TextCapitalization.words,
                                            ),
                                            if (_getFieldError(contactUsProvider, 'name') != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4, left: 4),
                                                child: Text(
                                                  _getFieldError(contactUsProvider, 'name')!,
                                                  style: rubikRegular.copyWith(
                                                    fontSize: 12,
                                                    color: Theme.of(context).colorScheme.error,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),
                                            CustomTextFieldWidget(
                                              title: getTranslated('email', context),
                                              isRequired: true,
                                              hintText: getTranslated('email', context),
                                              isShowBorder: true,
                                              controller: _emailController,
                                              focusNode: _emailFocus,
                                              nextFocus: _phoneFocus,
                                              inputType: TextInputType.emailAddress,
                                            ),
                                            if (_getFieldError(contactUsProvider, 'email') != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4, left: 4),
                                                child: Text(
                                                  _getFieldError(contactUsProvider, 'email')!,
                                                  style: rubikRegular.copyWith(
                                                    fontSize: 12,
                                                    color: Theme.of(context).colorScheme.error,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),
                                            CustomTextFieldWidget(
                                              title: getTranslated('mobile_number', context),
                                              hintText: getTranslated('mobile_number', context),
                                              isShowBorder: true,
                                              controller: _phoneController,
                                              focusNode: _phoneFocus,
                                              nextFocus: _messageFocus,
                                              inputType: TextInputType.phone,
                                            ),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),
                                            _SubjectDropdown(
                                              selectedSubject: _selectedSubject,
                                              subjectToText: _subjectToText,
                                              onChanged: (ContactSubject? v) => setState(() => _selectedSubject = v),
                                            ),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),
                                            CustomTextFieldWidget(
                                              title: getTranslated('your_message', context),
                                              isRequired: true,
                                              hintText: getTranslated('your_message', context),
                                              isShowBorder: true,
                                              controller: _messageController,
                                              focusNode: _messageFocus,
                                              maxLines: 5,
                                              inputType: TextInputType.multiline,
                                              inputAction: TextInputAction.newline,
                                              capitalization: TextCapitalization.sentences,
                                            ),
                                            if (_getFieldError(contactUsProvider, 'message') != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4, left: 4),
                                                child: Text(
                                                  _getFieldError(contactUsProvider, 'message')!,
                                                  style: rubikRegular.copyWith(
                                                    fontSize: 12,
                                                    color: Theme.of(context).colorScheme.error,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: Dimensions.paddingSizeLarge),
                                            CustomButtonWidget(
                                              isLoading: contactUsProvider.isLoading,
                                              btnTxt: contactUsProvider.isLoading
                                                  ? getTranslated('sending', context)
                                                  : getTranslated('send', context),
                                              onTap: () async {
                                                final name = _nameController.text.trim();
                                                final email = _emailController.text.trim();
                                                final phone = _phoneController.text.trim();
                                                final message = _messageController.text.trim();
                                                final subject = _selectedSubject != null ? _subjectToText(_selectedSubject!) : null;

                                                if (name.isEmpty) {
                                                  showCustomSnackBar(getTranslated('name_required', context), context, isError: true);
                                                  return;
                                                }
                                                if (email.isEmpty) {
                                                  showCustomSnackBar(getTranslated('email_required', context), context, isError: true);
                                                  return;
                                                }
                                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                                if (!emailRegex.hasMatch(email)) {
                                                  showCustomSnackBar(getTranslated('email_invalid', context), context, isError: true);
                                                  return;
                                                }
                                                if (message.isEmpty) {
                                                  showCustomSnackBar(getTranslated('message_required', context), context, isError: true);
                                                  return;
                                                }

                                                final ResponseModel result = await contactUsProvider.sendContactUsMessage(
                                                  name: name,
                                                  email: email,
                                                  phone: phone.isEmpty ? null : phone,
                                                  subject: subject,
                                                  message: message,
                                                );
                                                if (!context.mounted) return;
                                                if (result.isSuccess) {
                                                  showCustomSnackBar(
                                                    getTranslated('contact_success_message', context),
                                                    context,
                                                    isError: false,
                                                  );
                                                  _nameController.clear();
                                                  _emailController.clear();
                                                  _phoneController.clear();
                                                  _messageController.clear();
                                                  setState(() => _selectedSubject = null);
                                                } else {
                                                  final msg = result.message == 'throttle_message'
                                                      ? getTranslated('throttle_message', context)
                                                      : (result.message ?? '');
                                                  showCustomSnackBar(msg, context, isError: true);
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraLarge),
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 520,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: (lat != null && lng != null)
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                          child: OsmIframeMapWidget(latitude: lat, longitude: lng),
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.map_outlined, size: 34, color: Theme.of(context).hintColor),
                                            const SizedBox(height: 8),
                                            Text(
                                              getTranslated('map_no_store_coordinates', context),
                                              style: rubikRegular.copyWith(color: Theme.of(context).hintColor),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeLarge,
                                  vertical: Dimensions.paddingSizeSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  getTranslated('contact_us', context),
                                  style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            Consumer<ContactUsProvider>(
                              builder: (context, contactUsProvider, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    CustomTextFieldWidget(
                                      title: getTranslated('first_name', context),
                                      isRequired: true,
                                      hintText: getTranslated('first_name', context),
                                      isShowBorder: true,
                                      controller: _nameController,
                                      focusNode: _nameFocus,
                                      nextFocus: _emailFocus,
                                      inputType: TextInputType.name,
                                      capitalization: TextCapitalization.words,
                                    ),
                                    if (_getFieldError(contactUsProvider, 'name') != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4, left: 4),
                                        child: Text(
                                          _getFieldError(contactUsProvider, 'name')!,
                                          style: rubikRegular.copyWith(fontSize: 12, color: Theme.of(context).colorScheme.error),
                                        ),
                                      ),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),
                                    CustomTextFieldWidget(
                                      title: getTranslated('email', context),
                                      isRequired: true,
                                      hintText: getTranslated('email', context),
                                      isShowBorder: true,
                                      controller: _emailController,
                                      focusNode: _emailFocus,
                                      nextFocus: _phoneFocus,
                                      inputType: TextInputType.emailAddress,
                                    ),
                                    if (_getFieldError(contactUsProvider, 'email') != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4, left: 4),
                                        child: Text(
                                          _getFieldError(contactUsProvider, 'email')!,
                                          style: rubikRegular.copyWith(fontSize: 12, color: Theme.of(context).colorScheme.error),
                                        ),
                                      ),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),
                                    CustomTextFieldWidget(
                                      title: getTranslated('mobile_number', context),
                                      hintText: getTranslated('mobile_number', context),
                                      isShowBorder: true,
                                      controller: _phoneController,
                                      focusNode: _phoneFocus,
                                      nextFocus: _messageFocus,
                                      inputType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),
                                    _SubjectDropdown(
                                      selectedSubject: _selectedSubject,
                                      subjectToText: _subjectToText,
                                      onChanged: (ContactSubject? v) => setState(() => _selectedSubject = v),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),
                                    CustomTextFieldWidget(
                                      title: getTranslated('your_message', context),
                                      isRequired: true,
                                      hintText: getTranslated('your_message', context),
                                      isShowBorder: true,
                                      controller: _messageController,
                                      focusNode: _messageFocus,
                                      maxLines: 5,
                                      inputType: TextInputType.multiline,
                                      inputAction: TextInputAction.newline,
                                      capitalization: TextCapitalization.sentences,
                                    ),
                                    if (_getFieldError(contactUsProvider, 'message') != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4, left: 4),
                                        child: Text(
                                          _getFieldError(contactUsProvider, 'message')!,
                                          style: rubikRegular.copyWith(fontSize: 12, color: Theme.of(context).colorScheme.error),
                                        ),
                                      ),
                                    const SizedBox(height: Dimensions.paddingSizeLarge),
                                    CustomButtonWidget(
                                      isLoading: contactUsProvider.isLoading,
                                      btnTxt: contactUsProvider.isLoading
                                          ? getTranslated('sending', context)
                                          : getTranslated('send', context),
                                      onTap: () async {
                                        final name = _nameController.text.trim();
                                        final email = _emailController.text.trim();
                                        final phone = _phoneController.text.trim();
                                        final message = _messageController.text.trim();
                                        final subject = _selectedSubject != null ? _subjectToText(_selectedSubject!) : null;

                                        if (name.isEmpty) {
                                          showCustomSnackBar(getTranslated('name_required', context), context, isError: true);
                                          return;
                                        }
                                        if (email.isEmpty) {
                                          showCustomSnackBar(getTranslated('email_required', context), context, isError: true);
                                          return;
                                        }
                                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                        if (!emailRegex.hasMatch(email)) {
                                          showCustomSnackBar(getTranslated('email_invalid', context), context, isError: true);
                                          return;
                                        }
                                        if (message.isEmpty) {
                                          showCustomSnackBar(getTranslated('message_required', context), context, isError: true);
                                          return;
                                        }

                                        final ResponseModel result = await contactUsProvider.sendContactUsMessage(
                                          name: name,
                                          email: email,
                                          phone: phone.isEmpty ? null : phone,
                                          subject: subject,
                                          message: message,
                                        );
                                        if (!context.mounted) return;
                                        if (result.isSuccess) {
                                          showCustomSnackBar(
                                            getTranslated('contact_success_message', context),
                                            context,
                                            isError: false,
                                          );
                                          _nameController.clear();
                                          _emailController.clear();
                                          _phoneController.clear();
                                          _messageController.clear();
                                          setState(() => _selectedSubject = null);
                                        } else {
                                          final msg = result.message == 'throttle_message'
                                              ? getTranslated('throttle_message', context)
                                              : (result.message ?? '');
                                          showCustomSnackBar(msg, context, isError: true);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),
            ),
            if (isDesktop) const FooterWebWidget(footerType: FooterType.nonSliver),
          ],
        ),
      ),
    );
  }
}

class _SubjectDropdown extends StatelessWidget {
  final ContactSubject? selectedSubject;
  final String Function(ContactSubject) subjectToText;
  final ValueChanged<ContactSubject?> onChanged;

  const _SubjectDropdown({
    required this.selectedSubject,
    required this.subjectToText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: getTranslated('subject', context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
        contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ContactSubject?>(
          value: selectedSubject,
          isExpanded: true,
          hint: Text(
            getTranslated('select_subject_optional', context),
            style: rubikRegular.copyWith(color: Theme.of(context).hintColor),
          ),
          items: [
            const DropdownMenuItem<ContactSubject?>(value: null, child: Text('')),
            ...ContactSubject.values.map((s) => DropdownMenuItem<ContactSubject?>(
                  value: s,
                  child: Text(subjectToText(s)),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
