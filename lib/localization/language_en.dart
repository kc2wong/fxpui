import 'language.dart';
import '../model/payment.dart';
import '../model/constant.dart';
import '../util/string_util.dart';

class LanguageEn extends Language {

  final _menu = _MenuEn();
  final _loginPage = _LoginPageEn();
  final _paymentPage = _PaymentPageEn();
  final _accountPage = _AccountPageEn();

  final errorMessageMap = {
    'INVALID_CREDIT_DEBIT_AMOUNT' : 'Invalid Amount - Must be less than or equal to {}',
    'ERR_INVALID_FX_REF' : 'Invalid FxRef [{}] - For Error Simulation'
  };

  @override
  String get appName => 'FX+';

  @override
  String get languageCode => languageEn;

  @override
  String get english => 'English';

  @override
  String get traditionChinese => '繁體中文';

  @override
  String get welcomeTitle => 'Welcome to FX+';

  @override
  String get welcomeSubtitle => 'Sign In by selecting or entering your userid';

  @override
  String get add => 'Add';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get ccy => 'CCY';

  @override
  String get amount => 'Amount';

  @override
  String get fromAmount => 'From Amount';

  @override
  String get toAmount => 'To Amount';

  @override
  String get reset => 'Reset';

  @override
  String get refresh => 'Refresh';

  @override
  String get export => 'Export';

  @override
  String get searchCriteria => 'Select or enter search criteria';

  @override
  String get submit => 'Submit';

  @override
  String get collapseSearchPanel => 'Collapse Search Panel';

  @override
  String get expandSearchPanel => 'Expand Search Panel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get next => 'Next';

  @override
  String get cancel => 'Cancel';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get previous => 'Previous';

  @override
  String lastRefreshAt(DateTime dateTime) {
    return 'Last Refreshed At : ${dateTimeFormat.format(dateTime)}';
  }

  @override
  String getErrorMessage(String errorCode, List<String> errorParam) {
    return errorMessageMap.containsKey(errorCode) ? interpolate(errorMessageMap[errorCode]!, errorParam) : errorCode;
  }

  @override
  Menu get menu => _menu;

  @override
  LoginPage get loginPage => _loginPage;

  @override
  PaymentPage get paymentPage => _paymentPage;

  @override
  AccountPage get accountPage => _accountPage;

}

class _MenuEn extends Menu {
  @override
  String get about => 'About';

  @override
  String get dealMonitorView => 'Deal Monitor';

  @override
  String get dealView => 'Deal';

  @override
  String get paymentView => 'Payment';

  @override
  String get signIn => 'Sign In';

  @override
  String get setting => 'Setting';

  @override
  String get switchToDarkTheme => 'Toggle Dark Theme';

  @override
  String get switchToLightTheme => 'Toggle Light Theme';

  @override
  String get signOut => 'Sign Out';
}

class _LoginPageEn extends LoginPage {
  @override
  String get enterUserid => 'Enter userid';

  @override
  String get selectUserid => 'Select userid';

  @override
  String get signIn => 'Sign In';

  @override
  String get orLabel => 'OR';

  @override
  String get greeting => 'Welcome to FX+';

  @override
  String get signInHint => 'Sign In by selecting or entering your userid';
}

class _PaymentPageEn extends PaymentPage {
  static Map<EnrichmentRequestStatus, String> enrichmentStatusDescriptionMap = {
    EnrichmentRequestStatus.initial: 'New',
    EnrichmentRequestStatus.started: 'Started',
    EnrichmentRequestStatus.paired: 'Paired',
    EnrichmentRequestStatus.submitted: 'Submitted',
    EnrichmentRequestStatus.pendingFxt: 'Pending FXT',
    EnrichmentRequestStatus.pendingApproval: 'Pending Approval',
    EnrichmentRequestStatus.failed: 'Failed',
    EnrichmentRequestStatus.rejected: 'Rejected',
  };

  @override
  String get listPayment => 'List Payment';

