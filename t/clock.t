BEGIN {
    $^W = 1;
    $|  = 1;
    }
END {
    $::loaded || print "not ok 1\n";
    }

print "1..8\n";
use Tk;
use Tk::Clock;
$::loaded = 1;
print "ok 1\n";

my $delay  = 0;
my $period = 5000;

print "2..8\n";
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
print "3..8\n";

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Blue4");
    $c->config (
	tickColor  => "Yellow",
	useAnalog  => 1,
	useDigital => 0);
    print "ok 3\n";
    print "4..8\n";
    }); # no_analog

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Tan4");
    $c->config (
	useAnalog  => 0,
	useDigital => 1);
    print "ok 4\n";
    print "5..8\n";
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
    print "5..8\n";
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
    print "6..8\n";
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
    print "7..8\n";
    }); # clock_us

$delay += $period;
$c->after ($delay, sub {
    $c->destroy;
    $m->destroy;
    print "ok 8\n";
    }); # stop_clock

MainLoop;
