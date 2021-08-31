#!/usr/bin/perl -w
# This plugin uses uptime to collect load metrics
# Based on https://github.com/sensu-plugins/sensu-plugins-load-checks/blob/master/bin/metrics-load.rb

use Getopt::Long qw(:config no_auto_abbrev no_ignore_case);
use Pod::Usage;
use Sys::Hostname;

# https://metacpan.org/pod/lib::relative
use Cwd ();
use File::Basename ();
use File::Spec ();
use lib File::Spec->catdir(File::Basename::dirname(Cwd::abs_path __FILE__), '../lib');

require "load-average.pm";

my $scheme = hostname();

GetOptions(
	'scheme|s=s' => \$scheme,
) or pod2usage(2);

my $now = time();
my @loadavg = load_avg();

if (!@loadavg) {
	print "Could not read load average from /proc or `uptime`";
	exit 3;
}

printf("%s.load_avg.one %.2f %i\n", $scheme, $loadavg[0], $now);
printf("%s.load_avg.five %.2f %i\n", $scheme, $loadavg[1], $now);
printf("%s.load_avg.fifteen %.2f %i\n", $scheme, $loadavg[2], $now);
