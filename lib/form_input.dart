library core_utilities;

import 'package:core_utilities/core_utilities.dart';
import 'package:core_utilities/str_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FormInputType {
  text,
  number,
  select,
  select_multiple,
  reorder_items,
  phone,
  price,
  date,
  bool
}

class FormView extends StatefulWidget {
  final List<FormInput> inputs;
  const FormView(
    this.inputs, {
    super.key,
  });

  @override
  State<FormView> createState() => FormViewState();
}

class FormViewState extends State<FormView> {
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    for (var input in widget.inputs) {
      input.controller.dispose();
    }
    super.dispose();
  }

  InputDecoration getInputDecoration(FormInput input) {
    return InputDecoration(
        prefixIcon: input.prefixIcon,
        labelText: "${input.name}${input.isRequired ? "" : '(optional)'}",
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 16.0),
        helperText: input.helperText.isNotEmpty ? input.helperText : null,
        hintStyle: const TextStyle(
          color: Colors.black45,
        ),
        hintText: input.hintText.isNotEmpty ? input.hintText : null,
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)));
  }

  Widget getInput(FormInput input) {
    if (input.showIf != null) {
      if (input.showIf!(getData()) == false) {
        return const SizedBox();
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: input.showInAppBar ? 0 : 13, top: 0),
      child: input.type == FormInputType.select
          ? input.canAddOption
              ? Autocomplete<String>(
                  optionsBuilder: (value) async {
                    setState(() {
                      input.controller.text = value.text;
                    });
                    return input.options.where((e) =>
                        e.toLowerCase().contains(value.text.toLowerCase()));
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Container(
                      constraints: const BoxConstraints(maxHeight: 100),
                      color: Colors.white,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) => ListTile(
                            dense: true,
                            onTap: () => onSelected(options.toList()[index]),
                            title: Text(options.toList()[index]),
                          ),
                        ),
                      ),
                    );
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                          VoidCallback onFieldSubmitted) =>
                      TextFormField(
                    onTapOutside: (event) => context.unfocus(),
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: getInputDecoration(input),
                    autofillHints: input.options,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onSelected: (option) {
                    context.unfocus();
                    setState(() {
                      input.controller.text = option;
                    });
                  },
                )
              : InputDecorator(
                  decoration: getInputDecoration(input),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: input.controller.text,
                      isDense: true,
                      onChanged: (String? newValue) {
                        if (input.onChange != null) {
                          input.onChange!(newValue, widget.inputs);
                        }
                        setState(() {
                          input.controller.text = newValue!;
                        });
                      },
                      items: input.options.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.replaceAll(
                              "_",
                              " ",
                            ),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
          : TextFormField(
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              enabled: !input.readOnly,
              readOnly: input.readOnly || input.type == FormInputType.date,
              autofocus: input.autoFocus,
              inputFormatters: <TextInputFormatter>[
                if (input.type == FormInputType.number)
                  FilteringTextInputFormatter.digitsOnly
              ],
              textCapitalization: TextCapitalization.sentences,
              controller: input.controller,
              validator: input.validator,
              keyboardType: input.keyboardType,
              maxLength: input.maxLength,
              onTap: () async {
                if (input.type == FormInputType.date) {
                  DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: input.value.isEmpty
                          ? DateTime.now()
                          : DateTime.parse(input.controller.text),
                      firstDate: input.firstDate ?? DateTime(1900),
                      lastDate: input.lastDate ?? DateTime(2100));

                  if (date != null) {
                    input.controller.text = date.toString().split(" ")[0];
                    setState(() {});
                  }
                }
              },
              decoration: InputDecoration(
                isDense: input.showInAppBar,
                prefixIcon: input.prefixIcon,
                errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                    borderRadius: BorderRadius.circular(15)),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                    borderRadius: BorderRadius.circular(15)),
                prefixIconConstraints:
                    const BoxConstraints(minHeight: 36, minWidth: 40),
                floatingLabelBehavior: input.showInAppBar
                    ? FloatingLabelBehavior.never
                    : input.type == FormInputType.date
                        ? FloatingLabelBehavior.always
                        : FloatingLabelBehavior.auto,
                helperText:
                    input.helperText.isNotEmpty ? input.helperText : null,
                hintStyle: const TextStyle(color: Colors.black45),
                hintText: input.hintText.isNotEmpty ? input.hintText : null,
                counterText: "",
                labelText: input.type == FormInputType.date
                    ? input.name
                    : "${input.name}${input.isRequired ? "" : ' (optional)'}",
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            children: widget.inputs.map((input) => getInput(input)).toList()));
  }

  Map getData({bool checkRequired = false, bool ensureChanged = false}) {
    bool changed = false;
    Map data = {};
    for (var input in widget.inputs) {
      String value = input.controller.text.trim();
      if (input.type == FormInputType.date) {
        value = "$value ${DateTime.now().toString().split(" ")[1]}";
      }
      if (!_formKey.currentState!.validate() && checkRequired) {
        throw Exception("${input.name} is required");
      }
      if (input.value != value) changed = true;
      data[input.id] = value;
    }

    if (!changed && ensureChanged) {
      // updating without changing
      throw Exception("No change is made");
    }
    return data;
  }
}

