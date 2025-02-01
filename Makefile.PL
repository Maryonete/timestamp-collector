use 5.010;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'TimestampCollector',
    VERSION          => '1.01',
    AUTHOR           => 'Marion MAURICE <marion.maurice@mail.com>',
    LICENSE          => 'mit',
    MIN_PERL_VERSION => '5.010',
    PREREQ_PM        => {
        'IO::Socket::INET' => 0,
        'Time::HiRes'      => 0,
        'Config::Tiny'     => 0,
        'Fcntl'            => 0,
        'Test::More'       => 0,
        'Devel::Cover'     => 0,
    },
    EXE_FILES        => [ 
        'bin/client.pl', 
        'bin/server.pl', 
        'bin/launcher.pl' 
    ],
    test             => {
        TESTS => 't/*.t',
        COVERDIR => 't/cover_db',
    },
    META_MERGE       => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/Maryonete/timestamp-collector.git',
                web  => 'https://github.com/Maryonete/timestamp-collector',
            },
        },
    },
);
