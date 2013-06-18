#!/usr/bin/perl -w
use strict;

use Test::More tests=>149;

use Convert::Age qw(decode_age_strict decode_age_error);

BEGIN {
	use_ok( 'Convert::Age' );
}

is(decode_age_strict("1s"), 1, "1 second");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("1S"), 1, "1 Second with big S");
ok(!decode_age_error(), "Error string is not set");

is(decode_age_strict("1m"), 60, "1 minute");
ok(!decode_age_error(), "Error string is not set");

is(decode_age_strict("1h"), 3600, "1 hour");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("1H"), 3600, "1 Hour with big H");
ok(!decode_age_error(), "Error string is not set");

is(decode_age_strict("1d"), 3600 * 24, "1 day");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("1D"), 3600 * 24, "1 Day with big D");
ok(!decode_age_error(), "Error string is not set");

is(decode_age_strict("1w"), 3600 * 24 * 7, "1 week");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("1W"), 3600 * 24 * 7, "1 Week with big W");
ok(!decode_age_error(), "Error string is not set");

is(decode_age_strict("1M"), 3600 * 24 * 7 * 4, "1 Month");
ok(!decode_age_error(), "Error string is not set");

is(decode_age_strict("1y"), 31556952, "1 year");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("1Y"), 31556952, "1 year with big Y");
ok(!decode_age_error(), "Error string is not set");

foreach ("a" .. "z") {
	next if (/(s|m|h|d|w|y)/);
	ok(!decode_age_strict("1$_"), "Incorrect 1$_");
	like(decode_age_error(), qr/Time abbrevation \[[a-zA-Z]\] not known./, "Error string is set and correct");
}

foreach ("A" .. "Z") {
	next if (/(M|D|H|S|W|Y)/);
	ok(!decode_age_strict("1$_"), "Incorrect 1$_");
	ok(decode_age_error(), "Error string is set");
}

is(decode_age_strict("1m1s"), 61, "1m1s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("2m45s"), 165, "2m45s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("2h5m1s"), 1 + 60 * 5 + 60 * 60 * 2, "2h5m1s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("2d2h5m1s"), 3600 * 24 * 2 + 3600 * 2 + 5*60 + 1, "2d2h5m1s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("1s5m2h2d"), 0, "1s5m2h2d is not alloed");
like(decode_age_error(), qr/Previous time abbrevation \[[a-zA-Z]\] is smaller than \[[a-zA-Z]\]. This is not allowed./, "Error string is set and correct");
is(decode_age_strict("3w2d2h5m1s"),  3600 * 24 * 7 * 3 + 3600 * 24 * 2 + 3600 * 2 + 5*60 + 1, "3w2d2h5m1s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("2M3w2d2h5m1s"), 3600 * 24 * 7 * 4 * 2 + 3600 * 24 * 7 * 3 + 3600 * 24 * 2 + 3600 * 2 + 5*60 + 1, "2M3w2d2h5m1s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("2Y2M3w2d2h5m1s"), 2 * 31556952 + 3600 * 24 * 7 * 4 * 2 + 3600 * 24 * 7 * 3 + 3600 * 24 * 2 + 3600 * 2 + 5*60 + 1, "2Y2M3w2d2h5m1s");
ok(!decode_age_error(), "Error string is not set");

# Error, previous abbrevation larger than next.
is(decode_age_strict("3w2h2d5m1s"),  0, "3w2h2d5m1s not ok - previous setting larger than next");
like(decode_age_error(), qr/Previous time abbrevation \[[a-zA-Z]\] is smaller than \[[a-zA-Z]\]. This is not allowed./, "Error string is set and correct");
# Error, previous setting larger than next.
is(decode_age_strict("3w2d49h5m1s"),  0, "3w2d49h5m1s not ok - previous slice larger than next");
like(decode_age_error(), qr/Current time abbrevation \[\w+\] is larger or equal to given in previous \[\w+\]. Please optimize./, "Error string is set and correct");


# Same block as previous, but spaces are used.
is(decode_age_strict("1m 1s"), 61, "1m 1s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("2m 45s"), 165, "2m 45s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("2h 5m 1s"), 1 + 60 * 5 + 60 * 60 * 2, "2h 5m 1s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("2d 2h 5m 1s"), 3600 * 24 * 2 + 3600 * 2 + 5*60 + 1, "2d 2h 5m 1s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("1s 5m 2h 2d"), 0, "1s 5m 2h 2d is not alloed");
like(decode_age_error(), qr/Previous time abbrevation \[[a-zA-Z]\] is smaller than \[[a-zA-Z]\]. This is not allowed./, "Error string is set and correct");
is(decode_age_strict("3w 2d 2h 5m 1s"),  3600 * 24 * 7 * 3 + 3600 * 24 * 2 + 3600 * 2 + 5*60 + 1, "3w 2d 2h 5m 1s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("2M 3w 2d 2h 5m 1s"), 3600 * 24 * 7 * 4 * 2 + 3600 * 24 * 7 * 3 + 3600 * 24 * 2 + 3600 * 2 + 5*60 + 1, "2M 3w 2d 2h 5m 1s");
ok(!decode_age_error(), "Error string is not set");
is(decode_age_strict("2Y 2M 3w 2d 2h 5m 1s"), 2 * 31556952 + 3600 * 24 * 7 * 4 * 2 + 3600 * 24 * 7 * 3 + 3600 * 24 * 2 + 3600 * 2 + 5*60 + 1, "2Y 2M 3w 2d 2h 5m 1s");
ok(!decode_age_error(), "Error string is not set");

# Error, previous abbrevation larger than next.
is(decode_age_strict("3w 2h 2d 5m 1s"),  0, "3w 2h 2d 5m 1s not ok - previous setting larger than next");
like(decode_age_error(), qr/Previous time abbrevation \[[a-zA-Z]\] is smaller than \[[a-zA-Z]\]. This is not allowed./, "Error string is set and correct");

# Error, previous setting larger than next.
is(decode_age_strict("3w 2d 49h 5m 1s"),  0, "3w 2d 49h 5m 1s not ok - previous slice larger than next");
like(decode_age_error(), qr/Current time abbrevation \[\w+\] is larger or equal to given in previous \[\w+\]. Please optimize./, "Error string is set and correct");

# Error if string doesn't start with digit
is(decode_age_strict("m 1s"), 0, "m 1s shows error");
like(decode_age_error(), qr/Age string must start with digit!/, "Error string is set and correct");

# Error if string doesn't end with digit
is(decode_age_strict("1m 1"), 0, "m 1s shows error");
like(decode_age_error(), qr/Age string must end with letter!/, "Error string is set and correct");
