=head1 NAME

Tk::Clock - Clock widget with analog and digital display

=head1 SYNOPSIS

use Tk
use Tk::Clock;

$clock = $parent->Clock (?-option => <value> ...?);

$clock->config (	# These reflect the defaults
    useDigital	=> 1,
    useAnalog	=> 1,
    anaScale	=> 100,
    handColor	=> "Green4",
    secsColor	=> "Green2",
    tickColor	=> "Yellow4",
    tickFreq	=> 1,
    timeFont	=> "fixed",
    timeColor	=> "Red4",
    timeFormat	=> "HH.MM:SS",
    dateFont	=> "fixed",
    dateColor	=> "Blue4",
    dateFormat	=> "dd-mm-yy");

=head1 DESCRIPTION

Create a clock canvas with both an analog- and a digital display. Either
can be disabled by setting useAnalog or useDigital to 0 resp.

Legal dateFormat characters are d and dd for date, ddd and dddd for weekday,
m, mm, mmm and mmmm for month, y and yy for year and
any separators :, -, / or space.

Legal timeFormat characters are H and HH for hour, h and hh for AM/PM hour,
M and MM for minutes, S and SS for seconds, A for AM/PM indicator and any
separators :, -, . or space.

Meaningful values for tickFreq are 1, 5 and 15 showing all ticks, tick
every 5 minutes or the four main ticks only, though any positive integer
will do (put a tick on any tickFreq minute).

The analog clock can be enlaged or reduced using anaScale for which the
default of 100% is about 72x72 pixels. Future enhancement will include
auto sizing for anaScale 0.

=head1 BUGS

If the system load's too high, the clock might skip some seconds.

Due to the fact that the year is expressed in 2 digit's, this
widget is not Y2K compliant in the default configuration.

There's no check if either format will fit in the given space.

=head1 TODO

* Using POSIX' strftime () for dateFormat. Current implementation
  would probably make this very slow.
* Auto sizing to fit (analog) clock in given space.

=head1 AUTHOR

H.Merijn Brand <merijn@hempseed.com>

Thanks to Larry Wall for inventing perl.
Thanks to Nick Ing-Simmons for providing perlTk.
Thanks to Achim Bohnet for introducing me to OO (and converting
    the basics of my clock.pl to Tk::Clock.pm).
Thanks to Sriram Srinivasan for understanding OO though his Panther book.

=cut

package Tk::Clock;

use Carp;
use strict;
use vars qw/$VERSION @ISA/;

use Tk::Widget;
use Tk::Derived;
use Tk::Canvas;

@ISA = qw/Tk::Derived Tk::Canvas/;
$VERSION = "0.06";

Construct Tk::Widget "Clock";

my $ana_base = 73;	# Size base for 100%
my $ana_size = 73;	# Default size
my $dig_size = 26;

my %def_config = (
    handColor	=> "Green4",
    secsColor	=> "Green2",
    tickColor	=> "Yellow4",

    timeFont	=> "fixed",
    timeColor	=> "Red4",
    timeFormat	=> "HH.MM:SS",

    dateFont	=> "fixed",
    dateColor	=> "Blue4",
    dateFormat	=> "dd-mm-yy",

    useDigital	=> 1,
    useAnalog	=> 1,
    anaScale	=> 100,
    tickFreq	=> 1,

    fmtd	=> sub {
	my ($d, $m, $y, $w) = @_;
	sprintf "%02d-%02d-%02d", $d, $m + 1, $y % 100;
	},
    fmtt	=> sub {
	my ($h, $m, $s) = @_;
	sprintf "%02d.%02d:%02d", $h, $m, $s;
	},
    );

sub month ($$)
{
    [[  "1", "01", "Jan", "January"	],
     [  "2", "02", "Feb", "February"	],
     [  "3", "03", "Mar", "March"	],
     [  "4", "04", "Apr", "April"	],
     [  "5", "05", "May", "May"		],
     [  "6", "06", "Jun", "June"	],
     [  "7", "07", "Jul", "July"	],
     [  "8", "08", "Aug", "August"	],
     [  "9", "09", "Sep", "September"	],
     [ "10", "10", "Oct", "October"	],
     [ "11", "11", "Nov", "November"	],
     [ "12", "12", "Dec", "December"	]]->[$_[0]][$_[1]];
    } # month

