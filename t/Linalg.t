package Math::GSL::Linalg::Test;
use base q{Test::Class};
use Test::More;
use Math::GSL              qw/:all/;
use Math::GSL::BLAS        qw/:all/;
use Math::GSL::Test        qw/:all/;
use Math::GSL::CBLAS       qw/:all/;
use Math::GSL::Errno       qw/:all/;
use Math::GSL::Linalg      qw/:all/;
use Math::GSL::Matrix      qw/:all/;
use Math::GSL::MatrixComplex qw/:all/;
use Math::GSL::Vector      qw/:all/;
use Math::GSL::Machine     qw/:all/;
use Math::GSL::Complex     qw/:all/;
use Math::GSL::Permutation qw/:all/;
use Math::Complex;
use Data::Dumper;
use strict;
use warnings;

BEGIN { gsl_set_error_handler_off() }

sub make_fixture : Test(setup) {
    my $self = shift;
    $self->{matrix} = gsl_matrix_alloc(4, 4);
}

sub teardown : Test(teardown) {
    unlink 'linalg' if -f 'linalg';
}

sub GSL_GIVENS : Tests {
    my $version= gsl_version();
    my ($major, $minor, $tiny) = split /\./, $version;
    if ($major >= 2) {
        my ($a,$b) = (1.0,0.0);
        my ($c, $s) = gsl_linalg_givens($a, $b);
        ok_similar( [$c, $s], [1,0], "givens rotation with 1,0")
    }
}

sub GSL_LINALG_LU_DECOMP : Tests {
    my $base = Math::GSL::Matrix->new(4,4);
    $base->set_row(0, [0,1,2,3])
         ->set_row(1, [5,6,7,8])
         ->set_row(2, [9,10,11,12])
         ->set_row(3, [13,14,15,16]);
    my $permutation = gsl_permutation_alloc(4);
    gsl_permutation_init($permutation);
    my $first = Math::GSL::Matrix->new(4,4);
    gsl_matrix_memcpy($first->raw, $base->raw);

    my ($result, $signum) = gsl_linalg_LU_decomp($base->raw, $permutation);
    my $version= gsl_version();
    my ($major, $minor) = split /\./, $version;
    if ($major >= 2 && $minor >= 8) {
        # From version 2.8 onwards, the result value for a singular matrix is an integer
        #  such that U(i,i) = 0
        # TODO: For some reason this is not the case on macOS yet
        is_deeply( [ $result, $signum ], [ 4, 1] );
    }
    else {
        is_deeply( [ $result, $signum ], [ 0, 1] );
    }

    my $U = Math::GSL::Matrix->new(4,4);
    my $R = Math::GSL::Matrix->new(4,4);
    my $L = Math::GSL::Matrix->new(4,4);
    gsl_matrix_set_identity($L->raw);
    my $line;
    for ($line=3; $line>-1; $line--) {
     map { gsl_matrix_set($U->raw, $line, $_, gsl_matrix_get($base->raw, $line, $_)) } ($line..3) };
    for ($line=3; $line>1; $line--) {
     map { gsl_matrix_set($L->raw, $line, $_, gsl_matrix_get($base->raw, $line, $_)) } (0..$line-1) };
    gsl_blas_dgemm($CblasNoTrans, $CblasNoTrans, 1, $L->raw, $U->raw, 1, $R->raw);
    my @permutations = map { gsl_permutation_get($permutation, $_) } (0..3);
    map {
    my @got = $first->row($permutations[$_])->as_list;
    my @results = $R->row($_)->as_list;
    ok_similar([@got], [@results], "resulting row $_"); } (0..3);
}

