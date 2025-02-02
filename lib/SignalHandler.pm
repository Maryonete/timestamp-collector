package SignalHandler;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw(setup_signal_handlers);


sub setup_signal_handlers {
    my ($cleanup) = @_;
    $SIG{INT} = sub {
        print "\nArrêt en cours...\n";
        $cleanup->() if $cleanup;
        exit;
    };
}

1;

=pod

=head1 NAME

SignalHandler - Gestion des signaux pour un nettoyage propre

=head1 SYNOPSIS

    use SignalHandler;
    
    SignalHandler::setup_signal_handlers(\&cleanup);

=head1 DESCRIPTION

Ce module permet de configurer un gestionnaire pour le signal SIGINT (généralement envoyé lors d'un Ctrl+C).
Lors de la réception de ce signal, il affiche un message et exécute une fonction de nettoyage (si fournie).

=head1 FUNCTIONS

=head2 setup_signal_handlers

    $cleanup = \&cleanup;  # Une fonction à appeler lors de l'arrêt du programme.

Cette fonction configure le gestionnaire pour le signal SIGINT. Lorsque ce signal est reçu, elle affiche
"Arrêt en cours..." et exécute la fonction de nettoyage (si elle est définie) avant d'arrêter le programme.



=cut
