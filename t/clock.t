#!/pro/bin/perl

use strict;
use warnings;

use Test::More tests => 19;

BEGIN {
    use_ok ("Tk");
    use_ok ("Tk::Clock");
    }

my ($delay, $period, $m, $c) = (0, 5000);
ok ($m = MainWindow->new (-title => "clock"),	"MainWindow");
ok ($c = $m->Clock (-background => "Black"),	"Clock Widget");
like ($c->config (
    tickColor => "Orange",
    handColor => "Red",
    secsColor => "Green",
    timeColor => "lightBlue",
    dateColor => "Gold",
    timeFont  => "-misc-fixed-medium-r-normal--13-*-75-75-c-*-iso8859-1",
    ), qr(^Tk::Clock=HASH), "config");
ok ($c->pack (-expand => 1, -fill => "both"), "pack");
# Three stupid tests to align the rest
is ($delay, 0, "Delay is 0");
like ($period, qr/^\d+$/, "Period is $period");

$delay += $period;
like ($delay, qr/^\d+$/, "First after $delay");

$c->after ($delay, sub {
    $c->configure (-background => "Blue4");
    ok ($c->config (
	tickColor  => "Yellow",
	useAnalog  => 1,
	useDigital => 0,
	), "Blue4   Ad Yellow");
    }); # no_analog

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Tan4");
    ok ($c->config (
	useAnalog  => 0,
	useDigital => 1,
	), "Tan4    aD");
    }); # no_analog

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Maroon4");
    ok ($c->config (
	useAnalog  => 1,
	useDigital => 1,
	dateFormat => "m/d/y",
	timeFormat => "hh:MM A",
	), "Maroon4 AD m/d/y hh:MM A");
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Red4");
    ok ($c->config (
	useAnalog  => 0,
	useDigital => 1,
	dateFormat => "mmm yyy",
	timeFormat => "HH:MM:SS",
	), "Red4    aD mmm yyy HH:MM:SS");
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Purple4");
    ok ($c->config (
	useAnalog  => 0,
	useDigital => 1,
	dateFormat => "dddd\nd mmm yyy",
	timeFormat => "",
	), "Purple4 aD dddd\\nd mmm yyy ''");
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Gray75");
    ok ($c->config (
	useAnalog  => 1,
	useDigital => 0,
	anaScale   => 300,
	), "Gray75  Ad scale 300");
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    ok ($c->config (
	useAnalog  => 1,
	useDigital => 0,
	anaScale   => 67,
	tickFreq   => 5,
	), "        Ad scale  67 tickFreq 5");
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    ok ($c->config (
	useAnalog  => 1,
	useDigital => 1,
	anaScale   => 100,
	tickFreq   => 5,
	dateFormat => "ww dd-mm",
	timeFormat => "dd HH:SS",
	), "        AD scale 100 tickFreq 5 ww dd-mm dd HH:SS");
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    $c->destroy;
    ok (!Exists ($c), "Destroy Clock");
    $m->destroy;
    ok (!Exists ($m), "Destroy Main");
    exit;
    }); # stop_clock

MainLoop;
