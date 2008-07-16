%module QRNG

%include "typemaps.i"
%include "gsl_typemaps.i"

%apply double *OUTPUT { double x[] };


%typemap(argout) double x[] {
    AV *tempav;
    I32 len;
    int i;
    SV **tv;
    if (argvi >= items) {            
        EXTEND(sp,1);              
    }
    $result = sv_newmortal();
    sv_setnv($result,(NV) *($1));
    argvi++;

    $result = sv_newmortal();
    sv_setnv($result,(NV) *($1+1));
    argvi++;
}

%{
    #include "gsl/gsl_types.h"
    #include "gsl/gsl_qrng.h"
%}

%include "gsl/gsl_types.h"
%include "gsl/gsl_qrng.h"

%perlcode %{

@EXPORT_OK = qw($gsl_qrng_niederreiter_2 $gsl_qrng_sobol $gsl_qrng_halton $gsl_qrng_reversehalton
                gsl_qrng_alloc gsl_qrng_memcpy gsl_qrng_clone
                gsl_qrng_free  gsl_qrng_init gsl_qrng_name 
                gsl_qrng_size gsl_qrng_state gsl_qrng_get
            );
%EXPORT_TAGS = ( all => [ @EXPORT_OK ] );


__END__

=head1 NAME

Math::GSL::QRNG - Quasi-random number generator

=head1 SYNOPSIS

use Math::GSL::QRNG qw/:all/;

=head1 DESCRIPTION

Here is a list of all the functions included in this module :

=over

=item C<gsl_qrng_alloc($T, $n)> - This function returns a pointer to a newly-created instance of a quasi-random sequence generator of type $T and dimension $d. The type $T must be one of the constants included in this module.


=item C<gsl_qrng_clone>

=item C<gsl_qrng_memcpy> - 

=item C<gsl_qrng_free($q)> - This function frees all the memory associated with the generator $q. 

=item C<gsl_qrng_init($q)> - This function reinitializes the generator $q to its starting point. Note that quasi-random sequences do not use a seed and always produce the same set of values. 

=item C<gsl_qrng_name($q)> - This function returns a pointer to the name of the generator $q. 

=item C<gsl_qrng_size>

=item C<gsl_qrng_state>

=item C<gsl_qrng_get>

=back

This module also contains the following constants : 

=over

=item C<$gsl_qrng_niederreiter_2>

=item C<$gsl_qrng_sobol> 

=item C<$gsl_qrng_halton> 

=item C<$gsl_qrng_reversehalton>

=back

For more informations on the functions, we refer you to the GSL offcial documentation: L<http://www.gnu.org/software/gsl/manual/html_node/>

Tip : search on google: site:http://www.gnu.org/software/gsl/manual/html_node/ name_of_the_function_you_want


=head1 EXAMPLES

=head1 AUTHOR

Jonathan Leto <jonathan@leto.net> and Thierry Moisan <thierry.moisan@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 Jonathan Leto and Thierry Moisan

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
%}
