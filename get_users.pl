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

my %opts = ( verbose => 1 );
GetOptions(\%opts, qw( verbose) );

my $Config = Config::Tiny->read( 'app.conf' );
my $spc = $Config->{user}->{space};
my $key = $Config->{api}->{key};
my $url = "https://${spc}.backlog.jp/api/v2/users?apiKey=${key}";
my $ua  = LWP::UserAgent->new;

my $req = GET($url);
my $res = $ua->request($req);
my $json = JSON->new()->decode($res->content);
#print Dumper $json;

print "id,userId,name,mailAddress,nulabAccount,lang,roleType\n";
foreach my $item (@$json) {
    my $nulab_account = $item->{nulabAccount};
    if ($nulab_account) {
        my $nulab_id   = $nulab_account->{nulabId};
        my $nulab_name = $nulab_account->{name};
        my $unique_id  = $nulab_account->{uniqueId};
        printf "%d,%s,%s,%s,%s,%s,%s,%s,%d\n", $item->{id}, $item->{userId}, decode('UTF-8', $item->{name}), $item->{mailAddress}, $nulab_id, decode('UTF-8', $nulab_name), $unique_id, $item->{lang}, $item->{roleType};
    } else {
        printf "%d,%s,%s,%s,%s,%s,%d\n", $item->{id}, $item->{userId} ? $item->{userId} : '', decode('UTF-8', $item->{name}), $item->{mailAddress}, '', $item->{lang} ? $item->{lang} : '', $item->{roleType};
}
    }


