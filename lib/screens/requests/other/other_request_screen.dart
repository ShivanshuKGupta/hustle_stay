import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/other/other_request.dart';
import 'package:hustle_stay/models/user/user.dart';
import 'package:hustle_stay/screens/filter_screen/filter_choser_screen.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/other/loading_elevated_button.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

// ignore: must_be_immutable
class OtherRequestScreen extends StatefulWidget {
  static const routeName = 'Other Request Screen';
  OtherRequest? request;
  OtherRequestScreen({
    super.key,
    this.request,
  });

  @override
  State<OtherRequestScreen> createState() => _OtherRequestScreenState();
}

class _OtherRequestScreenState extends State<OtherRequestScreen> {
  final _txtController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.request != null) {
      _txtController.text = widget.request!.reason;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    widget.request ??= OtherRequest(requestingUserEmail: currentUser.email!);
    final Map<String, dynamic> uiElement = widget.request!.uiElement;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GridTileLogo(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    title: 'Other',
                    icon: Icon(
                      uiElement['icon'],
                      size: 50,
                    ),
                    color: theme.colorScheme.background,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              UsersBuilder(
                provider: fetchComplainees,
                loadingWidget: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: circularProgressIndicator(),
                  ),
                ),
                builder: (ctx, users) => ComplaineeChooser(
                  title: 'Who to request?',
                  helpText: 'Add a user',
                  allUsers: users.map((e) => e.email!).toSet(),
                  onChange: (users) {
                    setState(() {
                      widget.request!.approvers = users.toList();
                    });
                  },
                  chosenUsers: widget.request!.approvers.toSet(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) => setState(() {}),
                controller: _txtController,
                decoration: InputDecoration(
                  hintText: 'Specify the details for the request here',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              LoadingElevatedButton(
                onPressed: _txtController.text.trim().isEmpty ||
                        widget.request!.approvers.isEmpty
                    ? null
                    : _save,
                icon: _loading
                    ? circularProgressIndicator()
                    : const Icon(Icons.done),
                label: const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (widget.request == null || _txtController.text.trim().isEmpty) {
      showMsg(context, 'Please specify the details for the request');
      return;
    }
    widget.request!.reason = _txtController.text.trim();
    setState(() {
      _loading = true;
    });
    List<String> approvers = widget.request!.approvers.map((e) => e).toList();
    widget.request!.approvers.clear();
    bool isUpdate = widget.request!.id != 0;
    if (!isUpdate) {
      widget.request!.id = DateTime.now().millisecondsSinceEpoch;
    }
    widget.request!.approvers = approvers;
    await widget.request!.update();
    await widget.request!.fetchApprovers();
    if (context.mounted) {
      setState(() {
        _loading = false;
      });
      while (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
      if (!isUpdate) {
        /// TODO: These lines of code allow us to navigate to the chat screen with a template message for the request
        // navigatorPush(
        //   context,
        //   ChatScreen(
        //     chat: widget.request!.chatData,
        //     initialMsg: MessageData(
        //       id: DateTime.now().millisecondsSinceEpoch.toString(),
        //       from: currentUser.email!,
        //       createdAt: DateTime.now(),
        //       txt: otherRequestMessage(widget.request!),
        //     ),
        //   ),
        // );
      }
    }
  }
}