sub wday ($$)
{
    [[ "Sun", "Sunday"		],
     [ "Mon", "Monday"		],
     [ "Tue", "Tuesday"		],
     [ "Wed", "Wednesday"	],
     [ "Thu", "Thursday"	],
     [ "Fri", "Friday"		],
     [ "Sat", "Saturday"	]]->[$_[0]][$_[1]];
    } # wday

sub max ($$)
{
    $_[0] >= $_[1] ? $_[0] : $_[1];
    } # max

sub auto_size ()
{
    $ana_size > 0 and return $ana_size;
    } # auto_size

sub resize ($)
{
    my $clock = shift;

    my $data = $clock->privateData;
    my $hght = $data->{useAnalog}  * $ana_size + $data->{useDigital} * $dig_size + 1;
    my $wdth = max ($data->{useAnalog} * $ana_size, $data->{useDigital} * 72);
    $clock->cget (-height) == $hght &&
     $clock->cget (-width) == $wdth and return;
    $clock->configure (
	-height => $hght,
	-width  => $wdth);
    } # resize

sub createDigital ($)
{
    my $clock = shift;

    my $data = $clock->privateData;
    my $off = $data->{useAnalog} * $ana_size;
    $clock->createText (37, $off + $dig_size,
	-width  => 65,
	-font   => $data->{dateFont},
	-fill   => $data->{dateColor},
	-text   => $data->{dateFormat},
	-tags   => "date",
	-anchor => "s");
    $clock->createText (37, $off + 13,
	-width  => 65,
	-font   => $data->{timeFont},
	-fill   => $data->{timeColor},
	-text   => $data->{timeFormat},
	-tags   => "time",
	-anchor => "s");
    $data->{Clock_h} = -1;
#   $data->{Clock_m} = -1;
    $data->{Clock_s} = -1;
    $clock->resize ($data);
    } # createDigital

sub destroyDigital ($)
{
    my $clock = shift;

    $clock->delete ("date");
    $clock->delete ("time");
    } # destroyDigital

sub createAnalog ($)
{
    my $clock = shift;

    my $data = $clock->privateData;

    my $h = ($ana_size + 1) / 2 - 1;
    my $f = $data->{tickFreq};
    foreach my $tick (0 .. 59) {
	$tick % $f and next;
	my $l = $tick % 15 == 0 ? $h / 5 :
		$tick %  5 == 0 ? $h / 8 :
				  $h / 16;
	my $a = $tick * .104720;
	my $x = sin $a;
	my $y = cos $a;
	$clock->createLine (
	    ($h - $l) * $x + $h + 1, ($h - $l) * $y + $h + 1,
	     $h       * $x + $h + 1,  $h       * $y + $h + 1,
	    -tags  => "tick",
	    -arrow => "none",
	    -fill  => $data->{tickColor},
	    -width => 1.0);
	}
    $data->{Clock_h} = -1;
    $data->{Clock_m} = -1;
    $data->{Clock_s} = -1;
    $clock->resize ($data);
    } # createAnalog

sub destroyAnalog ($)
{
    my $clock = shift;

    $clock->delete ("tick");
    $clock->delete ("hour");
    $clock->delete ("min");
    $clock->delete ("sec");
    } # destroyAnalog

sub Populate
{
    my ($clock, $args) = @_;

    my $data = $clock->privateData;
    %$data = %def_config;
    $data->{Clock_h} = -1;
    $data->{Clock_m} = -1;
    $data->{Clock_s} = -1;

    $clock->SUPER::Populate ($args);

    $clock->ConfigSpecs (
        -width              => [ qw(SELF width              Width              72    ) ],
        -height             => [ qw(SELF height             Height             100   ) ],
        -relief             => [ qw(SELF relief             Relief             raised) ],
        -borderwidth        => [ qw(SELF borderWidth        BorderWidth        1     ) ],
        -highlightthickness => [ qw(SELF highlightThickness HighlightThickness 0     ) ],
        -takefocus          => [ qw(SELF takefocus          Takefocus          0     ) ],
        );

    $data->{useDigital} and $clock->createDigital;
    $data->{useAnalog}  and $clock->createAnalog;
	
    $clock->repeat (995, ["run" => $clock]);
    } # Populate

