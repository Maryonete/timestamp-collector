use strict;
use warnings;
use Test::More tests => 7;
use Test::Exception;
use IO::Socket::INET;
use FindBin;
use lib "$FindBin::Bin/../../lib";

BEGIN { use_ok('Timestamp::Client') }
BEGIN { use_ok('Timestamp::Server') }

subtest 'Creation de l\'objet Client sans option' => sub {
    my $client_default = Timestamp::Client->new();
    isa_ok($client_default, 'Timestamp::Client', 'Objet Client cree avec succes');
    is($client_default->{server_host}, 'localhost', 'server_host par defaut correct');
    is($client_default->{server_port}, '7777', 'server_port par defaut correct');
};

subtest 'Creation de l\'objet Client avec option' => sub {
    my $client_custom = Timestamp::Client->new(host => '127.0.0.1', port => '8888');
    is($client_custom->{server_host}, '127.0.0.1', 'server_host personnalise correct');
    is($client_custom->{server_port}, '8888', 'server_port personnalise correct');
};

sub create_test_server {
    return (IO::Socket::INET->new(
        LocalHost => 'localhost',
        LocalPort => 7777,
        Proto     => 'tcp',
        Listen    => 5,
        Reuse     => 1
    )) || die "Impossible de creer le serveur : $!\n";
}

subtest 'Connexion du client au serveur' => sub {
    my $test_server = create_test_server();
    my $test_client = Timestamp::Client->new();
    my $server_connection = $test_client->connect_to_server();
    
    isa_ok($server_connection, 'IO::Socket::INET', 'server_connection est un objet IO::Socket::INET');
    ok($server_connection, 'Client connecte au serveur');
    
    close($server_connection) if $server_connection;
    close($test_server) if $test_server;
};

subtest 'Connexion du client au serveur errone' => sub {
    my $invalid_client = Timestamp::Client->new(server_host => 'badhost', server_port => '9999');
    my $failed_connection = eval { $invalid_client->connect_to_server() };
    ok(!$failed_connection, "La connexion ne doit pas être etablie si le serveur est inaccessible");
};

subtest 'Verifier si la connexion echoue' => sub {
    plan tests => 1;
   
    my $invalid_client = Timestamp::Client->new(server_host => 'badhost', server_port => '9999');
    throws_ok { $invalid_client->connect_to_server() } qr/Client cannot connect to server:/,
        "Connexion echouee comme prevu avec un mauvais hote";
};

done_testing();

=head1 NOM

t_client.t - Tests unitaires pour Timestamp::Client

=head1 DESCRIPTION

Ce fichier teste les fonctionnalités principales du module Timestamp::Client, notamment la création de l'objet client, la connexion au serveur et la gestion des erreurs.

=head1 TESTS

=over 4

=item * Vérification de l'importation des modules Timestamp::Client et Timestamp::Server.

=item * Création d'un client avec et sans options personnalisées.

=item * Vérification de la connexion du client à un serveur de test.

=item * Simulation d'une connexion erronée avec un hôte ou un port invalide.

=item * Vérification que la connexion échoue bien lorsque le serveur est inaccessible.

=back

=cut
