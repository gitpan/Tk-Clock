BEGIN {
    $^W = 1;
    $|  = 1;
    }
END {
    $::loaded || print "not ok 1\n";
    }

print "1..2\n";
use Tk;
use Tk::Clock;
$::loaded = 1;
print "ok 1\n";

print "2..2\n";
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
sub stop_clock
{
    $c->destroy;
    print "ok 2\n";
    $m->destroy;
    } # stop_clock

sub chg_clock
{
    $c->config (
	dateFormat=> "m/d/y",
	timeFormat=> "hh:MM A",
	);
    }

$c->after ( 5000, \&chg_clock);
$c->after (10000, \&stop_clock);

MainLoop;
