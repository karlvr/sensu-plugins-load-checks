#!/usr/bin/perl -w

sub load_avg {
	my $cores = cpu_count();
	if (-e "/proc/loadavg") {
		my @result;
		open(my $fh, "<", "/proc/loadavg") or die("Cannot read /proc/loadavg");
		while (my $line = <$fh>) {
			@result = map { $_ / $cores } (split(/\s+/, $line))[0..2];
		}
		close($fh);
		return @result;
	} else {
		# Fallback for FreeBSD
		my @result;
		open(my $fh, "uptime|") or die("Cannot run uptime");
		while (my $line = <$fh>) {
			$line =~ s/.*load average: //;
			@result = map { $_ / $cores } split(/\s+/, $line);
		}
		close($fh);
		return @result;
	}
}

sub cpu_count {
	if (-e "/proc/cpuinfo") {
		my $count = 0;
		open(my $fh, "<", "/proc/cpuinfo") or die("Cannot read /proc/cpuinfo");
		while (<$fh>) {
			$count++ if /^processor/;
		}
		close($fh);
		return $count;
	} else {
		return int(`sysctl -n hw.ncpu`)
	}
}

return 1;
