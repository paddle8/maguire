# Maguire [![Build Status](https://next.travis-ci.org/paddle8/maguire.svg)](https://next.travis-ci.org/paddle8/maguire) [![Code Climate](https://codeclimate.com/github/paddle8/maguire.png)](https://codeclimate.com/github/paddle8/maguire) [![Code Climate](https://codeclimate.com/github/paddle8/maguire/coverage.png)](https://codeclimate.com/github/paddle8/maguire)

Maguire handles formatting currencies in various locales with capabilities to layer custom data sets on top.

## Adding your own locales

To add your own locale information, point Maguire to the directory in your project where the locale files will be:

```ruby
Maguire.locale_paths << "path/to/my/locales"
```

If you're adding a customization for French-speaking Canadians, the JSON file should be named `fr_CA.json`.

The file should *at least* have a layouts hash for providing information on how to format the currencies. The layout format should always be in US Dollars (using the code `USD`, and symbol `$`) and use the monetary value of `1234567890.12`. In addition, there's an optional layout if there's a custom format when there's no minor units (cf. '$1.-"). The monetary value for the zero layout is `1.00`.

So a layout for use in Quebec might be:

```json
{
  "layouts": {
    "positive": "1.234.567.890,12 $",
    "negative": "-1.234.567.890,12 $"
  }
}
```

Note: positive and negative layouts must be provided.

## Adding your own currencies

Adding your own custom currencies works just like adding your own locales; point Maguire to the directory where your currency files are:

```ruby
Maguire.data_paths << "path/to/my/currencies"
```

If you're adding Bitcoin to your project, the JSON file should be named `BTC`. (This corresponds to the lookup code used by the currency parameter passed into the `format` method.)

Currency files are required to have a `"symbol"` (and `"symbol_html"` if needed), `"code"`, and `"minor_units"` values. (`"minor_units"` says how many minor units make up a major unit in the currency. If there is no minor unit, this should be 0.)

A file for the Bitcoin currency would look like:

```json
{
  "name": "Bitcoin",
  "code": "BTC",
  "symbol": "฿",
  "symbol_html": "&#3647;",
  "minor_units": 8
}
```

After doing this, you can format your Bitcoins:

```ruby
Maguire.format({ value: 400_000_00000000, currency: "BTC" }, { strip_insignificant_zeros: true })
# ฿400,000
```