sub GSL_LINALG_LU_SOLVE : Tests {
    local $TODO = "the data in this test is suspect";
    return;
    my $self = shift;

    gsl_matrix_set($self->{matrix}, 0, 0, 1);
    gsl_matrix_set($self->{matrix}, 0, 1, 1);
    gsl_matrix_set($self->{matrix}, 0, 2, 2);
    gsl_matrix_set($self->{matrix}, 0, 3, 1);

    gsl_matrix_set($self->{matrix}, 1, 0, 2);
    gsl_matrix_set($self->{matrix}, 1, 1, 3);
    gsl_matrix_set($self->{matrix}, 1, 2, -1);
    gsl_matrix_set($self->{matrix}, 1, 3, 2);

    gsl_matrix_set($self->{matrix}, 2, 0, 5);
    gsl_matrix_set($self->{matrix}, 2, 1, -1);
    gsl_matrix_set($self->{matrix}, 2, 2, 1);
    gsl_matrix_set($self->{matrix}, 2, 3, -1);

    gsl_matrix_set($self->{matrix}, 3, 0, 1);
    gsl_matrix_set($self->{matrix}, 3, 1, 0);
    gsl_matrix_set($self->{matrix}, 3, 2, 7);
    gsl_matrix_set($self->{matrix}, 3, 3, 1);

    my $b = gsl_vector_alloc(4);
    gsl_vector_set($b, 0, 4);
    gsl_vector_set($b, 1, 1);
    gsl_vector_set($b, 2, 2);
    gsl_vector_set($b, 3, 11);

    my $x = gsl_vector_alloc(4);

    my $permutation = gsl_permutation_alloc(4);
    gsl_permutation_init($permutation);
    gsl_linalg_LU_decomp($self->{matrix}, $permutation);
    gsl_linalg_LU_solve($self->{matrix}, $permutation, $b, $x);
    my $value = gsl_vector_get($x, 0);
    ok_similar(
        [ map { gsl_vector_get($x, $_) } (1..3) ],
        [ 3-10*$value, -2*$value+2, 13*$value-3 ]
    );
}

sub GSL_LINALG_LU_SVX : Tests {
    local $TODO = "the data in this test is suspect";
    return;
    my $self = shift;
    gsl_matrix_set($self->{matrix}, 0, 0, 1);
    gsl_matrix_set($self->{matrix}, 0, 1, 1);
    gsl_matrix_set($self->{matrix}, 0, 2, 2);
    gsl_matrix_set($self->{matrix}, 0, 3, 1);

    gsl_matrix_set($self->{matrix}, 1, 0, 2);
    gsl_matrix_set($self->{matrix}, 1, 1, 3);
    gsl_matrix_set($self->{matrix}, 1, 2, -1);
    gsl_matrix_set($self->{matrix}, 1, 3, 2);

    gsl_matrix_set($self->{matrix}, 2, 0, 5);
    gsl_matrix_set($self->{matrix}, 2, 1, -1);
    gsl_matrix_set($self->{matrix}, 2, 2, 1);
    gsl_matrix_set($self->{matrix}, 2, 3, -1);

    gsl_matrix_set($self->{matrix}, 3, 0, 1);
    gsl_matrix_set($self->{matrix}, 3, 1, 0);
    gsl_matrix_set($self->{matrix}, 3, 2, 7);
    gsl_matrix_set($self->{matrix}, 3, 3, 1);

    my $x = gsl_vector_alloc(4);
    gsl_vector_set($x, 0, 4);
    gsl_vector_set($x, 1, 1);
    gsl_vector_set($x, 2, 2);
    gsl_vector_set($x, 3, 11);

    my $permutation = gsl_permutation_alloc(4);
    gsl_permutation_init($permutation);
    gsl_linalg_LU_decomp($self->{matrix}, $permutation);
    gsl_linalg_LU_svx($self->{matrix}, $permutation, $x);
    my $value = gsl_vector_get($x, 0);
    ok_similar(
        [ map { gsl_vector_get($x, $_) } (1..3) ],
        [ 3-10*$value, -2*$value+2, 13*$value-3 ]
    );
}

sub GSL_LINALG_LU_INVERT : Tests {
    my $self = shift;
    map { gsl_matrix_set($self->{matrix}, 0, $_, $_+1) } (0..3);

    gsl_matrix_set($self->{matrix}, 1, 0, 2);
    gsl_matrix_set($self->{matrix}, 1, 1, 3);
    gsl_matrix_set($self->{matrix}, 1, 2, 4);
    gsl_matrix_set($self->{matrix}, 1, 3, 1);

    gsl_matrix_set($self->{matrix}, 2, 0, 3);
    gsl_matrix_set($self->{matrix}, 2, 1, 4);
    gsl_matrix_set($self->{matrix}, 2, 2, 1);
    gsl_matrix_set($self->{matrix}, 2, 3, 2);

    gsl_matrix_set($self->{matrix}, 3, 0, 4);
    gsl_matrix_set($self->{matrix}, 3, 1, 1);
    gsl_matrix_set($self->{matrix}, 3, 2, 2);
    gsl_matrix_set($self->{matrix}, 3, 3, 3);

    my $inverse = gsl_matrix_alloc(4,4);
    my $permutation = gsl_permutation_alloc(4);
    gsl_permutation_init($permutation);
    gsl_linalg_LU_decomp($self->{matrix}, $permutation);
    gsl_linalg_LU_invert($self->{matrix}, $permutation, $inverse);

    ok_similar(gsl_matrix_get($inverse, 0, 0), -9/40);
    ok_similar(gsl_matrix_get($inverse, 0, 1), 1/40);
    ok_similar(gsl_matrix_get($inverse, 0, 2), 1/40);
    ok_similar(gsl_matrix_get($inverse, 0, 3), 11/40);

    ok_similar(gsl_matrix_get($inverse, 1, 0), 1/40);
    ok_similar(gsl_matrix_get($inverse, 1, 1), 1/40);
    ok_similar(gsl_matrix_get($inverse, 1, 2), 11/40);
    ok_similar(gsl_matrix_get($inverse, 1, 3), -9/40);

    ok_similar(gsl_matrix_get($inverse, 2, 0), 1/40);
    ok_similar(gsl_matrix_get($inverse, 2, 1), 11/40);
    ok_similar(gsl_matrix_get($inverse, 2, 2), -9/40);
    ok_similar(gsl_matrix_get($inverse, 2, 3), 1/40);

    ok_similar(gsl_matrix_get($inverse, 3, 0), 11/40);
    ok_similar(gsl_matrix_get($inverse, 3, 1), -9/40);
    ok_similar(gsl_matrix_get($inverse, 3, 2), 1/40);
    ok_similar(gsl_matrix_get($inverse, 3, 3), 1/40);
}