sub config ($@)
{
    my $clock = shift;

    ref $clock or croak "Bad method call";
    @_ or return;

    my $conf;
    if (ref $_[0] eq "HASH") {
	$conf = shift;
	}
    elsif (scalar @_ % 2 == 0) {
	my %conf = @_;
	$conf = \%conf;
	}
    else {
	croak "Bad hash";
	}

    my $data = $clock->privateData;
    foreach my $conf_spec (keys %def_config) {
	defined $conf->{$conf_spec} or next;
	defined $data->{$conf_spec} or next;
	my $old = $data->{$conf_spec};
	$data->{$conf_spec} = $conf->{$conf_spec};
	if    ($conf_spec eq "tickColor") {
	    $clock->itemconfigure ("tick", -fill => $data->{tickColor});
	    }
	elsif ($conf_spec eq "handColor") {
	    $clock->itemconfigure ("hour", -fill => $data->{handColor});
	    $clock->itemconfigure ("min",  -fill => $data->{handColor});
	    }
	elsif ($conf_spec eq "dateColor") {
	    $clock->itemconfigure ("date", -fill => $data->{dateColor});
	    }
	elsif ($conf_spec eq "dateFont") {
	    $clock->itemconfigure ("date", -font => $data->{dateFont});
	    }
	elsif ($conf_spec eq "timeColor") {
	    $clock->itemconfigure ("time", -fill => $data->{timeColor});
	    }
	elsif ($conf_spec eq "timeFont") {
	    $clock->itemconfigure ("time", -font => $data->{timeFont});
	    }
	elsif ($conf_spec eq "dateFormat") {
	    my %fmt = (
		"d"	=> '%d',	# 6
		"dd"	=> '%02d',	# 06
		"ddd"	=> '%3s',	# Mon
		"dddd"	=> '%s',	# Monday
		"m"	=> '%d',	# 7
		"mm"	=> '%02d',	# 07
		"mmm"	=> '%3s',	# Jul
		"mmmm"	=> '%s',	# July
		"y"	=> '%d',	# 98
		"yy"	=> '%02d',	# 98
		"yyy"	=> '%04d',	# 1998
		);
	    my $fmt = $data->{dateFormat};
	    $fmt =~ m(^[-dmy/: \n]*$) or croak "Bad dateFormat";
	    my @fmt = split m/([^dmy]+)/, $fmt;
	    my $args = "";
	    $fmt = "";
	    foreach my $f (@fmt) {
		if (defined $fmt{$f}) {
		    $fmt .= $fmt{$f};
		    if ($f =~ m/^m+$/) {
			my $l = length ($f) - 1;
			$args .= ", Tk::Clock::month (\$m, $l)";
			}
		    elsif ($f =~ m/^ddd+/) {
			my $l = length ($f) - 3;
			$args .= ", Tk::Clock::wday (\$w, $l)";
			}
		    else {
			$args .= ', $' . substr ($f, 0, 1);
			$f =~ m/^y+$/ and
			    $args .= length ($f) < 3 ? " % 100" : " + 1900";
			}
		    }
		else {
		    $fmt .= $f;
		    }
		}
	    $data->{Clock_h} = -1;	# force update;
	    $data->{fmtd}=eval"sub{my(\$d,\$m,\$y,\$w)=\@_;sprintf qq!$fmt!$args;}";
	    }
	elsif ($conf_spec eq "timeFormat") {
	    my %fmt = (
		"H"	=> '%d',	# 6
		"HH"	=> '%02d',	# 06
		"h"	=> '%d',	# 6	AM/PM
		"hh"	=> '%02d',	# 06	AM/PM
		"M"	=> '%d',	# 7
		"MM"	=> '%02d',	# 07
		"S"	=> '%d',	# 45
		"SS"	=> '%02d',	# 45
		"A"	=> '%s',	# PM
		);
	    my $fmt = $data->{timeFormat};
	    $fmt =~ m(^[-AhHMS\.: ]*$) or croak "Bad timeFormat";
	    my @fmt = split m/([^AhHMS]+)/, $fmt;
	    my $arg = "";
	    $fmt = "";
	    foreach my $f (@fmt) {
		if (defined $fmt{$f}) {
		    $fmt .= $fmt{$f};
		    $arg .= ', $' . substr ($f, 0, 1);
		    }
		else {
		    $fmt .= $f;
		    }
		}
	    $data->{fmtt} = eval "sub
	                          {
				      my (\$H, \$M, \$S) = \@_;
				      my \$h = \$H % 12;
				      my \$A = \$H > 11 ? 'PM' : 'AM';
				      sprintf \"$fmt\"$arg;
				      }";
	    }
	elsif ($conf_spec eq "tickFreq") {
	    $data->{tickFreq} < 1 ||
	    $data->{tickFreq} != int $data->{tickFreq} and
		$data->{tickFreq} = $old;
	    unless ($data->{tickFreq} == $old) {
		$clock->destroyAnalog;
		$clock->createAnalog;
		}
	    }
	elsif ($conf_spec eq "anaScale") {
	    $data->{anaScale} <= 0 and	# 0 will be auto some time
		$data->{anaScale} = $old;
	    my $new_size = $ana_base * $data->{anaScale} / 100.;
	    unless ($new_size == $ana_size) {
		$ana_size = $new_size;
		$clock->destroyAnalog;
		$clock->createAnalog;
		$clock->resize;
		$clock->after (5, ["run" => $clock]);
		}
	    }
	elsif ($conf_spec eq "useAnalog") {
	    if    ($old == 1 && $data->{useAnalog} == 0) {
		$clock->destroyAnalog;
		$clock->destroyDigital;
		$data->{useDigital} and $clock->createDigital;
		}
	    elsif ($old == 0 && $data->{useAnalog} == 1) {
		$clock->destroyDigital;
		$clock->createAnalog;
		$data->{useDigital} and $clock->createDigital;
		}
	    $clock->resize;
	    $clock->after (5, ["run" => $clock]);
	    }
	elsif ($conf_spec eq "useDigital") {
	    if    ($old == 1 && $data->{useDigital} == 0) {
		$clock->destroyDigital;
		}
	    elsif ($old == 0 && $data->{useDigital} == 1) {
		$clock->createDigital;
		}
	    $clock->resize;
	    $clock->after (5, ["run" => $clock]);
	    }
	}
    } # config

