import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/authentication_bloc.dart';
import '../bloc/event/authentication_event.dart';
import '../bloc/event/system_event.dart';
import '../bloc/state/authentication_state.dart';
import '../bloc/state/system_state.dart';
import '../bloc/system_bloc.dart';
import '../localization/language.dart';
import '../model/authentication.dart';
import '../util/logger.dart';
import '../util/string_util.dart';
import '../widget/button.dart';
import '../widget/input_dropdown.dart';
import '../widget/input_text.dart';

typedef LoginAction = void Function();

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _selectedIndex = 0;

  final _numOfTabs = 2;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  final _selectedUseridController = TextEditingController();
  final _enteredUseridController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Create TabController for getting the index of current tab
    _tabController = TabController(length: _numOfTabs, vsync: this);

    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final i18n = Language.of(context);
    final horizontalPadding = MediaQuery.of(context).size.width / 8;
    final verticalPadding = MediaQuery.of(context).size.height / 4;

    final localUsers = context.read<SystemBloc>().state.localUsers;
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(builder: (_, state) {
      return DefaultTabController(
        length: _numOfTabs,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: AppBar(
              backgroundColor: themeData.backgroundColor,
              // to hide the shadowed border
              elevation: 0,
              flexibleSpace: SafeArea(
                child: Container(
                  color: themeData.canvasColor,
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    indicatorWeight: 5,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: _getTabs(themeData),
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              state.authentication != null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(
                        left: horizontalPadding,
                        right: horizontalPadding,
                        top: verticalPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 500,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  i18n.loginPage.greeting,
                                  style: const TextStyle(
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  i18n.loginPage.signInHint,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const SizedBox(
                                  height: 120,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 320,
                            child: _formLogin(
                              () => loginAction(
                                  context,
                                  isNullOrEmpty(_selectedUseridController.text)
                                      ? _enteredUseridController.text
                                      : _selectedUseridController.text),
                              i18n,
                              localUsers,
                            ),
                          ),
                        ],
                      ),
                    ),
              const Center(
                child: Text(
                  'About Page',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTab({required String title, required Color color}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        height: 50.0,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  List<Widget> _getTabs(ThemeData theme) {
    return [
      _buildTab(
        title: 'Sign In',
        color: _selectedIndex == 0 ? theme.primaryColor : theme.disabledColor,
      ),
      _buildTab(
        title: 'About',
        color: _selectedIndex == 1 ? theme.primaryColor : theme.disabledColor,
      ),
    ];
  }

  Widget _formLogin(LoginAction loginAction, Language i18n, List<User> localUsers) {
    return Column(
      children: [
        InputDropdown<String>(
          hint: i18n.loginPage.selectUserid,
          controller: _selectedUseridController,
          choices: { for (var e in localUsers) e.userid : e.userid },
          onChanged: (value) {
            if (value.isNotEmpty) {
              _enteredUseridController.text = '';
            }
            setState(() {});
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            i18n.loginPage.orLabel,
            style: const TextStyle(
                color: Colors.black54, fontWeight: FontWeight.bold),
          ),
        ),
        InputText(
          hint: i18n.loginPage.enterUserid,
          controller: _enteredUseridController,
          onChanged: (value) {
            _selectedUseridController.text = '';
            setState(() {});
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Button(
                text: i18n.loginPage.signIn,
                buttonType: ButtonType.primary,
                enabled: _selectedUseridController.text.isNotEmpty || _enteredUseridController.text.isNotEmpty,
                onTap: loginAction,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectedUseridController.dispose();
    _enteredUseridController.dispose();
    super.dispose();
  }
}

loginAction(BuildContext context, String userid) {
  logger.d('Start login with userid = $userid');
  BlocProvider.of<SystemBloc>(context).add(StartLoadingEvent(spinnerColor: Theme.of(context).primaryColor));
  BlocProvider.of<AuthenticationBloc>(context).add(
    LoginEvent(
      userid: userid,
    ),
  );
}