sub GSL_LINALG_COMPLEX_LU_DET : Tests(2) {
    local $TODO = q{ $gsl_det is wrong or Math::Complex conversion is };
    my $m = Math::GSL::MatrixComplex->new(2,2)
                                 ->set_row(0, [ 1 , 2 ])
                                 ->set_row(1, [ 3 , 4*i ]);
    my $permutation = gsl_permutation_alloc(2);
    gsl_permutation_init($permutation);
    my $copy = $m->copy;
    my ($result, $signum) = gsl_linalg_complex_LU_decomp($copy->raw, $permutation);
    my $gsl_det = gsl_linalg_complex_LU_det($m->raw, $signum);
    my $det = Math::Complex->make( gsl_real($gsl_det), gsl_imag($gsl_det) );
    #warn Dumper [ $det ];
    ok_similar( [ Re $det ], [ -6 ], 'real');
    ok_similar( [ Im $det ], [ 4  ], 'imag');
}

sub GSL_LINALG_LU_DET : Tests {
    my $self = shift;
    map { gsl_matrix_set($self->{matrix}, 0, $_, $_+1) } (0..3);

    gsl_matrix_set($self->{matrix}, 1, 0, 2);
    gsl_matrix_set($self->{matrix}, 1, 1, 3);
    gsl_matrix_set($self->{matrix}, 1, 2, 4);
    gsl_matrix_set($self->{matrix}, 1, 3, 1);

    gsl_matrix_set($self->{matrix}, 2, 0, 3);
    gsl_matrix_set($self->{matrix}, 2, 1, 4);
    gsl_matrix_set($self->{matrix}, 2, 2, 1);
    gsl_matrix_set($self->{matrix}, 2, 3, 2);

    gsl_matrix_set($self->{matrix}, 3, 0, 4);
    gsl_matrix_set($self->{matrix}, 3, 1, 1);
    gsl_matrix_set($self->{matrix}, 3, 2, 2);
    gsl_matrix_set($self->{matrix}, 3, 3, 3);

    my $permutation = gsl_permutation_alloc(4);
    gsl_permutation_init($permutation);
    my ($result, $signum) = gsl_linalg_LU_decomp($self->{matrix}, $permutation);
    ok_similar(gsl_linalg_LU_det($self->{matrix}, $signum), 160);
}

sub GSL_LINALG_LU_LNDET : Tests {
    my $self = shift;
    map { gsl_matrix_set($self->{matrix}, 0, $_, $_+1) } (0..3);

    gsl_matrix_set($self->{matrix}, 1, 0, 2);
    gsl_matrix_set($self->{matrix}, 1, 1, 3);
    gsl_matrix_set($self->{matrix}, 1, 2, 4);
    gsl_matrix_set($self->{matrix}, 1, 3, 1);

    gsl_matrix_set($self->{matrix}, 2, 0, 3);
    gsl_matrix_set($self->{matrix}, 2, 1, 4);
    gsl_matrix_set($self->{matrix}, 2, 2, 1);
    gsl_matrix_set($self->{matrix}, 2, 3, 2);

    gsl_matrix_set($self->{matrix}, 3, 0, 4);
    gsl_matrix_set($self->{matrix}, 3, 1, 1);
    gsl_matrix_set($self->{matrix}, 3, 2, 2);
    gsl_matrix_set($self->{matrix}, 3, 3, 3);

    my $permutation = gsl_permutation_alloc(4);
    gsl_permutation_init($permutation);
    gsl_linalg_LU_decomp($self->{matrix}, $permutation);
    ok_similar(gsl_linalg_LU_lndet($self->{matrix}), log(160));
}

