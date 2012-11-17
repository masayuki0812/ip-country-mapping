Generate mappings between IP ranges and countries.

## How to use

First of all, initialize module:

    $ ./bin/init

Then, you can generate mappings:

    $ ./bin/generate

## Information Sources

This module downloads NIC information from each registries below:

* ARIN
* RIPE
* APNIC
* LACNIC
* AFRINIC

And countries information from ISO.

URLs for each information are written in `./conf/url_*`