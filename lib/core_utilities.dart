library core_utilities;

import 'package:flutter/material.dart';

import 'form_input.dart';
import 'styles.dart';

ThemeData getTheme(Color primaryColor, Color normalBlack, Color borderColor,
    double borderRadius) {
  return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        secondary: Colors.white,
        surface: Colors.white,
        seedColor: primaryColor,
      ),
      useMaterial3: true,
      dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: Colors.white),
          inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(
            color: Colors.white,
          ))),
      appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 5,
          shadowColor: Colors.grey,
          titleTextStyle: const TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          backgroundColor: primaryColor),
      tabBarTheme: TabBarTheme(
        indicatorColor: primaryColor,
        labelColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primaryColor)),
      datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          )),
      scaffoldBackgroundColor: const Color.fromARGB(255, 240, 239, 248),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.only(left: 10),
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColor),
        ),
        outlineBorder: BorderSide(color: primaryColor),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(borderRadius)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(borderRadius)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(showCloseIcon: true),
      dialogTheme: DialogTheme(
        elevation: 2,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          extendedTextStyle: const TextStyle(fontWeight: FontWeight.bold)),
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent, elevation: 0),
      listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.only(left: 12, right: 12),
          horizontalTitleGap: 8,
          leadingAndTrailingTextStyle:
              TextStyle(fontWeight: FontWeight.w500, color: normalBlack),
          titleTextStyle:
              TextStyle(fontWeight: FontWeight.w500, color: normalBlack)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 10,
          selectedIconTheme: IconThemeData(size: 26),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold)),
      cardTheme: CardTheme(
          elevation: 0.6,
          margin: const EdgeInsets.only(bottom: 9),
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor),
          )),
      popupMenuTheme: const PopupMenuThemeData(
          labelTextStyle: WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          color: Colors.white,
          surfaceTintColor: Colors.white));
}

extension CoreUtilities on BuildContext {
  // FOCUS RELATED
  void unfocus() {
    FocusScope.of(this).unfocus();
  }

  Future<T?> showCustomDialog<T>(
    String title,
    String message,
    Map<String, Function> buttons, {
    Widget? contentWidget,
    bool barrierDismissible = false,
  }) async {
    return await showDialog<T>(
      barrierDismissible: barrierDismissible,
      context: this,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 22)),
            ],
          ),
          content: contentWidget ?? Text(message),
          actions: buttons.entries.map((MapEntry<String, Function> entry) {
            return TextButton(
                onPressed: () async {
                  if (!context.mounted) return;
                  Navigator.of(context).pop(await entry.value());
                },
                child: Text(entry.key));
          }).toList(),
        );
      },
    );
  }

  Future<T?> showBottomSheet<T>(
    String title,
    Widget content, {
    String? inputDescription,
    bool isDismissable = true,
    Color backgroundColor = Colors.white,
    List<FormInput> inputs = const [],
  }) async {
    GlobalKey<FormViewState> formKey = GlobalKey();
    BuildContext mainContext = this;
    return await showModalBottomSheet<T>(
      isScrollControlled: true,
      isDismissible: isDismissable,
      backgroundColor: Colors.transparent,
      context: this,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              color: backgroundColor,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    const SizedBox(height: 10),
                    if (inputs.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      FormView(inputs, key: formKey),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          style: Styles.mainButton,
                          onPressed: () async {
                            try {
                              Map data = formKey.currentState!.getData(
                                  ensureChanged: true, checkRequired: true);
                              context.pop(data);
                            } catch (e) {
                              mainContext.showSnackbar(e.toString());
                            }
                          },
                          child: const Text("Save")),
                    ] else
                      content
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // NAVIGATION
  void pop<T>([T? result]) {
    if (!this.mounted) {
      return;
    }
    Navigator.of(this).pop(result);
  }

  // SNACKBAR
  void showSnackbar(
    String message, {
    EdgeInsets margin = const EdgeInsets.all(0),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        margin: margin,
      ),
    );
  }

  // DIALOG RELATED
  Future<bool> getConfirmation(
    String title,
    String content, {
    Widget? contentWidget,
    String okText = "Okay",
    bool showCancel = true,
  }) async {
    Map<String, Function> actions = {};
    if (showCancel) {
      actions["Cancel"] = () => false;
    }
    actions[okText] = () => true;
    return await showCustomDialog<bool?>(
          title,
          content,
          actions,
          contentWidget: contentWidget,
        ) ??
        false;
  }
}
