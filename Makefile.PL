use ExtUtils::MakeMaker;

use 5.006;
WriteMakefile(
    'NAME'	      => 'Class::WeakSingleton',
    'VERSION_FROM'    => 'WeakSingleton.pm',
    'PREREQ_PM'       => { 'Scalar::Util' => 0 },
    'dist'            => { 'COMPRESS' => 'gzip', 'SUFFIX' => 'gz' },
);
