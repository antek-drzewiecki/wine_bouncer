Changelog
=========

## Unreleased

## 1.1.0
* [#63](https://github.com/antek-drzewiecki/wine_bouncer/pull/65): Auth strategies could coexist being specified in an array. Grape support restricted to 0.15 - 0.18. Code refactoring. Swagger 2.0 auth strategy implementation started. 

## 1.0.1
* [#65](https://github.com/antek-drzewiecki/wine_bouncer/pull/65): Support for Doorkeeper 4.1 and 4.2. Thanks @daveallie

## 1.0
* [#61](https://github.com/antek-drzewiecki/wine_bouncer/pull/61): Travis cleanup Rails 4.1.x is EOL. Ruby 2.0 is unsupported.
* [#60](https://github.com/antek-drzewiecki/wine_bouncer/pull/60): Rails 5, Doorkeeper 4, grape 0.16.2 support. Thanks @texpert

## 0.5.1
* [#57](https://github.com/antek-drzewiecki/wine_bouncer/pull/57): Removed locks for doorkeeper
* [#56](https://github.com/antek-drzewiecki/wine_bouncer/pull/56): Grape 0.14.x support, removed locks.
* Tested against ruby 2.3.0

## 0.5.0
* [#50](https://github.com/antek-drzewiecki/wine_bouncer/pull/50): Grape 0.13.x support
* [#48](https://github.com/antek-drzewiecki/wine_bouncer/pull/48): Bind Doorkeeper error response into WineBouncer errors
* [#47](https://github.com/antek-drzewiecki/wine_bouncer/pull/47): Doorkeeper 3.0.x support

## 0.4.0
* [#42](https://github.com/antek-drzewiecki/wine_bouncer/pull/42): Added support for Doorkeeper 2.2
* [#41](https://github.com/antek-drzewiecki/wine_bouncer/pull/41): Added support for Grape 0.12.0, Removed support for Grape 0.8 and 0.9 (though they still work).
* [#39](https://github.com/antek-drzewiecki/wine_bouncer/pull/39): Add option to disable WineBouncer conditionally. Thanks @Fryie .

## 0.3.1
* [#31](https://github.com/antek-drzewiecki/wine_bouncer/pull/31): Improves support for default scopes trough DSL.
* [#30](https://github.com/antek-drzewiecki/wine_bouncer/pull/30): Restricted grape dependencies to the next minor level of grape.
* [#29](https://github.com/antek-drzewiecki/wine_bouncer/pull/29): Doorkeepers dependencies are restricted to minor levels. Thanks @nickcharlton
* [#27](https://github.com/antek-drzewiecki/wine_bouncer/pull/27): Fixes DSL default and protected strategy. Fixes #24 and #26.

## 0.3.0
* [#21](https://github.com/antek-drzewiecki/wine_bouncer/pull/21): Added an Easy DSL for WineBouncer. Thanks @masarakki .
* [#23](https://github.com/antek-drzewiecki/wine_bouncer/pull/23): Added support for Doorkeeper 2.1.1 and refactored strategies.

## 0.2.2
* [#17](https://github.com/antek-drzewiecki/wine_bouncer/pull/17): Added a new protected strategy. Thanks @whatasunnyday .

## 0.2.1
* [#12](https://github.com/antek-drzewiecki/wine_bouncer/pull/12): Added a rails generator to generate the WineBouncer configuration file. Thanks @whatasunnyday.
* [#7](https://github.com/antek-drzewiecki/wine_bouncer/pull/7): Added support for Doorkeeper 2.0.0 and 2.0.1. Thanks @whatasunnyday .

## 0.2.0
* [#4](https://github.com/antek-drzewiecki/wine_bouncer/pull/4): Support for newer versions of grape ( > 0.8 ).
* [#6](https://github.com/antek-drzewiecki/wine_bouncer/pull/6): Added the option to configure the resource owner.
