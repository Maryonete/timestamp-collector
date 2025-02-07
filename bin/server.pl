#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($RealBin);
use lib 'lib';
use SignalHandler ();
use Timestamp::OptionsHandler ();
use Timestamp::Server;


# Fonction principale
sub main {
    
    SignalHandler::setup_signal_handlers(\&cleanup);

    # Récupère et valide les options
    my %opts = Timestamp::OptionsHandler::handle_options('server');

    # Création et démarrage du serveur avec les paramètres
    my $serveur = Timestamp::Server->new(
        port => $opts{port}
    );
    print "Serveur demarre avec PID $$ (ecoute sur port: $opts{port})\n";
    $serveur->run();
}

# Gestion de l'arrêt propre avec Ctrl+C 
sub cleanup {
    print "Arret du processus Serveur [$$]\n";
    kill 'TERM', $$;
};

main();


=pod
=head1 NAME

server.pl - Lance un serveur d'écoute des timestamps

=head1 SYNOPSIS

  use Timestamp::Server;

  perl server.pl

=head1 DESCRIPTION

Ce script lance un serveur qui écoute sur un port défini dans la configuration. 
Les options sont validées avant de démarrer le serveur.

=head1 OPTIONS

=over 8

=item B<--port>

Port sur lequel le serveur ecoute le client


=back

=cut
