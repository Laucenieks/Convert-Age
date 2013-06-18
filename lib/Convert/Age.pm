package Convert::Age;

use warnings;
use strict;

=head1 NAME

Convert::Age - convert integer seconds into a "compact" form and back.

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';

=head1 SYNOPSIS

    use Convert::Age;

    my $c = Convert::Age::encode(189988007); # 6y7d10h26m47s
    my $d = Convert::Age::decode('5h37m5s'); # 20225

    # or export functions

    use Convert::Age qw(encode_age decode_age);

    my $c = encode_age(20225); # 5h37m5s
    my $d = decode_age('5h37m5s'); # 20225
    
    # or strict decoding - report any errors in human
    # readable error string.
    
    my $e = Convert::Age::decode_strict('5h37m5');
    if (!$e) {
    	print "Error: " . Convert::Age::error() . "\n";
    }
    
    # or export strict functions
    
    use Convert::Age qw(decode_age_strict decode_age_error);
    
    my $e = decode_age('h37m5s') # 0 and sets decode_age_error
    if (!$e) {
    	print "Error: " . decode_age_error() . "\n";
    }

=cut


use Exporter 'import';
our @EXPORT_OK = qw(encode_age decode_age decode_age_strict decode_age_error);

=head1 EXPORT

=over 4

=item encode_age 

synonym for Convert::Age::encode()

=item decode_age

synonym for Convert::Age::decode()

=item decode_age_strict

synonym for Convert::Age::decode_strict()

=item decode_age_error

synonym for Convert::Age::error()

=back

=head1 NOTE

The methods in this module are suitable for some kinds of logging and
input/output conversions.  It achieves the conversion through simple
remainder arithmetic and the length of a year as 365.2425 days.

=head1 TIME INTERVAL ABBREVATIONS

B<s> seconds

B<m> minutes

B<h> hours

B<d> days

B<w> weeks

B<M> months

B<y> years

Uppercase letters are accepted if corresponding lowercase letter is found.
Please note that B<M> is an exception.

=head1 FUNCTIONS

=head2 encode

convert seconds into a "readable" format 344 => 5m44s

=cut

my %convert = (
    y => 365.2425 * 3600 * 24,
    M => 3600 * 24 * 7 * 4,
    w => 3600 * 24 * 7,
    d => 3600 * 24,
    h => 3600,
    m => 60,
    s => 1,
);

our $errstr = '';

sub encode {
    my $age = shift;

    my $out = "";

    my %tag = reverse %convert;

    # largest first
    for my $k (reverse sort {$a <=> $b} keys %tag) {
        next unless ($age >= $k);
        next if (int ($age / $k) == 0);

        $out .= int ($age / $k). $tag{$k};
        $age = $age % $k;
    }

    return $out;
}

=head2 encode_age

synonym for encode that can be exported

=cut

sub encode_age {
    goto &encode;
}

=head2 decode

convert the "readable" format into seconds

=cut

sub decode {
    my $age = shift;

    return $age if ($age =~ /^\d+$/);

    my $seconds = 0;
    my $p = join "", keys %convert;
    my @l = split /([$p])/, $age;

    while (my ($c, $s) = splice(@l, 0, 2)) {
        $seconds += $c * $convert{$s};
    }

    return $seconds;
}

=head2 decode_age

synonym for encode that can be exported

=cut

sub decode_age {
    goto &decode;
}

=head2 decode_strict

Same functionality as "decode" function, but strictly checks correctness of
given argument. In case of any errors, 0 is returned and error message
accessible with F<Decode::Age:error()> or F<decode_age_error()> functions is
set.

Additional feature of this function is that time slices can be seperated by
space e.g. "1w 3d 45m" is accepted.

The following checks are made and error is set if this fails, followed by
examples producing error.

=over 2

=item Letters type is known. "1A"

=item String starts with number. "w1d"

=item String ends with letter. "1m1"

=item Biggest time slice is first. "1s1m"

=back

=cut

sub decode_strict {
	goto &decode_age_strict;
}

sub decode_age_strict {
	my $age = shift;
	
	$errstr = '';
	
	return $age if ($age =~ /^\d+$/);
	
	if ($age !~ /^[\w\s]+$/) {
		_set_errstr("Non-word character given!");
		return 0;
	}
	
	if ($age !~ /^\d+/) {
		_set_errstr("Age string must start with digit!");
		return 0;
	}
	
	if ($age !~ /[a-zA-Z]$/) {
		_set_errstr("Age string must end with letter!");
		return 0;
	}
	
	my $seconds = 0;
	
	my $previous_var = ($convert{'y'} + 1);
	my $previous_size = ($convert{'y'} * 2010);
	my @previous_setting = ("N/a", "N/a");
	while($age =~ /\G(\d+)([a-zA-Z])\s*/g) {
		my ($c, $s) = ($1, $2);
		
		if (!($s) or (!exists($convert{$s}) and (!exists($convert{lc($s)})))) {
			_set_errstr(_get_errstr(), "Time abbrevation [$s] not known.");
			return 0;
		}
		
		# Search lowercase identifier, if exists.
		if (!exists($convert{$s})) {
			$s = lc($s);
		}
		
		if ($convert{$s} > $previous_var) {
			_set_errstr(_get_errstr(), "Previous time abbrevation",
			"[$previous_setting[1]] is smaller than [$s]. This is not allowed.");
			return 0;
		} else {
			$previous_var = $convert{$s};
		}
		
		if (($c * $convert{$s}) >= $previous_size) {
			_set_errstr(_get_errstr(), "Current time abbrevation [$c$s] is",
			"larger or equal to given in previous",
			"[$previous_setting[0]$previous_setting[1]]. Please optimize.");
			return 0;
		} else {
			$previous_size = ($c * $convert{$s});
		}
		
		@previous_setting = ($c, $s);
		
		$seconds += $c * $convert{$s};
	}
	
	return $seconds;
}

sub _set_errstr {
	$Convert::Age::errstr = join(" ", @_);
}

sub _get_errstr {
	return $Convert::Age::errstr;
}

sub decode_age_error {
	return $Convert::Age::errstr;
}

=head2 error

Returns error message string if if previous F<decode_strict()> failed. If
previous F<decode_strict()> operation was successful, empty string will be
returned.

=cut

sub error {
	&decode_age_error;
}

1;

__END__

=head1 AUTHOR

Chris Fedde, C<< <cfedde at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-convert-age at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Convert-Age>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Convert::Age

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Convert-Age>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Convert-Age>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Convert-Age>

=item * Search CPAN

L<http://search.cpan.org/dist/Convert-Age>

=back

=head1 ACKNOWLEDGEMENTS

Normunds Neimanis, C<< <normunds at cpan.org> >>

Added decode_strict() and related tests.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Chris Fedde, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

