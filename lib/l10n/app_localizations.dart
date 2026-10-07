import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get appTitle;

  /// No description provided for @toolCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get toolCalculator;

  /// No description provided for @toolUnitConverter.
  ///
  /// In en, this message translates to:
  /// **'Unit Converter'**
  String get toolUnitConverter;

  /// No description provided for @toolPercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get toolPercentage;

  /// No description provided for @toolDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get toolDiscount;

  /// No description provided for @toolTip.
  ///
  /// In en, this message translates to:
  /// **'Tip & Split'**
  String get toolTip;

  /// No description provided for @toolLoan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get toolLoan;

  /// No description provided for @toolDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get toolDate;

  /// No description provided for @toolBmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get toolBmi;

  /// No description provided for @sectionCalculators.
  ///
  /// In en, this message translates to:
  /// **'Calculators'**
  String get sectionCalculators;

  /// No description provided for @sectionEveryday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get sectionEveryday;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No calculations yet'**
  String get historyEmpty;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all calculation history?'**
  String get clearHistoryConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @modeBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get modeBasic;

  /// No description provided for @modeScientific.
  ///
  /// In en, this message translates to:
  /// **'Scientific'**
  String get modeScientific;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @enterValues.
  ///
  /// In en, this message translates to:
  /// **'Enter values to see results'**
  String get enterValues;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @unitCatLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get unitCatLength;

  /// No description provided for @unitCatArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get unitCatArea;

  /// No description provided for @unitCatVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get unitCatVolume;

  /// No description provided for @unitCatMass.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get unitCatMass;

  /// No description provided for @unitCatTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get unitCatTemperature;

  /// No description provided for @unitCatSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get unitCatSpeed;

  /// No description provided for @unitCatTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get unitCatTime;

  /// No description provided for @unitCatData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get unitCatData;

  /// No description provided for @unit_millimeter.
  ///
  /// In en, this message translates to:
  /// **'Millimeter'**
  String get unit_millimeter;

  /// No description provided for @unit_centimeter.
  ///
  /// In en, this message translates to:
  /// **'Centimeter'**
  String get unit_centimeter;

  /// No description provided for @unit_meter.
  ///
  /// In en, this message translates to:
  /// **'Meter'**
  String get unit_meter;

  /// No description provided for @unit_kilometer.
  ///
  /// In en, this message translates to:
  /// **'Kilometer'**
  String get unit_kilometer;

  /// No description provided for @unit_inch.
  ///
  /// In en, this message translates to:
  /// **'Inch'**
  String get unit_inch;

  /// No description provided for @unit_foot.
  ///
  /// In en, this message translates to:
  /// **'Foot'**
  String get unit_foot;

  /// No description provided for @unit_yard.
  ///
  /// In en, this message translates to:
  /// **'Yard'**
  String get unit_yard;

  /// No description provided for @unit_mile.
  ///
  /// In en, this message translates to:
  /// **'Mile'**
  String get unit_mile;

  /// No description provided for @unit_nauticalMile.
  ///
  /// In en, this message translates to:
  /// **'Nautical mile'**
  String get unit_nauticalMile;

  /// No description provided for @unit_squareCentimeter.
  ///
  /// In en, this message translates to:
  /// **'Square centimeter'**
  String get unit_squareCentimeter;

  /// No description provided for @unit_squareMeter.
  ///
  /// In en, this message translates to:
  /// **'Square meter'**
  String get unit_squareMeter;

  /// No description provided for @unit_hectare.
  ///
  /// In en, this message translates to:
  /// **'Hectare'**
  String get unit_hectare;

  /// No description provided for @unit_squareKilometer.
  ///
  /// In en, this message translates to:
  /// **'Square kilometer'**
  String get unit_squareKilometer;

  /// No description provided for @unit_squareFoot.
  ///
  /// In en, this message translates to:
  /// **'Square foot'**
  String get unit_squareFoot;

  /// No description provided for @unit_acre.
  ///
  /// In en, this message translates to:
  /// **'Acre'**
  String get unit_acre;

  /// No description provided for @unit_squareMile.
  ///
  /// In en, this message translates to:
  /// **'Square mile'**
  String get unit_squareMile;

  /// No description provided for @unit_milliliter.
  ///
  /// In en, this message translates to:
  /// **'Milliliter'**
  String get unit_milliliter;

  /// No description provided for @unit_liter.
  ///
  /// In en, this message translates to:
  /// **'Liter'**
  String get unit_liter;

  /// No description provided for @unit_cubicMeter.
  ///
  /// In en, this message translates to:
  /// **'Cubic meter'**
  String get unit_cubicMeter;

  /// No description provided for @unit_teaspoon.
  ///
  /// In en, this message translates to:
  /// **'Teaspoon'**
  String get unit_teaspoon;

  /// No description provided for @unit_tablespoon.
  ///
  /// In en, this message translates to:
  /// **'Tablespoon'**
  String get unit_tablespoon;

  /// No description provided for @unit_cup.
  ///
  /// In en, this message translates to:
  /// **'Cup'**
  String get unit_cup;

  /// No description provided for @unit_fluidOunce.
  ///
  /// In en, this message translates to:
  /// **'Fluid ounce'**
  String get unit_fluidOunce;

  /// No description provided for @unit_gallonUs.
  ///
  /// In en, this message translates to:
  /// **'Gallon (US)'**
  String get unit_gallonUs;

  /// No description provided for @unit_gallonUk.
  ///
  /// In en, this message translates to:
  /// **'Gallon (UK)'**
  String get unit_gallonUk;

  /// No description provided for @unit_milligram.
  ///
  /// In en, this message translates to:
  /// **'Milligram'**
  String get unit_milligram;

  /// No description provided for @unit_gram.
  ///
  /// In en, this message translates to:
  /// **'Gram'**
  String get unit_gram;

  /// No description provided for @unit_kilogram.
  ///
  /// In en, this message translates to:
  /// **'Kilogram'**
  String get unit_kilogram;

  /// No description provided for @unit_tonne.
  ///
  /// In en, this message translates to:
  /// **'Tonne'**
  String get unit_tonne;

  /// No description provided for @unit_ounce.
  ///
  /// In en, this message translates to:
  /// **'Ounce'**
  String get unit_ounce;

  /// No description provided for @unit_pound.
  ///
  /// In en, this message translates to:
  /// **'Pound'**
  String get unit_pound;

  /// No description provided for @unit_stone.
  ///
  /// In en, this message translates to:
  /// **'Stone'**
  String get unit_stone;

  /// No description provided for @unit_celsius.
  ///
  /// In en, this message translates to:
  /// **'Celsius'**
  String get unit_celsius;

  /// No description provided for @unit_fahrenheit.
  ///
  /// In en, this message translates to:
  /// **'Fahrenheit'**
  String get unit_fahrenheit;

  /// No description provided for @unit_kelvin.
  ///
  /// In en, this message translates to:
  /// **'Kelvin'**
  String get unit_kelvin;

  /// No description provided for @unit_meterPerSecond.
  ///
  /// In en, this message translates to:
  /// **'Meters per second'**
  String get unit_meterPerSecond;

  /// No description provided for @unit_kilometerPerHour.
  ///
  /// In en, this message translates to:
  /// **'Kilometers per hour'**
  String get unit_kilometerPerHour;

  /// No description provided for @unit_milePerHour.
  ///
  /// In en, this message translates to:
  /// **'Miles per hour'**
  String get unit_milePerHour;

  /// No description provided for @unit_knot.
  ///
  /// In en, this message translates to:
  /// **'Knot'**
  String get unit_knot;

  /// No description provided for @unit_second.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get unit_second;

  /// No description provided for @unit_minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get unit_minute;

  /// No description provided for @unit_hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get unit_hour;

  /// No description provided for @unit_day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get unit_day;

  /// No description provided for @unit_week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get unit_week;

  /// No description provided for @unit_year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get unit_year;

  /// No description provided for @unit_byte.
  ///
  /// In en, this message translates to:
  /// **'Byte'**
  String get unit_byte;

  /// No description provided for @unit_kilobyte.
  ///
  /// In en, this message translates to:
  /// **'Kilobyte'**
  String get unit_kilobyte;

  /// No description provided for @unit_megabyte.
  ///
  /// In en, this message translates to:
  /// **'Megabyte'**
  String get unit_megabyte;

  /// No description provided for @unit_gigabyte.
  ///
  /// In en, this message translates to:
  /// **'Gigabyte'**
  String get unit_gigabyte;

  /// No description provided for @unit_terabyte.
  ///
  /// In en, this message translates to:
  /// **'Terabyte'**
  String get unit_terabyte;

  /// No description provided for @pctOfTitle.
  ///
  /// In en, this message translates to:
  /// **'What is X% of Y?'**
  String get pctOfTitle;

  /// No description provided for @pctWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'X is what percent of Y?'**
  String get pctWhatTitle;

  /// No description provided for @pctChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Percentage change from X to Y'**
  String get pctChangeTitle;

  /// No description provided for @pctIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get pctIncrease;

  /// No description provided for @pctDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get pctDecrease;

  /// No description provided for @originalPrice.
  ///
  /// In en, this message translates to:
  /// **'Original price'**
  String get originalPrice;

  /// No description provided for @discountPercent.
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get discountPercent;

  /// No description provided for @taxPercent.
  ///
  /// In en, this message translates to:
  /// **'Tax (%)'**
  String get taxPercent;

  /// No description provided for @youSave.
  ///
  /// In en, this message translates to:
  /// **'You save'**
  String get youSave;

  /// No description provided for @taxAmount.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get taxAmount;

  /// No description provided for @finalPrice.
  ///
  /// In en, this message translates to:
  /// **'Final price'**
  String get finalPrice;

  /// No description provided for @billAmount.
  ///
  /// In en, this message translates to:
  /// **'Bill amount'**
  String get billAmount;

  /// No description provided for @tipPercent.
  ///
  /// In en, this message translates to:
  /// **'Tip (%)'**
  String get tipPercent;

  /// No description provided for @numberOfPeople.
  ///
  /// In en, this message translates to:
  /// **'Number of people'**
  String get numberOfPeople;

  /// No description provided for @tipAmount.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tipAmount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @perPerson.
  ///
  /// In en, this message translates to:
  /// **'Total per person'**
  String get perPerson;

  /// No description provided for @tipPerPerson.
  ///
  /// In en, this message translates to:
  /// **'Tip per person'**
  String get tipPerPerson;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'Loan amount'**
  String get loanAmount;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Annual interest rate (%)'**
  String get interestRate;

  /// No description provided for @termMonths.
  ///
  /// In en, this message translates to:
  /// **'Term (months)'**
  String get termMonths;

  /// No description provided for @repaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Repayment method'**
  String get repaymentMethod;

  /// No description provided for @equalInstallment.
  ///
  /// In en, this message translates to:
  /// **'Equal installments'**
  String get equalInstallment;

  /// No description provided for @equalPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Equal principal'**
  String get equalPrincipal;

  /// No description provided for @monthlyPayment.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment'**
  String get monthlyPayment;

  /// No description provided for @firstPayment.
  ///
  /// In en, this message translates to:
  /// **'First payment'**
  String get firstPayment;

  /// No description provided for @lastPayment.
  ///
  /// In en, this message translates to:
  /// **'Last payment'**
  String get lastPayment;

  /// No description provided for @totalPayment.
  ///
  /// In en, this message translates to:
  /// **'Total payment'**
  String get totalPayment;

  /// No description provided for @totalInterest.
  ///
  /// In en, this message translates to:
  /// **'Total interest'**
  String get totalInterest;

  /// No description provided for @paymentSchedule.
  ///
  /// In en, this message translates to:
  /// **'Payment schedule'**
  String get paymentSchedule;

  /// No description provided for @colMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get colMonth;

  /// No description provided for @colPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get colPayment;

  /// No description provided for @colPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get colPrincipal;

  /// No description provided for @colInterest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get colInterest;

  /// No description provided for @colBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get colBalance;

  /// No description provided for @dateDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get dateDifference;

  /// No description provided for @dateAddSubtract.
  ///
  /// In en, this message translates to:
  /// **'Add / Subtract'**
  String get dateAddSubtract;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeks;

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'Total days'**
  String get totalDays;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @subtract.
  ///
  /// In en, this message translates to:
  /// **'Subtract'**
  String get subtract;

  /// No description provided for @resultDate.
  ///
  /// In en, this message translates to:
  /// **'Result date'**
  String get resultDate;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;

  /// No description provided for @yourBmi.
  ///
  /// In en, this message translates to:
  /// **'Your BMI'**
  String get yourBmi;

  /// No description provided for @bmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal weight'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiObese;

  /// No description provided for @bmiNote.
  ///
  /// In en, this message translates to:
  /// **'Adult categories according to WHO. Not medical advice.'**
  String get bmiNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'ja',
    'ko',
    'pt',
    'ru',
    'tr',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
