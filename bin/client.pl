#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Timestamp::Client;
use AppConfig;

use Timestamp::OptionsHandler;

sub main{

# Récupère et valide les options
my %opts = Timestamp::OptionsHandler::handle_options('client');

# Création et démarrage du client
my $client = Timestamp::Client->new(
    host     => $opts{host}, 
    port     => $opts{port}, 
    interval => $opts{interval}
);


$client->run();
}

main();
1;

__END__

=head1 NAME

client.pl - script principal pour creer un client

=head1 SYNOPSIS

  use Timestamp::Client;

  client.pl [options]

=head1 OPTIONS

=over 8

=item B<--interval>

Specifie l'interval de temps en ms entre chaque envoie de donnee du client au serveur

=item B<--port>

Port sur lequel le serveur ecoute le client

=item B<--host>

Adresse IP du serveur

=back

=cut