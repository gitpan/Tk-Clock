=head1 NAME

Tk::Clock - Clock widget with analog and digital display

=head1 SYNOPSIS

use Tk
use Tk::Clock;

$clock = $parent->Clock (?-option => <value> ...?);

$clock->config (	# These reflect the defaults
    useAnalog	=> 1,
    useDigital	=> 1,
    handColor	=> "Green4",
    secsColor	=> "Green2",
    tickColor	=> "Yellow4",
    timeFont	=> "fixed",
    timeColor	=> "Red4",
    timeFormat	=> "HH.MM:SS",
    dateFont	=> "fixed",
    dateColor	=> "Blue4",
    dateFormat	=> "dd-mm-yy");

=head1 DESCRIPTION

Create a clock canvas with both an analog- and a digital display. Either
can be disabled by setting useAnalog or useDigital to 0 resp.

Legal dateFormat characters are d and dd for date, m and mm for month,
y and yy for year and any separators :, -, / or space.

Legal timeFormat characters are H and HH for hour, h and hh for AM/PM hour,
M and MM for minutes, S and SS for seconds, A for AM/PM indicator and any
separators :, -, . or space.

=head1 BUGS

If the system load's too high, the clock might skip some seconds.

Due to the fact that the year is expressed in 2 digit's, this
widget is not (yet) Y2K compliant.

ddd and dddd for the (abbreviated) day of the week and
mmm and mmmm for the (abbreviated) month are not (yet) supported.

There's no check if either format will fit in the given space.

=head1 TODO

* Scalability would be a nice feature.
* Using POSIX' strftime () for dateFormat. Current implementation
  would probably make this very slow.

=head1 AUTHOR

H.Merijn Brand <merijn@hempseed.com>

Thanks to Larry Wall for inventing perl.
Thanks to Nick Ing-Simmons for providing perlTk.
Thanks to Achim Bohnet for introducing me to OO (and converting
    the basics of my clock.pl to clock.pm).
Thanks to Sriram Srinivasan for understanding OO though his Panther book.

=cut

package Tk::Clock;

use strict;
use vars qw/$VERSION @ISA/;

use Tk::Widget;
use Tk::Derived;
use Tk::Canvas;

@ISA = qw/Tk::Derived Tk::Canvas/;
$VERSION = "0.03";

Construct Tk::Widget "Clock";

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

    fmtd	=> sub {
	my ($d, $m, $y) = @_;
	sprintf "%02d-%02d-%02d", $d, $m + 1, $y;
	},
    fmtt	=> sub {
	my ($h, $m, $s) = @_;
	sprintf "%02d.%02d:%02d", $h, $m, $s;
	},
    );

sub resize ($)
{
    my $clock = shift;

    my $data = $clock->privateData;
    my $hght = $data->{useAnalog}  * 73 + $data->{useDigital} * 26 + 1;
    $clock->cget (-height) == $hght && return;
    $clock->configure (-height => $hght);
    } # resize

sub createDigital ($)
{
    my $clock = shift;

    my $data = $clock->privateData;
    my $off = $data->{useAnalog} * 73;
    $clock->createText (37, $off + 26,
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

    foreach my $tick (0 .. 59) {
	my $l = $tick % 15 == 0 ? 28 :
		$tick %  5 == 0 ? 30 : 33;
	my $a = $tick * .104720;
	my $x = sin ($a);
	my $y = cos ($a);
	$clock->createLine (
	    36 + $x * $l, 36 - $y * $l,
	    36 + $x * 35, 36 - $y * 35,
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

    $data->{useDigital} && $clock->createDigital;
    $data->{useAnalog}  && $clock->createAnalog;
	
    $clock->repeat (995, ["run" => $clock]);
    } # Populate

sub config ($@)
{
    my $clock = shift;

    ref $clock || die "Bad method call";
    @_ || return;

    my $conf;
    if (ref $_[0] eq "HASH") {
	$conf = shift;
	}
    elsif (scalar @_ % 2 == 0) {
	my %conf = @_;
	$conf = \%conf;
	}
    else {
	die "Bad hash";
	}

    my $data = $clock->privateData;
    foreach my $conf_spec (keys %def_config) {
	defined $conf->{$conf_spec} || next;
	defined $data->{$conf_spec} || next;
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
		"ddd"	=> '%3s',	# Mon (NYI)
		"m"	=> '%d',	# 7
		"mm"	=> '%02d',	# 07
		"mmm"	=> '%3s',	# Jul (NYI)
		"y"	=> '%d',	# 98
		"yy"	=> '%02d',	# 98
		"yyy"	=> '%04d',	# 1998
		);
	    my $fmt = $data->{dateFormat};
	    $fmt =~ m(^[-dmy/: ]+$) || die "Bad dateFormat";
	    my @fmt = split m/([^dmy]+)/, $fmt;
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
	    $data->{Clock_h} = -1;	# force update;
	    $data->{fmtd}=eval"sub{my(\$d,\$m,\$y)=\@_;\$m++;sprintf \"$fmt\"$arg;}";
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
	    $fmt =~ m(^[-AhHMS\.: ]+$) || die "Bad timeFormat";
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
	    $data->{fmtt}=eval"sub{my(\$H,\$M,\$S)=\@_;my\$h=\$H%12;my\$A=\$H>11?'PM':'AM';sprintf \"$fmt\"$arg;}";
	    }
	elsif ($conf_spec eq "useAnalog") {
	    if    ($old == 1 && $data->{useAnalog} == 0) {
		$clock->destroyAnalog;
		$clock->destroyDigital;
		$data->{useDigital} && $clock->createDigital;
		}
	    elsif ($old == 0 && $data->{useAnalog} == 1) {
		$clock->destroyDigital;
		$clock->createAnalog;
		$data->{useDigital} && $clock->createDigital;
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

    $a = $tick * .104720;
    $x = sin ($a) * $len;
    $y = cos ($a) * $len;
    (36 - $x / 4, 36 + $y / 4, 36 + $x, 36 - $y);
    } # where

sub run ($)
{
    my $clock = shift;

    my (@t) = localtime (time);

    my $data = $clock->privateData;

    unless ($t[2] == $data->{Clock_h}) {
	$data->{Clock_h} = $t[2];
	$data->{useDigital} &&
	    $clock->itemconfigure ("date",
		-text => &{$data->{fmtd}} (@t[3,4,5]));
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
		    -width => 2.6);

	    $clock->delete ("min");
	    $clock->createLine (
		$clock->where ($data->{Clock_m}, 30),
		    -tags  => "min",
		    -arrow => "none",
		    -fill  => $data->{handColor},
		    -width => 1.5);
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
	$data->{useDigital} &&
	    $clock->itemconfigure ("time",
		-text => &{$data->{fmtt}} (@t[2,1,0]));
        } 
    } # run

1;
