import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../bloc/authentication_bloc.dart';
import '../bloc/currency_bloc.dart';
import '../bloc/state/site_state.dart';
import '../bloc/system_bloc.dart';
import '../bloc/site_bloc.dart';
import '../bloc/event/authentication_event.dart';
import '../bloc/state/currency_state.dart';
import '../localization/language.dart';
import '../model/constant.dart';
import '../model/system.dart';
import '../model/site.dart';
import '../widget/base_widget.dart';
import '../widget/button.dart';
import '../widget/dialog.dart';
import '../widget/dropdown_button.dart';
import '../widget/input_dropdown.dart';

import '../util/logger.dart';

import 'payment/payment_view_controller.dart' as p;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, BaseWidget {
  late TabController _tabController;
  late TextEditingController _siteController;

  int _selectedIndex = 0;

  final _numOfTabs = 3;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Create TabController for getting the index of current tab
    _tabController = TabController(length: _numOfTabs, vsync: this);
    _siteController = TextEditingController();

    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });

    final siteSearchBloc = BlocProvider.of<SiteSearchBloc>(context);
    if (!siteSearchBloc.withData()) {
      siteSearchBloc.listSite();
    }

    final currencySearchBloc = BlocProvider.of<CurrencySearchBloc>(context);
    if (!currencySearchBloc.withData()) {
      currencySearchBloc.listCurrency();
    }
  }

  @override
  void dispose() {
    _siteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final i18n = Language.of(context);
    final systemBloc = BlocProvider.of<SystemBloc>(context);
    final siteSearchBloc = BlocProvider.of<SiteSearchBloc>(context);
    final authentication = BlocProvider.of<AuthenticationBloc>(context).state.authentication;

    return BlocBuilder<SiteSearchBloc, SiteSearchState>(
      buildWhen: (previous, current) => current.selectedSite != null || previous.siteSelectable != current.siteSelectable,
      builder: (_, siteSearchState) {
        final Map<Site, String> siteMap = {for (var e in siteSearchState.siteList ?? const []) e: e.siteCode};
        if (_siteController.text.isEmpty && siteSearchState.selectedSite != null) {
          _siteController.text = siteSearchState.selectedSite!.siteCode;
        }
        final oldSite = _siteController.text;

        const height = 50.0;
        // Render the content only if both site list and currency list are fetched
        return BlocBuilder<CurrencySearchBloc, CurrencySearchState>(
          builder: (_, currencySearchState) {
            final tabBar = TabBar(
              physics: const NeverScrollableScrollPhysics(),
              isScrollable: true,
              controller: _tabController,
              indicatorWeight: 5,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: _getTabs(i18n, themeData),
            );

            final siteDropdown = InputDropdown<Site>(
              choices: siteMap,
              controller: _siteController,
              initialValue: siteSearchState.selectedSite != null ? [siteSearchState.selectedSite!] : null,
              mandatory: true,
              enabled: siteSearchState.siteSelectable,
              changeConfirmation: (site) => confirmSwitchSite(oldSite, site.first.siteCode, i18n),
              onChanged: (site) => siteSearchBloc.selectSite(site.first.siteCode),
            );

            return siteSearchState.selectedSite == null || currencySearchState.currencyList == null
                ? Container()
                : DefaultTabController(
                    length: _numOfTabs,
                    child: Scaffold(
                      appBar: PreferredSize(
                        preferredSize: const Size.fromHeight(height),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AppBar(
                                backgroundColor: themeData.backgroundColor,
                                // to hide the shadowed border
                                elevation: 0,
                                flexibleSpace: SafeArea(
                                  child: Container(
                                    color: themeData.canvasColor,
                                    child: siteSearchState.siteSelectable
                                        ? tabBar
                                        // Disable change tab
                                        : MouseRegion(
                                            cursor: SystemMouseCursors.forbidden,
                                            child: IgnorePointer(
                                              child: tabBar,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: height,
                                color: themeData.canvasColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 150,
                                      padding: const EdgeInsets.only(
                                        right: 25,
                                      ),
                                      child: siteSearchState.siteSelectable
                                          ? siteDropdown
                                          : MouseRegion(
                                              cursor: SystemMouseCursors.forbidden,
                                              child: siteDropdown,
                                            ),
                                    ),
                                    authentication != null
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              right: 25,
                                            ),
                                            child: Text(
                                              authentication.user.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: themeData.disabledColor,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    _menuButton(
                                      DropDownButton(
                                        text: i18n.changeLanguage,
                                        icon: Icon(Icons.translate, color: themeData.primaryColor,),
                                        iconOnly: true,
                                        actions: [
                                          DropDownButtonAction(() => systemBloc.changeLanguage(languageEn), i18n.english, checked: i18n.languageCode == languageEn),
                                          DropDownButtonAction(() => systemBloc.changeLanguage(languageHant), i18n.traditionChinese, checked: i18n.languageCode == languageHant),
                                        ],
                                      ),
                                    ),
                                    _menuButton(
                                      Button(
                                        buttonType: ButtonType.iconOnly,
                                        icon: Icon(systemBloc.state.themeMode == ThemeMode.light
                                            ? MdiIcons.lightbulbOnOutline
                                            : MdiIcons.lightbulb),
                                        text: systemBloc.state.themeMode == ThemeMode.light
                                            ? i18n.menu.switchToDarkTheme
                                            : i18n.menu.switchToLightTheme,
                                        onTap: () => systemBloc.toggleTheme(),
                                      ),
                                    ),
                                    _menuButton(
                                      Button(
                                        buttonType: ButtonType.iconOnly,
                                        icon: const Icon(Icons.settings),
                                        text: i18n.menu.setting,
                                        onTap: () => systemBloc.showToast('Setting Pressed', ToastType.info),
                                      ),
                                    ),
                                    _menuButton(
                                      Button(
                                        buttonType: ButtonType.iconOnly,
                                        icon: const Icon(Icons.logout),
                                        text: i18n.menu.signOut,
                                        onTap: () => logoutAction(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      body: TabBarView(
                        controller: _tabController,
                        children: const [
                          p.PaymentViewController(),
                          Center(
                            child: Text(
                              'Deal View',
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Deal Monitor View',
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          },
        );
      },
    );
  }

  Widget _buildTab({required String title, required Color color}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        height: 50.0,
        alignment: Alignment.center,
        child: Text(
          title,
          style: defaultTextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Widget> _getTabs(Language i18n, ThemeData theme) {
    const nonSelectedColor = Colors.grey;
    return [
      _buildTab(
        title: i18n.menu.paymentView,
        color: _selectedIndex == 0 ? theme.primaryColor : nonSelectedColor,
      ),
      _buildTab(
        title: i18n.menu.dealView,
        color: _selectedIndex == 1 ? theme.primaryColor : nonSelectedColor,
      ),
      _buildTab(
        title: i18n.menu.dealMonitorView,
        color: _selectedIndex == 2 ? theme.primaryColor : nonSelectedColor,
      ),
    ];
  }

  Widget _menuButton(Widget iconButton) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: iconButton,
    );
  }

  void logoutAction(BuildContext context) {
    logger.d('Start logout user');
    BlocProvider.of<AuthenticationBloc>(context).add(
      LogoutEvent(),
    );
  }

  Future<bool> confirmSwitchSite(String oldSiteCode, String siteCode, Language i18n) async {
    if (oldSiteCode == siteCode) {
      return false;
    }
    else {
      return await showDialog(
        context: context,
        builder: (_) => YesNoDialog(
          title: i18n.paymentPage.confirmSwitchSiteTitle,
          subText: i18n.paymentPage.confirmSwitchSite(oldSiteCode, siteCode),
          yesButtonProp: YesNoDialogButtonProp(
            i18n.yes,
          ),
          noButtonProp: YesNoDialogButtonProp(
            i18n.no,
          ),
        ),
      );
    }
  }
}
