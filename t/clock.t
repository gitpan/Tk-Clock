BEGIN {
    $^W = 1;
    $|  = 1;
    }
END {
    $::loaded || print "not ok 1\n";
    }

my $ntests = 10;
print "1..$ntests\n";
use Tk;
use Tk::Clock;
$::loaded = 1;
print "ok 1\n";

my $delay  = 0;
my $period = 5000;

print "2..$ntests\n";
my $m = MainWindow->new (-title => "clock");
my $c = $m->Clock (-background => "Black");
$c->config (
    tickColor => "Orange",
    handColor => "Red",
    secsColor => "Green",
    timeColor => "lightBlue",
    dateColor => "Gold",
    timeFont  => "-misc-fixed-medium-r-normal--13-*-75-75-c-*-iso8859-1",
    );
$c->pack;
print "ok 2\n";
print "3..$ntests\n";

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Blue4");
    $c->config (
	tickColor  => "Yellow",
	useAnalog  => 1,
	useDigital => 0);
    print "ok 3\n";
    print "4..$ntests\n";
    }); # no_analog

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Tan4");
    $c->config (
	useAnalog  => 0,
	useDigital => 1);
    print "ok 4\n";
    print "5..$ntests\n";
    }); # no_analog

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Maroon4");
    $c->config (
	useAnalog  => 1,
	useDigital => 1,
	dateFormat => "m/d/y",
	timeFormat => "hh:MM A",
	);
    print "ok 5\n";
    print "5..$ntests\n";
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Red4");
    $c->config (
	useAnalog  => 0,
	useDigital => 1,
	dateFormat => "mmm yyy",
	timeFormat => "HH:MM:SS",
	);
    print "ok 6\n";
    print "6..$ntests\n";
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Purple4");
    $c->config (
	useAnalog  => 0,
	useDigital => 1,
	dateFormat => "dddd\nd mmm yyy",
	timeFormat => "",
	);
    print "ok 7\n";
    print "7..$ntests\n";
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Gray75");
    $c->config (
	useAnalog  => 1,
	useDigital => 0,
	anaScale   => 300,
	);
    print "ok 8\n";
    print "8..$ntests\n";
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    $c->config (
	useAnalog  => 1,
	useDigital => 0,
	anaScale   => 67,
	tickFreq   => 5,
	);
    print "ok 9\n";
    print "9..$ntests\n";
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    $c->destroy;
    $m->destroy;
    print "ok $ntests\n";
    }); # stop_clock

MainLoop;
