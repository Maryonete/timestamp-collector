#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use POSIX ":sys_wait_h";
use Time::HiRes qw(sleep);
use FindBin qw($RealBin);
use lib 'lib';
use AppConfig; 
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
            print "END SERVEUR";
        exit 0;
    }
    print "Serveur demarre avec PID $pid_serveur (ecoute sur port: $port)\n";
    return $pid_serveur;
}

# Client
sub start_clients {
    my ($nb_clients, $port, $host, $interval) = @_;

    my @pid_clients = ();
    foreach (1..$nb_clients) {
        my $pid_client = fork();
        if ($pid_client == 0) {
            while (1) {
            # Démarrage du client via le script
            system("perl $client_script --host=$opts{host} --port=$opts{port} --interval=$opts{interval}") 
            or warn "Client termine, redémarrage...\n";
            sleep 1; # Attendre avant de redémarrer
            }
        }
        push(@pid_clients, $pid_client);
    }
    print "Clients demarres avec PIDs : " . join(", ", @pid_clients) . " sur $host:$port\n";
    return @pid_clients;
}

# Gestion de l'arrêt propre avec Ctrl+C 
sub handle_termination {
    my ($pid_serveur, @pid_clients) = @_;
    $SIG{INT} = sub {
        print "\nArret des processus...\n";
        kill 'TERM', $pid_serveur, @pid_clients;
        exit;
    };
}

# Attente des processus enfants
sub wait_for_children {
    while (1) {
        sleep 1;
        # Vérifier les processus enfants terminés
        while ((my $pid = waitpid(-1, WNOHANG)) > 0) {
            print "Processus $pid terminé\n";
        }
    }
}

# Main execution flow
print "\nDemarrage avec la configuration suivante:\n";
print "- Serveur port: $opts{port}\n";
print "- Clients connect: $opts{host}:$opts{port}\n";
print "- Nombre de clients: $opts{nb_clients}\n";
print "- Intervalle: $opts{interval}  ms\n";
print '_' x 50 . "\n";
my $pid_serveur = start_server($opts{port});
my @pid_clients = start_clients($opts{nb_clients},$opts{port}, $opts{host}, $opts{interval});


# Handle termination signal (Ctrl+C)
handle_termination($pid_serveur, @pid_clients);

# Wait for the child processes to terminate
wait_for_children();