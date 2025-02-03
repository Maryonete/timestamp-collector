#!/usr/bin/perl
use strict;
use warnings;

use POSIX ":sys_wait_h";

use FindBin qw($RealBin);
use lib 'lib';

use Timestamp::OptionsHandler ();

# Serveur
sub start_server {
     my ($server_script, $options) = @_;
    my $pid_serveur = fork();
    if (!defined $pid_serveur) {
        die "Impossible de forker : $!\n";
    } 
    elsif ($pid_serveur == 0) {
        # Démarrage du serveur via le script
        system("perl $server_script --port=$options->{port}") 
            or die "Impossible de lancer serveur.pl : $!\n";
        exit 0;
    }
    return $pid_serveur;
}

# Client
sub start_clients {
    my ($client_script, $options) = @_;

    my @pid_clients = ();

    foreach (1..$options->{nb_clients}) {

        my $pid_client = fork();
        
        if ($pid_client == 0) {
            
            # Démarrage du client via le script
            system("perl $client_script --host=$options->{host} --port=$options->{port} --interval=$options->{interval}") 
                or die "Client connexion terminee\n";
            exit 0;
        }
        push(@pid_clients, $pid_client) if $pid_client;
    }
    return @pid_clients;
}
# Affichage de la configuration
sub display_config {
    my ($options) = @_;
    print "Communication TCP/IP Client(s)/Serveur\n";
    print "Demarrage avec la configuration suivante:\n";
    print "- Serveur port: $options->{port}\n";
    print "- Clients connect: $options->{host}:$options->{port}\n";
    print "- Nombre de clients: $options->{nb_clients}\n";
    print "- Intervalle: $options->{interval} ms\n";
    print '_' x 50 . "\n";
}
sub main{

    # Récupère et valide les options
    my %options = Timestamp::OptionsHandler::handle_options('launcher');

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

    display_config(\%options);

    my $pid_serveur = start_server($server_script, \%options)  ;
    my @pid_clients = start_clients($client_script , \%options);
}

main();
1;


=pod

=head1 NAME

launcher.pl - Lance un serveur d'écoute des timestamps et n clients

=head1 SYNOPSIS

  perl launcher.pl

=head1 DESCRIPTION

Ce script lance un serveur et n clients.
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
