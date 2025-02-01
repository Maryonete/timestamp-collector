package Timestamp::Client;
use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw(time);
use IO::Socket::INET;
use Time::HiRes qw(usleep);
use Timestamp::Util;
use Timestamp::OptionsHandler;

sub new {
    my ($class, %options) = @_;

    # Si aucune option n'est passée, utilise le gestionnaire d'options
    unless (%options) {
        %options = Timestamp::OptionsHandler::handle_options('client');
    }

    my $self = {
        server_host => $options{host} || 'localhost',
        server_port => $options{port} || '7777',
        time_offset => 0,  # Stocke l'offset de temps
        sync_interval => $options{interval} || 10,  # Intervalle en millisecondes
    };
    bless $self, $class;
    return $self;
}

sub connect_to_server {
    my ($self) = @_;
    return (new IO::Socket::INET (
        PeerHost => $self->{server_host},
        PeerPort => $self->{server_port},
        Proto    => 'tcp',
    )) || die "Client cannot connect to server: host:$self->{server_host} - port:$self->{server_port} $!\n";
}

sub calculate_time_offset {
    my ($self) = @_;
    my $server_connection = $self->connect_to_server();
    return unless $server_connection;
           
    # Indique qu'il s'agit d'une synchronisation
    $server_connection->print("SYNC\n");
    
    # Envoie le timestamp local
    my $client_timestamp = time();
   
    # Reçoit le timestamp du serveur
    my $server_timestamp;
    $server_connection->recv($server_timestamp, 1024);
    
    # Timestamp du serveur invalide
    if (!Timestamp::Util::validate_timestamp($server_timestamp)) {
        $self->{time_offset} = 0;
        warn "Timestamp du serveur invalide : $server_timestamp [serveur = $client_timestamp]";
        return 0;
    }

    # Calcule et stocke l'offset
    $self->{time_offset} = $server_timestamp - $client_timestamp;
    $server_connection->close();
    
    return $self->{time_offset};
}

sub run {
    my ($self) = @_;
    $self->calculate_time_offset();
    
    while (1) {
        my $synchronized_timestamp = time()+ $self->{time_offset};
        if (my $server_connection = $self->connect_to_server()) {
            $server_connection->send($synchronized_timestamp);
            $server_connection->close();
        }
        
        # Pause de 10 millisecondes (10 000 microsecondes)
        usleep($self->{sync_interval} * 1000);
    }
}

1;

__END__

=head1 NAME

Timestamp::Client - Client pour envoyer des timestamps synchronises a un serveur

=head1 SYNOPSIS

    use Timestamp::Client;

    my $client = Timestamp::Client->new( host => 'localhost', port => 7777, interval => 10 );
    $client->run();

=head1 DESCRIPTION

Le client Timestamp::Client etablit une connexion TCP avec un serveur, calcule l'offset temporel entre son horloge locale et celle du serveur, puis envoie en continu des timestamps synchronises. Les timestamps sont envoyes toutes les 10 millisecondes (configurable).

=head1 EXAMPLE

    my $client = Timestamp::Client->new( host => 'localhost', port => 7777, interval => 10 );
    $client->run();

=head1 OPTIONS

=over 8

=item B<--host>

Adresse du serveur. Valeur par defaut : 'localhost'.

=item B<--port>

Port du serveur. Valeur par defaut : 7777.

=item B<--interval>

Intervalle entre les envois de timestamps, en millisecondes. Valeur par defaut : 10.

=back

=head1 METHODS

=over 8

=item B<new>

Initialise le client avec les options suivantes : hote du serveur, port et intervalle entre chaque envoi de timestamp.

=item B<connect_to_server>

etablit une connexion TCP avec le serveur specifie.

=item B<calculate_time_offset>

Calcule l'offset entre l'horloge locale du client et l'horloge du serveur, puis le stocke pour une synchronisation future.

=item B<run>

Envoie des timestamps synchronises au serveur a intervalles reguliers, en utilisant l'offset calcule.

=back

=cut
