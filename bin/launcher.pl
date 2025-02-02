#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use POSIX ":sys_wait_h";
use Time::HiRes qw(sleep);
use FindBin qw($RealBin);
use lib 'lib';
use SignalHandler;
use Timestamp::OptionsHandler;


# Récupère et valide les options
my %opts = Timestamp::OptionsHandler::handle_options('launcher');

# Chemins des scripts
my $server_script = "$RealBin/server.pl";
my $client_script = "$RealBin/client.pl";

# Vérifier que les scripts existent
unless (-e $server_script) {
    die "Le script serveur [$server_script] n'existe pas.\n";
}
unless (-e $client_script) {
    die "Le script client [$client_script] n'existe pas.\n";
}

# Serveur
sub start_server {
     my ($port) = @_;
    my $pid_serveur = fork();
    if (!defined $pid_serveur) {
        die "Impossible de forker : $!\n";
    } 
    elsif ($pid_serveur == 0) {
        # Démarrage du serveur via le script
        system("perl $server_script --port=$opts{port}") 
            or die "Impossible de lancer serveur.pl : $!\n";
        exit 0;
    }
    return $pid_serveur;
}

# Client
sub start_clients {
    my ($nb_clients, $port, $host, $interval) = @_;

    my @pid_clients = ();

    foreach (1..$nb_clients) {

        my $pid_client = fork();
        
        if ($pid_client == 0) {
            # Gestionnaire de signal pour le client
            $SIG{TERM} = sub {
                print "Client $$ terminé\n";
                exit 0;
            };
            # Démarrage du client via le script
            system("perl $client_script --host=$opts{host} --port=$opts{port} --interval=$opts{interval}") 
                or die "Client connexion terminee\n";
            exit 0;
        }
        push(@pid_clients, $pid_client) if $pid_client;
    }
    return @pid_clients;
}

# Main
print '_' x 50 . "\n";
print "Communication TCP/IP Client(s)/Serveur";
print "\nDemarrage avec la configuration suivante:\n";
print "- Serveur port: $opts{port}\n";
print "- Clients connect: $opts{host}:$opts{port}\n";
print "- Nombre de clients: $opts{nb_clients}\n";
print "- Intervalle: $opts{interval}  ms\n";
print '_' x 50 . "\n";
my $pid_serveur = start_server($opts{port});
my @pid_clients = start_clients($opts{nb_clients},$opts{port}, $opts{host}, $opts{interval});


# Gestion de l'arrêt propre avec Ctrl+C 
my $cleanup = sub {
    print "\nArrêt des processus...\n";
    
    # Terminer tous les processus du groupe
    kill 'TERM', -$$;  # Envoie TERM à tout le groupe de processus
    
    # Attendre la fin de tous les processus
    while (waitpid(-1, 0) > 0) {}
    
    print "Tous les processus sont arrêtés\n";

};

# Active le gestionnaire avec le cleanup : signal (Ctrl+C)
setup_signal_handlers($cleanup);




1;
=pod
=head1 NAME

launcher.pl - Lance un serveur d'écoute des timestamps et n clients

=head1 SYNOPSIS

  use Timestamp::Server;

  perl server.pl

=head1 DESCRIPTION

Ce script lance un serveur et n clients 
Les options sont validées avant de démarrer le serveur et le clients.

=head1 OPTIONS

=over 8

=item B<--interval>

Specifie l'interval de temps en ms entre chaque envoie de donnee du client au serveur

=item B<--port>

Port sur lequel le serveur ecoute le client

=item B<--host>

Adresse IP du serveur

=item B<--clients>

Nombre de clients a lancer

=back

=cut
