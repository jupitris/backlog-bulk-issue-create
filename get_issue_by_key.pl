#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;

use JSON;
use LWP::UserAgent;
use HTTP::Request::Common;
use Config::Tiny;
use Encode qw(decode encode);

use Getopt::Long;
use Carp qw(croak);
use Data::Dumper;

binmode(STDOUT, ":utf8");

my %opts = ( key => '', verbose => 1 );
GetOptions(\%opts, qw( key=s verbose) );

foreach my $field ( qw( key ) ){
    if ( ! exists $opts{$field} ){
        croak "$field is required.";
    }
}

my $Config = Config::Tiny->read( 'app.conf' );
my $spc = $Config->{user}->{space};
my $key = $Config->{api}->{key};
my $url = "https://${spc}.backlog.jp/api/v2/issues/$opts{'key'}?apiKey=${key}";
my $ua  = LWP::UserAgent->new;

my $req = GET($url);
my $res = $ua->request($req);
my $json = decode_json($res->content);
print Dumper $json;
