package DBIx::DBH;

use 5.006001;
use strict;
use warnings;

use Data::Dumper;

use DBI;
use Params::Validate qw( :all );

#use DBIx::DBH::mysql;
#use DBIx::DBH::Pg;


require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use DBIx::DBH ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.03';


our @attr = qw
  (  
   dbi_connect_method
   Warn

   _Active
   _Executed
   _Kids
   _ActiveKids
   _CachedKids
   _CompatMode

   InactiveDestroy
   PrintWarn
   PrintError
   RaiseError
   HandleError
   HandleSetErr

   _ErrCount

   ShowErrorStatement
   TraceLevel
   FetchHashKeyName
   ChopBlanks
   LongReadLen
   LongTruncOk
   TaintIn
   TaintOut
   Taint
   Profile
   _should-add-support-for-private_your_module_name_*


   AutoCommit

   _Driver
   _Name
   _Statement

   RowCacheSize

   _Username
  );

# Preloaded methods go here.

Params::Validate::validation_options(allow_extra => 1);

sub connect {

  my @connect_data = connect_data(@_);

  my $dbh;
  eval
    {
      $dbh = DBI->connect( @connect_data );
    };

  die $@ if $@;
  die 'Unable to connect to database' unless $dbh;

  return $dbh;

}

sub dbi_attr {
  my ($h, %p) = @_;

  $h = {} unless defined $h;

  for my $attr (@attr) {
    if (exists $p{$attr}) {
#      warn "$attr = $p{$attr};";
      $h->{$attr} = $p{$attr};
    }
  }

  $h;
}

sub connect_data {

  my $class = shift;
  my %p = @_;

  %p = validate( @_, { vendor => { callbacks =>
				   { 'only valid vendors are mysql and Pg' =>
				     sub { $_[0] =~ /mysql|Pg/ } }}} ) ;

  my $subclass = "DBIx::DBH::$p{vendor}";

  my $eval_string = "require $subclass";

  eval $eval_string;

  my ($dsn, $user, $pass, $attr) = $subclass->connect_data(@_);
  $attr = dbi_attr($attr, %p);

  ($dsn, $user, $pass, $attr)

}

sub form_dsn {

  (connect_data(@_))[0];

}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

 DBIx::DBH - Perl extension for simplifying database connections

=head1 ABSTRACT

DBIx::DBH is designed to facilitate and validate the process of creating 
DBI database connections.
It's chief and unique contribution to this set of modules on CPAN is that
it forms the DSN string for you, regardless of database vendor. Another thing 
about this module is that
it takes a Perl hash as input, making it ideal for converting HTTP form data
and or config file information into DBI database handles. It also can form
DSN strings for both major free databases and is subclassed to support
extension for other databases.

DBIx::DBH provides rigorous validation on the input parameters via
L<Params::Validate>. It does not
allow parameters which are not defined by the DBI or the database vendor
driver into the hash.

=head1 DBIx::DBH API

=head2 $dbh = connect(%params)

C<%params> requires the following as keys:

=over 4

=item * vendor : the value matches /\a(mysql|Pg)\Z/ (case-sensitive).

=item * dbname : the value is the name of the database to connect to

=back

C<%params> can have the following optional parameters

=over 4

=item * user

=item * password

=item * host

=item * port

=back

C<%params> can also have parameters specific to a particular database
vendor. See
L<DBIx::DBH::mysql> and L<BIx::DBH::Pg> for additional parameters
acceptable based on database vendor.

=head2 ($dsn, $user, $pass, $attr) = connect_data(%params)

C<connect_data> takes the same arguments as C<connect()> but returns
a list of the 4 arguments required by the L<DBI> C<connect()>
function. This is useful for working with modules that have an
alternative connection syntax such as L<DBIx::AnyDBD> or 
L<Alzabo>.

=head1 AUTHOR

Terrence Brannon, E<lt>bauhaus@metaperl.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Terrence Brannon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