sub where ($$$)
{
    my ($clock, $tick, $len) = @_;      # ticks 0 .. 59
    my ($x, $y, $a);

    my $h = ($ana_size + 1) / 2;
    $a = $tick * .104720;
    $x = $len  * sin ($a) * $ana_size / 73;
    $y = $len  * cos ($a) * $ana_size / 73;
    ($h - $x / 4, $h + $y / 4, $h + $x, $h - $y);
    } # where

sub run ($)
{
    my $clock = shift;

    my (@t) = localtime time;

    my $data = $clock->privateData;

    unless ($t[2] == $data->{Clock_h}) {
	$data->{Clock_h} = $t[2];
	$data->{useDigital} and
	    $clock->itemconfigure ("date",
		-text => &{$data->{fmtd}} (@t[3,4,5,6]));
	}

    unless ($t[1] == $data->{Clock_m}) {
        $data->{Clock_m} = $t[1];
	if ($data->{useAnalog}) {
	    $clock->delete ("hour");
	    $clock->createLine (
		$clock->where (($data->{Clock_h} % 12) * 5 + $t[1] / 12, 22),
		    -tags  => "hour",
		    -arrow => "none",
		    -fill  => $data->{handColor},
		    -width => $ana_size / 26);

	    $clock->delete ("min");
	    $clock->createLine (
		$clock->where ($data->{Clock_m}, 30),
		    -tags  => "min",
		    -arrow => "none",
		    -fill  => $data->{handColor},
		    -width => $ana_size / 30);
	    }
	}

    unless ($t[0] == $data->{Clock_s}) {
        $data->{Clock_s} = $t[0];
        if ($data->{useAnalog}) {
	    $clock->delete ("sec");
	    $clock->createLine (
		$clock->where ($data->{Clock_s}, 34),
		    -tags  => "sec",
		    -arrow => "none",
		    -fill  => $data->{secsColor},
		    -width => 0.8);
	    }
	$data->{useDigital} and
	    $clock->itemconfigure ("time",
		-text => &{$data->{fmtt}} (@t[2,1,0]));
        } 
    } # run

1;
