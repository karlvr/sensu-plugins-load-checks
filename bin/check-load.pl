#!/usr/bin/perl -w
# Check the system load
# Based on https://github.com/sensu-plugins/sensu-plugins-load-checks/blob/master/bin/check-load.rb

use Getopt::Long qw(:config no_auto_abbrev no_ignore_case);
use Pod::Usage;
use Sys::Hostname;

# https://metacpan.org/pod/lib::relative
use Cwd ();
use File::Basename ();
use File::Spec ();
use lib File::Spec->catdir(File::Basename::dirname(Cwd::abs_path __FILE__), '../lib');

require "load-average.pm";

my @warn;
my @crit;

GetOptions(
	'warn|w=s' => \@warn,
	'crit|c=s' => \@crit,
) or pod2usage(2);

@warn = split(/,/, join(',', @warn));
@crit = split(/,/, join(',', @crit));

if (!@warn) {
	@warn = (2.75, 2.5, 2.0);
}
if (!@crit) {
	@crit = (3.5, 3.25, 3.0);
}

my $now = time();
my @loadavg = load_avg();
my $cpucount = cpu_count();

if (!@loadavg) {
	print "Could not read load average from /proc or `uptime`";
	exit 3;
}

sub exceed {
	my @levels = @_;
	for ($i = 0; $i <= $#levels; $i++) {
		if ($i <= $#loadavg) {
			if ($loadavg[$i] >= $levels[$i]) {
				return 1;
			}
		}
	}
	return 0;
}

print "Per core load average ($cpucount CPU): @loadavg\n";
exit 2 if exceed(@crit);
exit 1 if exceed(@warn);
