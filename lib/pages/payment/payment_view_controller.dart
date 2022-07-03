import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/account_bloc.dart';
import '../../bloc/enrichment_request_bloc.dart';
import '../../bloc/enrichment_request_search_bloc.dart';
import '../../bloc/site_bloc.dart';
import '../../bloc/state/enrichment_request_state.dart';
import '../../bloc/state/account_state.dart';
import '../../bloc/system_bloc.dart';
import '../../localization/language.dart';
import '../../model/payment.dart';
import '../../model/system.dart';
import '../../util/logger.dart';
import '../../widget/breadcrumb.dart';
import '../../widget/button.dart';
import '../../widget/dropdown_button.dart';
import 'payment_detail_page.dart';
import 'payment_edit_page.dart';
import 'payment_listing_page.dart';
import 'payment_submit_page.dart';
import 'account_detail_page.dart';
import 'utils.dart';

// Control navigation of payment view
class PaymentViewController extends StatefulWidget {
  const PaymentViewController({Key? key}) : super(key: key);

  @override
  State<PaymentViewController> createState() => _PaymentViewControllerState();
}

class _PaymentViewControllerState extends State<PaymentViewController> with SingleTickerProviderStateMixin {
  late _PaymentNavigator paymentNavigator;

  late _PaymentViewType _currentViewType;
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _currentViewType = _PaymentViewType.notApplicable;