class FormInput {
  String id;
  String name;
  FormInputType type;
  String value;
  int maxLength;
  int minValue = 0;
  String hintText;
  String helperText;
  bool autoFocus = false;
  List<String> options;
  bool readOnly = false;
  bool quantitativeTags = false;
  int tagsLimit;
  DateTime? firstDate = DateTime.now();
  DateTime? lastDate = DateTime.now();
  bool canAddOption = false;
  bool showInAppBar = false;
  TextInputType keyboardType;
  bool isRequired;
  bool Function(dynamic data)? showIf = (data) => true;
  FocusNode focusNode = FocusNode();
  TextEditingController? optionsSearchController;
  Icon? prefixIcon;
  void Function(dynamic newValue, List<FormInput>)? onChange;
  TextEditingController controller = TextEditingController();
  FormInput(
    this.id, {
    this.type = FormInputType.text,
    this.value = "",
    this.name = "",
    this.keyboardType = TextInputType.text,
    this.maxLength = 200,
    this.canAddOption = true,
    this.isRequired = true,
    this.options = const [],
    this.tagsLimit = 10,
    this.hintText = "",
    this.helperText = "",
    this.prefixIcon,
    this.minValue = 0,
    this.showIf,
    this.firstDate,
    this.readOnly = false,
    this.lastDate,
    this.onChange,
    this.showInAppBar = false,
    this.autoFocus = false,
  }) {
    if (name.isEmpty) {
      name = id.replaceAll("_", " ").capitalize();
    }

    if (value.isNotEmpty) {
      controller.text = value;
    }

    options = options
        .map((e) => e.trim())
        .toSet()
        .where((e) => e.isNotEmpty && e != "null")
        .toList();

    if (prefixIcon == null) {
      if (name.toLowerCase().contains("name")) {
        prefixIcon = const Icon(Icons.person);
      } else if (name.toLowerCase().contains("note")) {
        prefixIcon = const Icon(Icons.notes_outlined);
      } else if (name.toLowerCase().contains("credit")) {
        prefixIcon = const Icon(Icons.payment);
      } else if (name.toLowerCase().contains("email")) {
        prefixIcon = const Icon(Icons.email);
        keyboardType = TextInputType.emailAddress;
      }
    }

    if (name == "Items") {
      quantitativeTags = true;
    }

    if (type == FormInputType.phone) {
      prefixIcon = const Icon(Icons.phone);
      keyboardType = TextInputType.phone;
    } else if (type == FormInputType.date) {
      prefixIcon = const Icon(Icons.calendar_today);
      controller.text = controller.text.split(" ")[0];
    } else if (type == FormInputType.number) {
      keyboardType = TextInputType.number;
    } else if (type == FormInputType.price) {
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
    } else if (type == FormInputType.select_multiple && !canAddOption) {
      optionsSearchController = TextEditingController();
    }
  }

  String? validator(String? value) {
    if (isRequired) {
      if (value == null || value.isEmpty) {
        return "$name is required";
      }
      if (type == FormInputType.number && int.parse(value) < minValue) {
        return "$name must be greater than $minValue";
      }
    }
    return null;
  }
}