sub GSL_LINALG_QR_DECOMP : Tests {
    my $matrix = gsl_matrix_alloc(3,5);
    my ($i, $j);
    for($i=0; $i<3; $i++) {
     for($j=0; $j<5; $j++) {
       gsl_matrix_set($matrix, $i, $j, 1.0/($i+$j+1.0));
     }
    }

    my $tau = gsl_vector_alloc(3);
    my $q = gsl_matrix_alloc(3,3);
    my $r = gsl_matrix_alloc(3,5);
    my $a = gsl_matrix_alloc(3,5);
    my $save = gsl_matrix_alloc(3, 5);
    gsl_matrix_memcpy($save, $matrix);

    ok_status(gsl_linalg_QR_decomp($matrix, $tau));
    ok_similar(gsl_linalg_QR_unpack($matrix, $tau, $q, $r), 0);
  # compute a = q r
  gsl_blas_dgemm ($CblasNoTrans, $CblasNoTrans, 1.0, $q, $r, 0.0, $a);

  my ($aij, $mij);
  for($i=0; $i<3; $i++) {
    for($j=0; $j<5; $j++) {
      $aij = gsl_matrix_get($a, $i, $j);
      $mij = gsl_matrix_get($save, $i, $j);
      ok(is_similar_relative($aij, $mij, 2 * 8.0 * $GSL_DBL_EPSILON));
    }
  }

}

sub GSL_LINALG_CHOLESKY_DECOMP : Tests {
    my $self = shift;
    map{ gsl_matrix_set($self->{matrix}, 0, $_, $_+1)} (0..3);

    gsl_matrix_set($self->{matrix}, 1, 0, 2);
    gsl_matrix_set($self->{matrix}, 1, 1, 5);
    gsl_matrix_set($self->{matrix}, 1, 2, 8);
    gsl_matrix_set($self->{matrix}, 1, 3, 11);

    gsl_matrix_set($self->{matrix}, 2, 0, 3);
    gsl_matrix_set($self->{matrix}, 2, 1, 8);
    gsl_matrix_set($self->{matrix}, 2, 2, 14);
    gsl_matrix_set($self->{matrix}, 2, 3, 20);

    gsl_matrix_set($self->{matrix}, 3, 0, 4);
    gsl_matrix_set($self->{matrix}, 3, 1, 11);
    gsl_matrix_set($self->{matrix}, 3, 2, 20);
    gsl_matrix_set($self->{matrix}, 3, 3, 30);

    ok_status(gsl_linalg_cholesky_decomp($self->{matrix}));
    my $v = gsl_matrix_diagonal($self->{matrix});
    ok_similar(
        [ map { gsl_vector_get($v->{vector}, $_)} (0..3) ], [(1)x 4 ]
    );
    is_similar(gsl_matrix_get($self->{matrix}, 1, 0), 2);
    is_similar(gsl_matrix_get($self->{matrix}, 2, 0), 3);
    is_similar(gsl_matrix_get($self->{matrix}, 2, 1), 2);
    is_similar(gsl_matrix_get($self->{matrix}, 3, 0), 4);
    is_similar(gsl_matrix_get($self->{matrix}, 3, 1), 3);
    is_similar(gsl_matrix_get($self->{matrix}, 3, 2), 2);
}
sub GSL_LINALG_HESSENBERG_DECOMP_UNPACK_UNPACK_ACCUM_SET_ZERO : Tests {
    my $self = shift;

    gsl_matrix_set($self->{matrix}, 1, 0, 3);
    gsl_matrix_set($self->{matrix}, 1, 1, 2);
    gsl_matrix_set($self->{matrix}, 1, 2, 5);
    gsl_matrix_set($self->{matrix}, 1, 3, -4);

    gsl_matrix_set($self->{matrix}, 1, 0, 5);
    gsl_matrix_set($self->{matrix}, 1, 1, -3);
    gsl_matrix_set($self->{matrix}, 1, 2, 6);
    gsl_matrix_set($self->{matrix}, 1, 3, 9);

    gsl_matrix_set($self->{matrix}, 2, 0, -2);
    gsl_matrix_set($self->{matrix}, 2, 1, 1);
    gsl_matrix_set($self->{matrix}, 2, 2, 5);
    gsl_matrix_set($self->{matrix}, 2, 3, 8);

    gsl_matrix_set($self->{matrix}, 3, 0, -6);
    gsl_matrix_set($self->{matrix}, 3, 1, 7);
    gsl_matrix_set($self->{matrix}, 3, 2, 2);
    gsl_matrix_set($self->{matrix}, 3, 3, -8);
    my $tau = gsl_vector_alloc(4);
    ok_status(gsl_linalg_hessenberg_decomp($self->{matrix}, $tau));
    my $U = gsl_matrix_alloc(4,4);
    ok_status(gsl_linalg_hessenberg_unpack($self->{matrix}, $tau, $U));
    ok_similar(gsl_matrix_get($U, 0, 0), 1);

    ok_similar( [ map { gsl_matrix_get($U, $_, 0), 0 } (1..3) ], [ 0, 0, 0, 0, 0, 0 ]);

    ok_similar( [ map { gsl_matrix_get($U, 0, $_), 0 } (1..3) ], [ 0, 0, 0, 0, 0, 0 ]);

    ok_similar(gsl_matrix_get($U, 1, 1), -0.620173672946042309);
    ok_similar(gsl_matrix_get($U, 1, 2), -0.268847804615518438);
    ok_similar(gsl_matrix_get($U, 1, 3), 0.736956900597335762);
    ok_similar(gsl_matrix_get($U, 2, 1), 0.248069469178416908);
    ok_similar(gsl_matrix_get($U, 2, 2), -0.958442423454322956);
    ok_similar(gsl_matrix_get($U, 2, 3), -0.140888819231843737);
    ok_similar(gsl_matrix_get($U, 3, 1), 0.744208407535250749);
    ok_similar(gsl_matrix_get($U, 3, 2), 0.0954409706385089263);
    ok_similar(gsl_matrix_get($U, 3, 3), 0.661093690241727594);

    my $V = gsl_matrix_alloc(4,4);
    ok_status( gsl_linalg_hessenberg_unpack_accum($self->{matrix}, $tau, $V), 0); #I don't know how to test the result of this function...

    ok_status( gsl_linalg_hessenberg_set_zero($self->{matrix}) );
    for(my $line = 2; $line<4; $line++) {
        map { ok_similar(gsl_matrix_get($self->{matrix}, $line, $_), 0, "Set zero", 1e-8) } (0..$line-2);
    }
}