    final _breadcrumbItems = <BreadcrumbItem<_PaymentViewType>>[
      BreadcrumbItem(() {
        final i18n = Language.of(context);
        return i18n.menu.paymentView;
      }, _PaymentViewType.notApplicable),
    ];

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            if (paymentNavigator.target != null) {
              _currentViewType = paymentNavigator.target!;
              _controller.reset();
              setState(() {});
            }
          }
        },
      );
    _animation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    paymentNavigator = _PaymentNavigator(_breadcrumbItems, _controller);
    paymentNavigator.pushListPayment(
      () => BlocProvider.of<EnrichmentRequestBloc>(context).clearEnrichmentRequest(),
      () => Language.of(context).paymentPage.listPayment,
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = Language.of(context);
    final siteSearchBloc = BlocProvider.of<SiteSearchBloc>(context);
    final fxAccountSearchBloc = BlocProvider.of<FxAccountSearchBloc>(context);
    final systemBloc = BlocProvider.of<SystemBloc>(context);
    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);

    Widget? mainPane;
    switch (_currentViewType) {
      case _PaymentViewType.editPayment:
        siteSearchBloc.disableSelectSite();
        mainPane = const PaymentEditPage(
        );
        break;
      case _PaymentViewType.submitPayment:
        siteSearchBloc.disableSelectSite();
        mainPane = const PaymentSubmitPage(
        );
        break;
      case _PaymentViewType.viewPayment:
        siteSearchBloc.disableSelectSite();
        mainPane = PaymentDetailPage(
          enrichmentRequestBloc.state.enrichmentRequest!
        );
        break;
      case _PaymentViewType.listPayment:
        siteSearchBloc.enableSelectSite();
        mainPane = const PaymentListingPage();
        break;
      case _PaymentViewType.viewAccount:
        siteSearchBloc.disableSelectSite();
        mainPane = AccountDetailPage(
          fxAccountSearchBloc.state.selectedFxAccount!,
        );
        break;
      default:
        mainPane = const SizedBox.shrink();
        break;
    }

    final child = SlideTransition(
      position: _animation,
      transformHitTests: true,
      child: mainPane,
    );

    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 40,
                // color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<FxAccountSearchBloc, FxAccountSearchState>(
                        listenWhen: (previous, current) => previous.selectedFxAccount != current.selectedFxAccount,
                        listener: (_, state) {
                          if (state.selectedFxAccount != null) {
                            paymentNavigator.pushViewAccount(() => i18n.paymentPage.accountDetail);
                          }
                          else {
                            paymentNavigator.popLast();
                          }
                        },
                      ),
                      BlocListener<EnrichmentRequestBloc, EnrichmentRequestState>(
                        listenWhen: (previous, current) =>
                            previous.isLoading() != current.isLoading() || previous.transactionStatus != current.transactionStatus || previous.errorCode != current.errorCode,
                        listener: (_, state) {
                          if (state.isLoading()) {
                            systemBloc.startLoading();
                          }
                          else {
                            systemBloc.stopLoading();
                            final enrichmentRequest = state.enrichmentRequest;
                            logger.d('transactionStatus = ${state.transactionStatus} enrichmentRequest = $enrichmentRequest');
                            if (state.errorCode != null) {
                              systemBloc.showToast(i18n.getErrorMessage(state.errorCode!, state.errorParams), ToastType.error);
                            }
                            if (enrichmentRequest != null) {
                              if (state.transactionStatus == TransactionStatus.edit) {
                                paymentNavigator.popToEditPayment(() => i18n.paymentPage.editPayment);
                              }
                              else if (state.transactionStatus == TransactionStatus.finishCreate || state.transactionStatus == TransactionStatus.finishUpdate) {
                                paymentNavigator.pushSubmitPayment(() => i18n.paymentPage.submitPayment);
                              }
                              else if (state.transactionStatus == TransactionStatus.finishGetOne) {
                                final enrichmentRequestStatus = state.enrichmentRequest?.status;
                                if (enrichmentRequestStatus == EnrichmentRequestStatus.started) {
                                  paymentNavigator.pushSubmitPayment(() => i18n.paymentPage.submitPayment);
                                }
                                else {
                                  paymentNavigator.pushViewPayment(() => i18n.paymentPage.viewPayment);
                                }
                              }
                              else if (state.transactionStatus == TransactionStatus.finishCancel) {
                                systemBloc.showToast(i18n.paymentPage.cancelRequestSubmitted, ToastType.success);
                                paymentNavigator.popToListPayment();
                              }
                              else if (state.transactionStatus == TransactionStatus.finishSubmit) {
                                systemBloc.showToast(state.dealToMatch != null ? i18n.paymentPage.matchingRequestSubmitted : i18n.paymentPage.bookingRequestSubmitted, ToastType.success);
                                paymentNavigator.popToListPayment();
                              }
                            }
                            else {
                              if (state.transactionStatus == TransactionStatus.edit) {
                                paymentNavigator.pushEditPayment(() => i18n.paymentPage.newPayment);
                              } else {
                                paymentNavigator.popToListPayment();
                              }
                            }
                          }
                        },
                      ),
                    ],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // BreadCrumb
                        BreadCrumb(
                          items: paymentNavigator.breadcrumbItems,
                        ),
                        _currentViewType != _PaymentViewType.listPayment
                            ? const SizedBox.shrink()
                            : _createActionButtonBar(),
                      ],
                    ),
                  ),
                ),
                // color: Colors.green,
              ),
              const Divider(),
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // New Payment + Request Quotation + Refresh + Download
  Widget _createActionButtonBar() {

    final i18n = Language.of(context);
    final siteSearchBloc = BlocProvider.of<SiteSearchBloc>(context);
    final fxAccountSearchBloc = BlocProvider.of<FxAccountSearchBloc>(context);
    final systemBloc = BlocProvider.of<SystemBloc>(context);
    final enrichmentRequestBloc = BlocProvider.of<EnrichmentRequestBloc>(context);
    final enrichmentRequestSearchBloc = BlocProvider.of<EnrichmentRequestSearchBloc>(context);

    return Row(
      children: <Widget>[
        _addRightPadding(
          Button(
            text: i18n.paymentPage.newPayment,
            icon: const Icon(Icons.add),
            buttonType: ButtonType.primary,
            onTap: () {
              // Clear the account
              fxAccountSearchBloc.resetState();
              // Initialize payment
              enrichmentRequestBloc.initializeEnrichmentRequest(siteSearchBloc.state.selectedSite!.siteCode, numberOfInputAccount);
            },
          ),
        ),
        _addRightPadding(
          Button(
            text: i18n.paymentPage.requestQuote,
            icon: const Icon(Icons.add_chart),
            onTap: () => systemBloc.showToast('Request Quote Pressed', ToastType.info),
          ),
        ),
        _addRightPadding(
          Button(
            text: i18n.refresh,
            icon: const Icon(Icons.refresh),
            buttonType: ButtonType.iconOnly,
            onTap: () => enrichmentRequestSearchBloc.refreshData(
                refreshSuccessMessage: 'Data refreshed successfully',
                forceRefresh: true
            ),
          ),
        ),
        _addRightPadding(
          DropDownButton(
            text: i18n.export,
            icon: const Icon(Icons.file_download),
            iconOnly: true,
            actions: [
              DropDownButtonAction(() => systemBloc.showToast('Export Current Page Pressed', ToastType.info), 'Current Page'),
              DropDownButtonAction(() => systemBloc.showToast('Export All Pages Pressed', ToastType.info), 'All Pages'),
            ],
            // choices: {
            //   'Current Page': () {
            //     systemBloc.showToast('Export Current Page Pressed', ToastType.info);
            //   },
            //   'All Pages': () {
            //     systemBloc.showToast('Export All Pages Pressed', ToastType.info);
            //   },
            // },
          ),
        ),
      ],
    );
  }

  Widget _addRightPadding(Widget widget) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8.0,
      ),
      child: widget,
    );
  }
}

