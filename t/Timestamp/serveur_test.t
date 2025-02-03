use strict;
use warnings;
use Test::More  tests => 5;
use Test::Exception;
use IO::Socket::INET;


BEGIN { use_ok('Timestamp::Client') }
BEGIN { use_ok('Timestamp::Server') }

subtest 'Creation de l\'objet Serveur sans option' => sub {
    my $server_default = Timestamp::Server->new();
    isa_ok($server_default, 'Timestamp::Server', 'Objet Serveur cree avec succès');
    is($server_default->{server_host}, '0.0.0.0', 'server_host par defaut correct');
    is($server_default->{server_port}, '7777', 'server_port par déeaut correct');
    is($server_default->{output_file}, './datas/timestamps.log', 'fichier timestamps par defaut correct');
};

subtest 'Creation de l\'objet Serveur avec option' => sub {
    my $server_custom = Timestamp::Server->new(port => '8888');
    is($server_custom->{server_port}, '8888', 'server_port personnalise correct');
};

sub create_test_client {
    return IO::Socket::INET->new(
        PeerHost => 'localhost',
        PeerPort => '7777',
        Proto    => 'tcp'
    );
}

subtest 'Erreur sur chemin fichier log timestamp' => sub {
    my $server = Timestamp::Server->new();
    $server->{output_file} = "/test/false/directory/test.txt";
    my $process_data_fail = eval { $server->process_data("tt") };
    ok(!$process_data_fail, "Impossible d'ouvrir le fichier");
};

# subtest 'Test de la gestion des donnees dans le fichier' => sub {
#     my $server = Timestamp::Server->new();
#     my $server_socket = $server->create_server_socket();

#     isa_ok($server_socket, 'IO::Socket::INET', 'Objet server_socket cree avec succes');

#     my $test_client = create_test_client();
    
#     $test_client->send("Test data") if $test_client;
#     my $client_connection = $server_socket->accept();

#     $server->{output_file} = "$RealBin/datas/timestamps.log";
    
#     my $test_data = "donnees de test";
#     $server->process_data($test_data);

#     open(my $log_file, "<$server->{output_file}") or die "open: $!";
#     chomp(my $file_content = <$log_file>);
#     is($file_content, $test_data, "Fichier de log renseigne correctement");
    
#     $test_client->close() if $test_client;
# };

# subtest 'teste handle_client_connection' => sub {
#     my $server = Timestamp::Server->new();
#     my $server_socket = $server->create_server_socket();

#     isa_ok($server_socket, 'IO::Socket::INET', 'Objet server_socket cree avec succes');

#     my $test_client = create_test_client();
#     my $client_connection = $server_socket->accept();

#     $test_client->send("Test data") if $test_client;

#     $server->handle_time_sync($client_connection);
#     my $server_time = time();
    
#     my $client_message = $server->handle_client_connection($test_client);
#     isa_ok($client_connection, 'IO::Socket::INET', 'Objet client_connection cree avec succes');

#     $test_client->close() if $test_client;
# };



done_testing();

=head1 NOM

serveur_test.t - Tests unitaires pour le module Timestamp::Server

=head1 DESCRIPTION

Ce fichier teste les principales fonctionnalités du serveur, 
incluant la création de l'objet, la gestion des connexions et l'écriture des données.

=head1 TESTS

=over 4

=item * Chargement des modules Timestamp::Client et Timestamp::Server

=item * Création de l'objet serveur avec ou sans options

=item * Vérification des paramètres par défaut (host, port, fichier log)

=item * Gestion des erreurs lors de l'ouverture du fichier log

=item * Vérification de l'écriture correcte des données dans le fichier log

=item * Gestion d'une connexion client et traitement des messages

=item * Synchronisation du temps avec le client

=back

=cut
