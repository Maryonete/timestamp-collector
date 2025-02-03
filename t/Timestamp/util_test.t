use strict;
use warnings;
use Test::More;
use Test::Exception;
use IO::Socket::INET;


BEGIN { use_ok('Timestamp::Util') }

subtest "Validate id it's a number" => sub {
    ok(Timestamp::Util::is_number('123'), '123 un nombre');
    ok(!Timestamp::Util::is_number('1aa'), '123.45 n\'est pas un nombre valide');
};
subtest "Validate est un timestamp" => sub {
    ok(Timestamp::Util::validate_timestamp('123.456'), '123.456 est un timestamp valide');
    ok(Timestamp::Util::validate_timestamp('0.000'), '0.000 est un timestamp valide');
    ok(Timestamp::Util::validate_timestamp('999.999'), '999.999 est un timestamp valide');
    ok(Timestamp::Util::validate_timestamp('123456.789'), '123456.789 est un timestamp valide');
    ok(Timestamp::Util::validate_timestamp('123.456'), '123.456 est un timestamp valide');
    ok(Timestamp::Util::validate_timestamp('0.000'), '0.000 est un timestamp valide');
    ok(Timestamp::Util::validate_timestamp('999.999'), '999.999 est un timestamp valide');
    ok(Timestamp::Util::validate_timestamp('123456.789'), '123456.789 est un timestamp valide');
    ok(!Timestamp::Util::validate_timestamp('123.45'), '123.45 n\'est pas un timestamp valide');
    ok(!Timestamp::Util::validate_timestamp('123.4567'), '123.4567 n\'est pas un timestamp valide');
    ok(!Timestamp::Util::validate_timestamp('123.456.'), '123.456. n\'est pas un timestamp valide');
    ok(!Timestamp::Util::validate_timestamp('123.456.7'), '123.456.7 n\'est pas un timestamp valide');
    ok(!Timestamp::Util::validate_timestamp('123.456.78'), '123.456.78 n\'est pas un timestamp valide');
    ok(!Timestamp::Util::validate_timestamp('123.456.789'), '123.456.789 n\'est pas un timestamp valide');
    
};

subtest "Validate est un numero de port" => sub {
    ok(Timestamp::Util::validate_port('123'), '123 est un port valide');
    ok(!Timestamp::Util::validate_port('123.45'), '123.45 n\'est pas un port valide');
    ok(!Timestamp::Util::validate_port('0'), '0 n\'est pas un port valide');
    ok(!Timestamp::Util::validate_port(''), '"" n\'est pas un port valide');
    ok(!Timestamp::Util::validate_port('numport'), 'numport n\'est pas un port valide');
};
subtest "Validate nombre de client" => sub {
    ok(Timestamp::Util::validate_clients_number('123'), '123 est un nombre de client valide');
    ok(!Timestamp::Util::validate_clients_number('123.45'), '123.45 n\'est pas un nombre de client valide');
    ok(!Timestamp::Util::validate_clients_number(''), '"" n\'est pas un nombre de client valide');
    ok(!Timestamp::Util::validate_clients_number('0'), '0 n\'est pas un nombre de client valide');
    ok(!Timestamp::Util::validate_clients_number('9999'), '9999 n\'est pas un nombre de client valide');
};
subtest "Validate host" => sub {
    ok(Timestamp::Util::validate_host('127.0.0.1'), '127.0.0.1 est un host valide');
    ok(!Timestamp::Util::validate_host(''), '"" n\'est pas un host valide');
    # ok(!Timestamp::Util::validate_host('15656'), '15656 n\'est pas un host valide');

    # ok(!Timestamp::Util::validate_host('www.test.fr'), '127.0.0.15656 n\'est pas un host valide');
};
subtest "Validate interval" => sub {
    ok(Timestamp::Util::validate_interval('1'), '1 est un interval valide');
    ok(!Timestamp::Util::validate_interval(''), '"" n\'est pas un interval valide');
    ok(!Timestamp::Util::validate_interval('0'), '0 n\'est pas un interval valide');
    ok(!Timestamp::Util::validate_interval('5000'), '5000 n\'est pas un interval valide');
};
done_testing();
