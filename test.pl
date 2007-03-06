#!/usr/bin/perl

use strict;
use lib "./lib/Config";
use Basic;
use IO::All;

use Data::Dumper;

my $data_file = "haproxy.cfg";
my @data      = io( $data_file )->chomp->slurp;
my $a         = Config::Basic->new(
    -data => \@data,
#-file => "haproxy.cfg",
    -sections => [ 'global', '#\s+listen', 'listen', 'defaults' ],
);

#print Dumper($a->target);
#print Dumper( $a->sections );
#print $a->sections ;
my $res = $a->parse();

my ($s ,$p)= $a->sections() ;
print "*s" x 100 ."\n";
print Dumper( $s );
print "*p" x 100 ."\n";
print Dumper( $p );
print "*r" x 100 ."\n";
print Dumper( $res );
print "*" x 100 ."\n";
my ($se,$start) = $a->get_section( $res->{ '#\s+listen' }[0] );
print Dumper( $se );
print "=" x 100 ."\n";
#use Config::General;
# my %re = ParseConfig( -String => $se);
##my $se = $a->parse_section( $res->{ listen }[1] );
#print Dumper( \%re );
#print "=" x 100 ."\n";
#print Dumper( $res );

#print $a->target( "haproxy1.cfg" ) . "\n";
#
#print Dumper( $res );
#print Dumper( ( $res->{ global }[0] ) );
#my $se = $a->parse_section( $res->{ listen }[1] );
#print Dumper( $se );
#
#my $res = $a->parse;
#print Dumper( \@data );
