use NativeCall;

my class TimeStruct is repr<CStruct> {
    has int32 $.tm_sec;
    has int32 $.tm_min;
    has int32 $.tm_hour;
    has int32 $.tm_mday;
    has int32 $.tm_mon;
    has int32 $.tm_year;
    has int32 $.tm_wday;
    has int32 $.tm_yday;
    has int32 $.tm_isdst;
    has long  $.tm_gmtoff;
    has Str   $.tm_zone;

    method list() {
        ($.tm_sec, $.tm_min, $.tm_hour, $.tm_mday,  $.tm_mon, $.tm_year,
         $.tm_wday,$.tm_yday,$.tm_isdst,$.tm_gmtoff,$.tm_zone)
    }
}

# actual NativeCall interfaces
my sub get-localtime(int64 is rw --> TimeStruct)
  is native is symbol<localtime> {*}
my sub get-ctime(int64 is rw --> Str)
  is native is symbol<ctime> {*}
my sub get-gmtime(int64 is rw --> TimeStruct)
  is native is symbol<gmtime> {*}

# actual exported subs
my proto sub localtime(|) is export {*}
multi sub localtime(Scalar:U, Int() $time = time) {
    my int64 $epoch = $time;
    get-ctime($epoch).chomp
}
multi sub localtime(Int() $time = time) {
    my int64 $epoch = $time;
    get-localtime($epoch).list
}

my proto sub gmtime(|) is export {*}
multi sub gmtime(Scalar:U, Int() $time = time) {
    my int64 $epoch = $time;
    $epoch -= get-localtime($epoch).tm_gmtoff;
    get-ctime($epoch).chomp
}
multi sub gmtime(Int() $time = time) {
    my int64 $epoch = $time;
    get-gmtime($epoch).list
}

=begin pod

=head1 NAME

Raku port of Perl's localtime / gmtime built-ins

=head1 SYNOPSIS

    use P5localtime;

    #     0    1    2     3     4    5     6     7     8
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    say localtime(Scalar, time);

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
    say gmtime(Scalar, time);

=head1 DESCRIPTION

This module tries to mimic the behaviour of Perl's C<localtime> and C<gmtime>
built-ins as closely as possible in the Raku Programmming Language.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    localtime EXPR
    localtime
            Converts a time as returned by the time function to a 9-element
            list with the time analyzed for the local time zone. Typically
            used as follows:

                #  0    1    2     3     4    5     6     7     8
                ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                            localtime(time);

            All list elements are numeric and come straight out of the C
            `struct tm'. $sec, $min, and $hour are the seconds, minutes, and
            hours of the specified time.

            $mday is the day of the month and $mon the month in the range
            0..11, with 0 indicating January and 11 indicating December. This
            makes it easy to get a month name from a list:

                my @abbr = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
                print "$abbr[$mon] $mday";
                # $mon=9, $mday=18 gives "Oct 18"

            $year contains the number of years since 1900. To get a 4-digit
            year write:

                $year += 1900;

            To get the last two digits of the year (e.g., "01" in 2001) do:

                $year = sprintf("%02d", $year % 100);

            $wday is the day of the week, with 0 indicating Sunday and 3
            indicating Wednesday. $yday is the day of the year, in the range
            0..364 (or 0..365 in leap years.)

            $isdst is true if the specified time occurs during Daylight Saving
            Time, false otherwise.

            If EXPR is omitted, "localtime()" uses the current time (as
            returned by time(3)).

            In scalar context, "localtime()" returns the ctime(3) value:

                $now_string = localtime;  # e.g., "Thu Oct 13 04:54:34 1994"

            The format of this scalar value is not locale-dependent but built
            into Perl. For GMT instead of local time use the "gmtime" builtin.
            See also the "Time::Local" module (for converting seconds,
            minutes, hours, and such back to the integer value returned by
            time()), and the POSIX module's strftime(3) and mktime(3)
            functions.

            To get somewhat similar but locale-dependent date strings, set up
            your locale environment variables appropriately (please see
            perllocale) and try for example:

                use POSIX qw(strftime);
                $now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;
                # or for GMT formatted appropriately for your locale:
                $now_string = strftime "%a %b %e %H:%M:%S %Y", gmtime;

            Note that the %a and %b, the short forms of the day of the week
            and the month of the year, may not necessarily be three characters
            wide.

            The Time::gmtime and Time::localtime modules provide a convenient,
            by-name access mechanism to the gmtime() and localtime()
            functions, respectively.

            For a comprehensive date and time representation look at the
            DateTime module on CPAN.

            Portability issues: "localtime" in perlport.

    gmtime EXPR
    gmtime  Works just like "localtime" but the returned values are localized
            for the standard Greenwich time zone.

            Note: When called in list context, $isdst, the last value returned
            by gmtime, is always 0. There is no Daylight Saving Time in GMT.

            Portability issues: "gmtime" in perlport.

=head1 PORTING CAVEATS

=head2 Mimicking scalar context

Since Raku does not have a concept of scalar context, this must be mimiced
by passing the C<Scalar> type as the first positional parameter.

The implementation actually also returns the offset in GMT in seconds as
element number 9, and the name of the timezone as element number 10, if
supported by the OS.

=head2 Depends on POSIX semantics

This module depends on the availability of POSIX semantics.  This is
generally not available on Windows, so this module will probably not work
on Windows.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

Source can be located at: https://github.com/lizmat/P5localtime . Comments and
Pull Requests are welcome.

=head1 ACKNOWLEDGEMENTS

JJ Merelo, Jan-Olof Hendig, Tobias Leich, Timo Paulssen and Christoph (on
StackOverflow) for support in getting this to work.

=head1 COPYRIGHT AND LICENSE

Copyright 2018, 2019, 2020, 2021, 2023 Elizabeth Mattijsen

Re-imagined from Perl as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
