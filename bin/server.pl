#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Getopt::Long;
use Timestamp::Server;

use lib 'lib';
use AppConfig;
use SignalHandler;

use Timestamp::OptionsHandler;


# Fonction principale
sub main {
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
my $cleanup = sub {
    kill 'TERM', $$;
};
main();
setup_signal_handlers($cleanup);
setup_signal_handlers();