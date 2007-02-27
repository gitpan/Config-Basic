###########################################################
# Tie::Countloop package
# Gnu GPL2 license
#
# $Id: Basic.pm,v 1.8 2006/12/12 13:10:00 fabrice Exp $
# $Revision: 1.8 $
#
# Fabrice Dulaunoy <fabrice@dulaunoy.com>
###########################################################
# ChangeLog:
#
###########################################################=

=head1 SYNOPSIS

=over 3

B<Config::Basic>

	A basic config parser
	for file where a section start at first column and end when a new section appear

=back

=cut

package Config::Basic;
use strict;
use Carp;
use IO::All;

use fields qw{ sections target };
use vars qw($VERSION);

$VERSION = do { my @rev = ( q$Revision: 1.8 $ =~ /\d+/g ); sprintf "%d." . "%d" x $#rev, @rev };


use Data::Dumper;
###########################################################################

###########################################################################
### 			class creator					###
###########################################################################

=head1 METHODS
	
	OO interface

=head3 new

=over

Create a new parser 

=over

"sections" = an ARRAY with all possible section
"-target	a file name to parse or a ref ARRAY with the data to parse
"-data"	  	is a synonym of "-target"
"-file"	  	is a synonym of "-target"

my $a  = B<Config::Basic>->new(
    	-data => \@data,
    	-sections => [ 'global', 'listen', 'defaults' ],
);	

=back

=back

=cut

sub new
{
    my ( $class ) = shift;
    no strict "refs";
    my $fields_ref = \%{ "${class}::FIELDS" };
    my $self       = [$fields_ref];
    $self->{ sections }   = { @_ }->{ -sections };
    $self->{ target }     = { @_ }->{ -file } || { @_ }->{ -data } || { @_ }->{ -target };
    bless( $self, $class );
    return $self;
}
###########################################################################

###########################################################################
### 			get/set method for the target object 		###
###########################################################################

=head3 target

	get/set the target in use

	my $target = $a->target(  ) . "\n";		# return the current target	
	my $target =  $a->target( "new.cfg" ) . "\n";	# change the target to the file "new.cfg" 
							and return the new target (here the file name)
	my $target = $a->target( \@data ) . "\n";	# change the target to the a ARRAY ref 
							and return the new target (her the ARRAY ref)

=cut	

sub target
{
    my $self   = shift;
    my $object = shift;
    if ( $object )
    {
        $self->{ target } = $object;
    }
    return $self->{ target };
}
###########################################################################

###########################################################################
### 			get/set  method for the sections		###
##"		sections are a ARRAY  of all possible section		###
###########################################################################


=head3 sections

	get/set the sections to use


	my $sect = $a->sections(  ) . "\n";				# return  a ARRAY ref with the current sections	
	my $new_sect = $a->sections( [ 'all', 'server' ]  ) . "\n"; 	# set a new set of sections and 
									return a ARRAY ref with the current sections

=cut	


sub sections
{
    my $self   = shift;
    my $object = shift;
    if ( $object )
    {
        $self->{ sections } = $object;
    }
    return $self->{ sections };
}
###########################################################################


##########################################################################
### 		method to retrieve a section				###
###			Param: a ref hash with start and end line	###
###			 {						###
###			        'end' => 25,				###
###			         start' => 8				###
###			 }						###
###									###
###########################################################################

=head3 get_section

	method to retrieve a section.
	the method expect a ref to a HASH with { start => "start_line" , end => "end_line" }


	my $se = $a->get_section( $res->{ listen }[1] );   # return 3 element:
			start line
			end line
			ARRAY ref with the content of the section

=cut	


sub get_section
{
    my $self   = shift;
    my $object = shift;
    my @all;
    if ( !( ref $self->{ target } ) )
    {
        @all = io( ( $self->{ target } ) )->chomp->slurp;
    }
    else
    {
        @all = @{ $self->{ target } };
    }
    my @section = splice @all, $object->{ start }, $object->{ end } - $object->{ start };

    return  $object->{ start }, $object->{ end } , \@section ;

}
###########################################################################

###########################################################################
### 			parse the target and return a ref to a hash 	###
###			where each section contain a array of hash 	###
###			with start  and end line (fisrt line = 0)	###
###									###         
###	   { 	 'global' => [						###
###                        {						###
###                          'end' => 8,				###
###                          'start' => 0				###
###                        }						###
###                      ]						###
###        }								###
###########################################################################


=head3 parse

	method to parse a target
	the method return a ref  to an HASH. 
	Each key are a section.
	Each value contain a ref to an ARRAY with a ref to a HASH for each section seen in the target

	my $se = $a->get_section( $res->{ listen }[1] );   # return ARRAY ref with the content of the section

=cut	

sub parse
{
    my $self = shift;
    my %sect;
    foreach ( @{ ( $self->{ sections } ) } )
    {
        $sect{ $_ } = [];
    }

    my @all;
    if ( !( ref $self->{ target } ) )
    {
        @all = io( ( $self->{ target } ) )->chomp->slurp;

    }
    else
    {
        @all = @{ $self->{ target } };
    }

    my $line_nbr = -1;
    my $seen;
    my $start;
    my $end;
    my $seen_regex;

    foreach my $line ( @all )
    {
        $line_nbr++;
	foreach my $regex (@{  $self->{ sections } })
	{
        if ( $line =~ m/^($regex)/g )
        {    
            if ( $seen )
            {
                $end = $line_nbr;
                my @tmp = @{ $sect{ $seen_regex } };
                my %range;
                $range{ start } = $start;
                $range{ end }   = $end;
                push @tmp, \%range;
                $sect{ $seen_regex } = \@tmp;
                $start               = $line_nbr;
                $seen_regex          = $regex;
            }
            else
            {
                $seen_regex = $regex;
                $start      = $line_nbr;
                $seen ^= 1;
            }
        }
    }
    }

    if ( $seen )
    {
        $line_nbr++;
        my @tmp = @{ $sect{ $seen_regex } };
        my %range;
        $range{ start } = $start;
        $range{ end }   = $line_nbr;
        push @tmp, \%range;
        $sect{ $seen_regex } = \@tmp;
    }
    return \%sect;
}
###########################################################################

1;

__END__

=pod

=begin readme


=head1 EXAMPLES

Parse a file like this (named here test1.cfg)


###########################################################################

	global
		daemon
		max		10000    
		log 127.0.0.1 local0 notice
		pidfile  /var/run/running.pid
		nbproc	2

	defaults
		mode	application
		option	dontlognull
		option	closeonexit
		retries	1
		contimeout	5000
	special  extra value
		item	1
		item	2	
	server	192.168.1.2
		log	global
		option	test
		type	fw 750
	server	192.168.1.3
		log	local
		option	test
		type	pw 800
		
###########################################################################	


	#!/usr/bin/perl
        use strict;
        use Config::Basic;
        use Data::Dumper;
        use Config::General;

        my $data_file = "test1.cfg";
        my $a = Config::Basic->new(
            -file     => "test1.cfg",
            -sections => [ 'global', 'server', 'defaults' ],
        );

        print Dumper( $a->sections );
        my $res = $a->parse();
        print Dumper( $res );

        my $se = $a->get_section( $res->{ server }[1] );

        my %re = ParseConfig( -String => $se );
        print Dumper( \%re );
        print Dumper( $a->sections( [ 'global', 'server', 'special', 'defaults' ] ) );
        $res = $a->parse();
        print Dumper( $res );

        $se = $a->get_section( $res->{ special }[0] );
        print Dumper( $se )

=end readme

=head1 AUTHOR

Fabrice Dulaunoy <fabrice[at]dulaunoy[dot]com>

07 december 2006

=head1 LICENSE

Under the GNU GPL2

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public 
License as published by the Free Software Foundation; either version 2 of the License, 
or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; 
if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

B<Config::Basic> Copyright (C) 2006 DULAUNOY Fabrice. B<Config::Basic> comes with ABSOLUTELY NO WARRANTY; 
for details See: L<http://www.gnu.org/licenses/gpl.html> 
This is free software, and you are welcome to redistribute it under certain conditions;