enum _PaymentViewType {
  notApplicable,
  listPayment,
  editPayment,
  submitPayment,
  viewPayment,
  viewAccount,
}

class _PaymentNavigator {
  List<BreadcrumbItem<_PaymentViewType>> breadcrumbItems;
  AnimationController controller;
  _PaymentViewType? target;

  _PaymentNavigator(this.breadcrumbItems, this.controller);

  void pushListPayment(VoidCallback onTap, CaptionProvider captionProvider) {
    if (breadcrumbItems.isEmpty || breadcrumbItems.last.metaData != _PaymentViewType.listPayment) {
      breadcrumbItems.add(
        BreadcrumbItem(
          captionProvider,
          _PaymentViewType.listPayment,
          onItemTap: (item) {
            onTap();
            popToListPayment();
          },
        ),
      );
      target = _PaymentViewType.listPayment;
      controller.forward();
    }
  }

  void pushEditPayment(CaptionProvider captionProvider) {
    if (breadcrumbItems.isEmpty || breadcrumbItems.last.metaData != _PaymentViewType.editPayment) {
      breadcrumbItems.add(
        BreadcrumbItem(
          captionProvider,
          _PaymentViewType.editPayment,
          onItemTap: (item) => popToEditPayment(captionProvider),
        ),
      );
      target = _PaymentViewType.editPayment;
      controller.forward();
    }
  }

  void pushViewPayment(CaptionProvider captionProvider) {
    if (breadcrumbItems.isEmpty || breadcrumbItems.last.metaData != _PaymentViewType.viewPayment) {
      breadcrumbItems.add(
        BreadcrumbItem(
          captionProvider,
          _PaymentViewType.viewPayment,
        ),
      );
      target = _PaymentViewType.viewPayment;
      controller.forward();
    }
  }

  void pushSubmitPayment(CaptionProvider captionProvider) {
    if (breadcrumbItems.isEmpty || breadcrumbItems.last.metaData != _PaymentViewType.submitPayment) {
      breadcrumbItems.add(
        BreadcrumbItem(
          captionProvider,
          _PaymentViewType.submitPayment,
        ),
      );
      target = _PaymentViewType.submitPayment;
      controller.forward();
    }
  }

  void pushViewAccount(CaptionProvider captionProvider) {
    if (breadcrumbItems.isEmpty || breadcrumbItems.last.metaData != _PaymentViewType.viewAccount) {
      breadcrumbItems.add(
        BreadcrumbItem(
          captionProvider,
          _PaymentViewType.viewAccount,
        ),
      );
      target = _PaymentViewType.viewAccount;
      controller.forward();
    }
  }

  void popLast() {
    if (breadcrumbItems.length > 1) {
      breadcrumbItems.removeAt(breadcrumbItems.length - 1);
      target = breadcrumbItems.last.metaData;
      if (target != null) {
        controller.forward();
      }
    }
  }

  void popToEditPayment(CaptionProvider captionProvider) {
    final idx = breadcrumbItems.indexWhere((element) => element.metaData == _PaymentViewType.editPayment);
    if (idx >= 0 && idx != breadcrumbItems.length - 1) {
      breadcrumbItems.removeRange(idx + 1, breadcrumbItems.length);
      // breadcrumbItems.add(BreadcrumbItem(captionProvider, _PaymentViewType.editPayment));
      target = _PaymentViewType.editPayment;
      controller.forward();
    }
  }

  void popToListPayment() {
    final idx = breadcrumbItems.indexWhere((element) => element.metaData == _PaymentViewType.listPayment);
    if (idx >= 0 && idx != breadcrumbItems.length - 1) {
      breadcrumbItems.removeRange(idx + 1, breadcrumbItems.length);
      target = _PaymentViewType.listPayment;
      controller.forward();
    }
  }

}