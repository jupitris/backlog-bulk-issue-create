#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;

use LWP::UserAgent;
use HTTP::Request::Common;
use Config::Tiny;
use Text::CSV_XS qw(csv);
use Encode qw(decode encode);

use Getopt::Long;
use Carp qw(croak);
use Data::Dumper;

my %opts = ( file => 'issue.csv', ignore => 1, verbose => 1 );
GetOptions(\%opts, qw( file=s ignore verbose) );

foreach my $field ( qw( file ) ){
    if ( ! exists $opts{$field} ){
        croak "$field is required.";
    }
}

my $Config = Config::Tiny->read( 'app.conf' );
my $spc = $Config->{user}->{space};
my $key = $Config->{api}->{key};
my $url = "https://${spc}.backlog.jp/api/v2/issues?apiKey=${key}";
my $ua  = LWP::UserAgent->new;

my @field_names = qw/ projectId summary parentIssueId description startDate dueDate estimatedHours actualHours issueTypeId categoryId versionId milestoneId priorityId assigneeId /;
my $file = $opts{file};
my $csv = Text::CSV_XS->new({ binary => 1, eol => $/, auto_diag => 1 });
open my $fh, "<:utf8", $file or croak "$file: $!"; #">

# ignore = 1のときは、1行目をfieldとみなして無視する
$csv->getline($fh) if $opts{'ignore'};

while (my $row = $csv->getline($fh)) {
    my %fields;

    for (my $i = 0; $i <= $#field_names; $i++) {
        $fields{$field_names[$i]} = @$row[$i];
    }

    #print "$fields{'projectId'} $fields{'summary'} $fields{'startDate'} $fields{'dueDate'}\n";
    my %postdata = (
        projectId      => $fields{'projectId'} + 0,
        summary        => encode('UTF-8', $fields{'summary'}),
        #parentIssueId  => $fields{'parentIssueId'} + 0,
        description    => encode('UTF-8', $fields{'description'}),
        startDate      => $fields{'startDate'},
        dueDate        => $fields{'dueDate'},
        estimatedHours => $fields{'estimatedHours'} + 0,
        actualHours    => $fields{'actualHours'} + 0,
        issueTypeId    => $fields{'issueTypeId'} + 0,
        'categoryId[]'   => $fields{'categoryId'} + 0,
        'versionId[]'    => $fields{'versionId'} + 0,
        'milestoneId[]'  => $fields{'milestoneId'} + 0,
        priorityId     => $fields{'priorityId'} + 0,
        assigneeId     => $fields{'assigneeId'} + 0,
    );
    my $req = POST($url, \%postdata);
    my $res = $ua->request($req)->as_string;
    print Dumper $res;
}
