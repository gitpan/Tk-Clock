BEGIN {
    $^W = 1;
    $|  = 1;
    }
END {
    $::loaded || print "not ok 1\n";
    }

print "1..6\n";
use Tk;
use Tk::Clock;
$::loaded = 1;
print "ok 1\n";

print "2..6\n";
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
print "3..6\n";

$c->after ( 5000, sub {
    $c->config (useAnalog => 1, useDigital => 0);
    print "ok 3\n";
    print "4..6\n";
    }); # no_analog

$c->after (10000, sub {
    $c->config (useAnalog => 0, useDigital => 1);
    print "ok 4\n";
    print "5..6\n";
    }); # no_analog

$c->after (15000, sub {
    $c->config (
	useAnalog => 1,
	useDigital=> 1,
	dateFormat=> "m/d/y",
	timeFormat=> "hh:MM A",
	);
    print "ok 5\n";
    print "6..6\n";
    }); # clock_us

$c->after (20000, sub {
    $c->destroy;
    $m->destroy;
    print "ok 6\n";
    }); # stop_clock

MainLoop;
