#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($RealBin);
use lib 'lib';
use SignalHandler ();
use Timestamp::OptionsHandler ();
use Timestamp::Client;

sub main{
  SignalHandler::setup_signal_handlers(\&cleanup);

  # Récupère et valide les options
  my %opts = Timestamp::OptionsHandler::handle_options('client');

  # Création et démarrage du client
  my $client = Timestamp::Client->new(
      host     => $opts{host}, 
      port     => $opts{port}, 
      interval => $opts{interval}
  );
  print "Client demarre avec PID : $$ sur $opts{host}:$opts{port}\n";
  $client->run();
}

# Gestion de l'arrêt propre avec Ctrl+C 
sub cleanup  {
  print "Arret du processus Client [$$]\n";
  kill 'TERM', $$;
};

main();

__END__

=head1 NAME

client.pl - script principal pour creer et demarrer un client

=head1 SYNOPSIS

  use Timestamp::Client;

  client.pl [options]

=head1 OPTIONS

=over 8

=item B<--interval>

Specifie l'interval de temps en ms entre chaque envoie de donnee du client au serveur

=item B<--port>

Port sur lequel le client se connecte chez le serveur

=item B<--host>

Adresse IP du serveur

=back

=cut
