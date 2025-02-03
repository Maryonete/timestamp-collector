use strict;
use warnings;
use Test::More;
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

#  sub init_datas_file {
#     my $self = shift;

#     # Vérifier si le fichier existe, sinon le créer
#     unless (-e $self->{output_file}) {
#         open(my $fh, '>', $self->{output_file}) 
#             or die "Impossible de créer le fichier [$self->{output_file}]: $!";
#         close($fh);
#     }

#     # Ouvrir en lecture pour charger les données dans la mémoire
#     open(my $log_file, '<', $self->{output_file}) 
#         or die "Impossible d'ouvrir le fichier [$self->{output_file}]: $!";

#     # Lire et nettoyer les données
#     while (my $line = <$log_file>) {
#         chomp $line;
#         next unless $line =~ /\S/;  # Ignore les lignes vides
#         push @{$self->{datas_file}}, $line;
#     }
#     close($log_file);
# }

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

