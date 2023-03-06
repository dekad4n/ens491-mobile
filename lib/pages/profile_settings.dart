import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/providers/metamask.dart';
import 'package:tickrypt/providers/user_provider.dart';
import 'package:tickrypt/services/user.dart';
import 'package:tickrypt/widgets/atoms/buttons/changeAvatar.dart';
import 'package:tickrypt/widgets/organisms/headers/settingsHeader.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettings extends StatefulWidget {
  final dynamic user;
  final dynamic token;
  const ProfileSettings({Key? key, this.user, this.token}) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  UserService userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();
  var _avatarAsBytes;
  bool changed = false;
  var changedAvatar;
  var avatar;
  XFile? _coverImage;
  void _pickImageFromGallery() async {
    XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _coverImage = pickedFile;
        changed = true;
        changedAvatar = pickedFile.path;
      });
      var imageBytes = await pickedFile.readAsBytes();

      // String encodedImage = base64Encode(imageBytes);

      setState(() {
        _avatarAsBytes = imageBytes;
        // imageBase64Encoded = encodedImage;
      });
    }
  }

  bool isNameChangeEnabled = false;
  void onPressEdit() {
    setState(() {
      isNameChangeEnabled = true;
    });
  }

  var _name = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              settingsHeader(context, widget.user, widget.token, changed,
                  changedAvatar, _avatarAsBytes, _name),
              changeAvatar(avatar, _pickImageFromGallery),
              Container(
                width: MediaQuery.of(context).size.width * 344 / 385,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF5200FF),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!isNameChangeEnabled)
                          Text(
                            widget.user.username.length > 16
                                ? widget.user.username.substring(0, 16) + ".."
                                : widget.user.username,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF050A31)),
                          ),
                        if (isNameChangeEnabled)
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 4 / 7,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  _name = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                } else {
                                  setState(() {
                                    _name = value;
                                  });
                                }
                                return null;
                              },
                            ),
                          ),
                        IconButton(
                            onPressed: () {
                              onPressEdit();
                            },
                            icon: Icon(CupertinoIcons.pen))
                      ]),
                ),
              )
            ],
            // Get Minted Tickets
          ),
        ),
      ),
    );
  }
}
