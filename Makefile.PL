use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	      => 'Class::WeakSingleton',
    'VERSION_FROM'    => 'WeakSingleton.pm', # finds $VERSION
    'dist'            => { 'COMPRESS' => 'gzip', 'SUFFIX' => 'gz' },
);