  @override
  String get viewPayment => 'View Payment';

  @override
  String get newPayment => 'New Payment';

  @override
  String get editPayment => 'Edit Payment';

  @override
  String get cancelPayment => 'Cancel Payment';

  @override
  String get submitPayment => 'Submit Payment';

  @override
  String get requestQuote => 'Request Quote';

  @override
  String get direction => 'Direction';

  @override
  String get incoming => 'Incoming';

  @override
  String get outgoing => 'Outgoing';

  @override
  String get account => 'Account';

  @override
  String get accountDetail => 'Account Detail';

  @override
  String get account1 => 'Account 1';

  @override
  String get account2 => 'Account 2';

  @override
  String accountName(String? name) {
    return name != null ? 'Ext. Account Name : $name' : '';
  }

  @override
  String accountAlert(String? alert) {
    return alert != null ? 'Alert : $alert' : '';
  }

  @override
  String get instructionId => 'Instruction Id';

  @override
  String get requestStatus => 'Request Status';

  @override
  String get executeDate => 'Execute Date';

  @override
  String get executeDateFromTo => 'Execute Date (From - To)';

  @override
  String get initiatedBy => 'Initiated By';

  @override
  String get bankBuy => 'Bank Buy (Debit)';

  @override
  String get bankSell => 'Bank Sell (Credit)';

  @override
  String get fxRef => 'FX Ref';

  @override
  String get remainingCcy => 'Remaining CCY';

  @override
  String get remainingAmount => 'Remaining Amount';

  @override
  String get dealCcy => 'Deal CCY';

  @override
  String get dealAmount => 'Deal Amount';

  @override
  String get contraCcy => 'Contra CCY';

  @override
  String get contraAmount => 'Contra Amount';

  @override
  String get traderComment => 'Trader Comment';

  @override
  String get ccyPair => 'CCY Pair';

  @override
  String get rate => 'Rate';

  @override
  String get product => 'Product';

  @override
  String get valueDate => 'Value Date';

  @override
  String get fxt => 'FXT';

  @override
  String get fxd => 'FXD';

  @override
  String get populate => 'Populate';

  @override
  String get matching => 'Matching';

  @override
  String get booking => 'Booking';

  @override
  String get start => 'Start';

  @override
  String getEnrichmentStatusDescription(EnrichmentRequestStatus status) {
    return enrichmentStatusDescriptionMap[status] ?? status.name;
  }

  @override
  EnrichmentRequestStatus? getEnrichmentStatus(String description) {
    return enrichmentStatusDescriptionMap.entries.firstWhere((element) => element.value == description).key;
  }

  @override
  String get newBooking => 'New Booking';

  @override
  String get matchPayment => 'Match Payment';

  @override
  String get confirmBooking => 'Confirm to book new deal ?';

  @override
  String get confirmSwitchSiteTitle => 'Switch Site';

  @override
  String confirmSwitchSite(String oldSite, String newSite) => 'Do you want to switch from $oldSite to $newSite ?';

  @override
  String confirmMatching(String fxRef) => 'Confirm to match with deal $fxRef ?';

  @override
  String get confirmCancelPayment => 'Confirm to cancel the payment ?';

  @override
  String get matchingRequestSubmitted => 'Matching request submitted';

  @override
  String get bookingRequestSubmitted => 'Booking request submitted';

  @override
  String get cancelRequestSubmitted => 'Cancel request submitted';

  @override
  String get chooseYourAction => 'Choose Your Action';

  @override
  String get enrichmentResult => 'Enrichment Result';

  @override
  String get paymentDetail => 'Payment Detail';

  @override
  String get memos => 'Memos';

}

class _AccountPageEn extends AccountPage {
  @override
  String get fxAccount => 'FX Account';

  @override
  String get name => 'Name';

  @override
  String get ref => 'Ref';

  @override
  String get status => 'Status';

  @override
  String get type => 'Type';
}
