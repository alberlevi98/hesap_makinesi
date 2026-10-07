/// Unit conversion data. Each unit converts to and from its category's base
/// unit; most are linear factors, temperature uses offsets.
enum UnitCategory { length, area, volume, mass, temperature, speed, time, data }

class Unit {
  const Unit(this.id, this.symbol, this.factor, {this.offset = 0});

  /// Stable id, also used as the localization key suffix.
  final String id;
  final String symbol;

  /// value_in_base = value * factor + offset
  final double factor;
  final double offset;

  double toBase(double v) => v * factor + offset;
  double fromBase(double v) => (v - offset) / factor;
}

const Map<UnitCategory, List<Unit>> units = {
  UnitCategory.length: [
    Unit('millimeter', 'mm', 0.001),
    Unit('centimeter', 'cm', 0.01),
    Unit('meter', 'm', 1),
    Unit('kilometer', 'km', 1000),
    Unit('inch', 'in', 0.0254),
    Unit('foot', 'ft', 0.3048),
    Unit('yard', 'yd', 0.9144),
    Unit('mile', 'mi', 1609.344),
    Unit('nauticalMile', 'nmi', 1852),
  ],
  UnitCategory.area: [
    Unit('squareCentimeter', 'cm²', 0.0001),
    Unit('squareMeter', 'm²', 1),
    Unit('hectare', 'ha', 10000),
    Unit('squareKilometer', 'km²', 1e6),
    Unit('squareFoot', 'ft²', 0.09290304),
    Unit('acre', 'ac', 4046.8564224),
    Unit('squareMile', 'mi²', 2589988.110336),
  ],
  UnitCategory.volume: [
    Unit('milliliter', 'mL', 0.001),
    Unit('liter', 'L', 1),
    Unit('cubicMeter', 'm³', 1000),
    Unit('teaspoon', 'tsp', 0.00492892159375),
    Unit('tablespoon', 'tbsp', 0.01478676478125),
    Unit('cup', 'cup', 0.2365882365),
    Unit('fluidOunce', 'fl oz', 0.0295735295625),
    Unit('gallonUs', 'gal (US)', 3.785411784),
    Unit('gallonUk', 'gal (UK)', 4.54609),
  ],
  UnitCategory.mass: [
    Unit('milligram', 'mg', 0.000001),
    Unit('gram', 'g', 0.001),
    Unit('kilogram', 'kg', 1),
    Unit('tonne', 't', 1000),
    Unit('ounce', 'oz', 0.028349523125),
    Unit('pound', 'lb', 0.45359237),
    Unit('stone', 'st', 6.35029318),
  ],
  UnitCategory.temperature: [
    Unit('celsius', '°C', 1),
    Unit('fahrenheit', '°F', 5 / 9, offset: -32 * 5 / 9),
    Unit('kelvin', 'K', 1, offset: -273.15),
  ],
  UnitCategory.speed: [
    Unit('meterPerSecond', 'm/s', 1),
    Unit('kilometerPerHour', 'km/h', 1 / 3.6),
    Unit('milePerHour', 'mph', 0.44704),
    Unit('knot', 'kn', 1852 / 3600),
  ],
  UnitCategory.time: [
    Unit('second', 's', 1),
    Unit('minute', 'min', 60),
    Unit('hour', 'h', 3600),
    Unit('day', 'd', 86400),
    Unit('week', 'wk', 604800),
    Unit('year', 'yr', 31557600), // Julian year, 365.25 days
  ],
  UnitCategory.data: [
    Unit('byte', 'B', 1),
    Unit('kilobyte', 'KB', 1024),
    Unit('megabyte', 'MB', 1048576),
    Unit('gigabyte', 'GB', 1073741824),
    Unit('terabyte', 'TB', 1099511627776),
  ],
};

double convert(double value, Unit from, Unit to) => to.fromBase(from.toBase(value));
