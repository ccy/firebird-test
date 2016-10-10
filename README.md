Introduction
==

Firebird-test is a DUnitX test project to test bugs/issues in Firebird.  The project is written in Delphi/Object.  The project using [Firebird - New Object Oriented API](http://firebirdsql.org/file/documentation/release_notes/html/en/3_0/rnfb30-apiods-api.html) to access services available in Firebird.

The project requires some additional library to build:

* [DUnitX](https://github.com/VSoftTechnologies/DUnitX): Latest version of [RAD Studio](https://www.embarcadero.com/products/rad-studio) shall come with DUnitX.

* [Firebird.pas]: This is the firebird OO api interfaces implemented by Object Pascal.  For example, [Firebird 3.0 firebird.pas](https://raw.githubusercontent.com/FirebirdSQL/firebird/B3_0_Release/src/include/gen/Firebird.pas)