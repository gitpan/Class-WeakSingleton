use 5.006;
use Module::Build;

Module::Build->new(
    module_name => 'Class::WeakSingleton',
    license     => 'perl',
    requires    => {
        'Scalar::Util' => 0,
        perl           => '5.6.0',
    },
    build_requires => { 'Test::More' => 0 },

    # There is no 'skip' value yet.
    #    create_makefile_pl => 'skip',
    create_readme   => 1,
    create_packlist => 1,
    sign            => 1,
)->create_build_script;
