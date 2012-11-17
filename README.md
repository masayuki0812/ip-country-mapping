Generate mappings between IP ranges and countries.

## How to use

First of all, initialize module:

    $ ./bin/init

Then, you can generate mappings:

    $ ./bin/generate

## Output

Format:

    <start_ip>,<end_ip>,<country_code>,<country_name>

Example:

    3.0.0.0,4.255.255.255,US,UNITED STATES
    6.0.0.0,9.255.255.255,US,UNITED STATES
    11.0.0.0,13.255.255.255,US,UNITED STATES
    15.0.0.0,23.15.255.255,US,UNITED STATES
    ...

## Information Sources

This module downloads NIC information from each registries below:

* ARIN
* RIPE
* APNIC
* LACNIC
* AFRINIC

And countries information from ISO.

URLs for each information are written in `./conf/url_*`