sub GSL_LINALG_BIDIAG_DECOMP_UNPACK_UNPACK2_UNPACK_B : Tests {
    my $self = shift;
    gsl_matrix_set($self->{matrix}, 1, 0, 3);
    gsl_matrix_set($self->{matrix}, 1, 1, 2);
    gsl_matrix_set($self->{matrix}, 1, 2, 5);
    gsl_matrix_set($self->{matrix}, 1, 3, -4);

    gsl_matrix_set($self->{matrix}, 1, 0, 5);
    gsl_matrix_set($self->{matrix}, 1, 1, -3);
    gsl_matrix_set($self->{matrix}, 1, 2, 6);
    gsl_matrix_set($self->{matrix}, 1, 3, 9);

    gsl_matrix_set($self->{matrix}, 2, 0, -2);
    gsl_matrix_set($self->{matrix}, 2, 1, 1);
    gsl_matrix_set($self->{matrix}, 2, 2, 5);
    gsl_matrix_set($self->{matrix}, 2, 3, 8);

    gsl_matrix_set($self->{matrix}, 3, 0, -6);
    gsl_matrix_set($self->{matrix}, 3, 1, 7);
    gsl_matrix_set($self->{matrix}, 3, 2, 2);
    gsl_matrix_set($self->{matrix}, 3, 3, -8);
    my $tau_U = gsl_vector_alloc(4);
    my $tau_V = gsl_vector_alloc(3);

    ok_status(gsl_linalg_bidiag_decomp($self->{matrix}, $tau_U, $tau_V));
    my $U = gsl_matrix_alloc(4,4);
    my $V = gsl_matrix_alloc(4,4);
    my $diag = gsl_vector_alloc(4);
    my $superdiag = gsl_vector_alloc(3);
    ok_status(gsl_linalg_bidiag_unpack($self->{matrix}, $tau_U, $U, $tau_V, $V, $diag, $superdiag));
    ok_similar(gsl_matrix_get($V, 0, 0), 1);
    ok_similar( [ map { gsl_matrix_get($V, $_, 0) } (1..3) ], [ (0) x 3 ] );
    ok_similar( [ map { gsl_matrix_get($V, 0, $_) } (1..3) ], [ (0) x 3 ] );

    local $TODO = 'look into this';
    ok_similar(gsl_matrix_get($U, 1, 1), -0.609437002705849772);
    ok_similar(gsl_matrix_get($U, 1, 2), -0.758604748961341558); #doesn't fit the data I've got...
}

Test::Class->runtests;
