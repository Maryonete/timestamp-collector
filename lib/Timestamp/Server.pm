package Timestamp::Server;
use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw(time);
use IO::Socket::INET;
use Timestamp::Util;
use Timestamp::OptionsHandler;

# TODO: Optimisation des performances : Utilisation de buffers et de gestion efficace des fichiers.

sub new {
    my ($class, %options) = @_;

     # Si aucune option n'est passée, utilise le gestionnaire d'options
    unless (%options) {
        %options = Timestamp::OptionsHandler::handle_options('server');
    }

    my $self = {
        server_host => '0.0.0.0',
        server_port => $options{port} || '7777',
        output_file => './datas/timestamps.log', # TODO mettre en config
        datas_file  => [], # données contenues dans le fichier
    };
    bless $self, $class;
    return $self;
}
sub create_server_socket {
    my ($self) = @_;
    return new IO::Socket::INET (
        LocalHost => $self->{server_host},
        LocalPort => $self->{server_port},
        Proto     => 'tcp',
        Listen    => 5,
        Reuse     => 1
    );
}
# Envoie le timestamp du serveur
sub handle_time_sync {
    my ($self, $client_connection) = @_;
    
    my $server_time = sprintf("%.3f", time());
    $client_connection->send($server_time);
   
    return 1;
}

sub handle_client_connection {
    my ($self, $server_socket) = @_;
    my $client_connection = $server_socket->accept();
   
    if (!$client_connection) {
        print "Erreur lors de l'acceptation de la connexion : $!\n";
        return;
    }
    # Premiere connexion : synchronisation du temps
    my $client_message = <$client_connection>;
    if ($client_message eq "SYNC\n") {
        $self->handle_time_sync($client_connection);
        return;
    }
    return $client_message;
}
sub init_datas_file {
    my ($self) = @_;

    # Ouvrir en lecture pour charger les données dans la mémoire
    open(my $log_file, '<', $self->{output_file}) 
        or die "Impossible d'ouvrir le fichier [$self->{output_file}]: $!";

    # Lire et stocker les données dans le tableau
    $self->{datas_file} = [ map { chomp; $_ } <$log_file> ];
    close($log_file);
}
sub process_data {
    my ($self, $data) = @_;
    
    # Vérification de l'absence de doublons
    unless(grep { $_ eq $data } @{$self->{datas_file}}) {
        push(@{$self->{datas_file}}, $data);  # Ajouter le nouveau timestamp à la liste
        # Trier et nettoyer les retours à la ligne
        my @sorted_timestamps = sort map { chomp; $_ } @{$self->{datas_file}};
        
        # Ouvrir le fichier en écriture et y écrire les données triées
        open(my $log_file, '>', $self->{output_file}) 
            or die "Impossible d'ouvrir le fichier [$self->{output_file}]: $!";
        print $log_file join("\n", @sorted_timestamps) . "\n";
        close($log_file);
    }
}



sub run {
    my ($self) = @_;
    $| = 1; # pas de bufferisation console
    
    # Creating a listening socket
    my $server_socket = $self->create_server_socket();
    die "Cannot create socket $!\n" unless $server_socket;
    
    $self->init_datas_file();

    while(1) {
        my $message = $self->handle_client_connection($server_socket);
        next unless $message;
        next unless Timestamp::Util::validate_timestamp($message);
        $self->process_data($message);
        print "-";
    }
}

1;

__END__

=head1 NAME

Timestamp::Server - Serveur de gestion des connexions clients et de stockage des timestamps

=head1 SYNOPSIS

    use Timestamp::Server;

    my $server = Timestamp::Server->new( port => 7777 );
    $server->run();

=head1 DESCRIPTION

Le serveur Timestamp::Server recoit des connexions TCP des clients, synchronise leurs horloges et enregistre les timestamps recus dans un fichier. Les donnees sont triees et les doublons elimines avant l'enregistrement.

=head1 EXAMPLE

    my $server = Timestamp::Server->new( port => 7777 );
    $server->run();

=head1 OPTIONS

=over 8

=item B<--port>

Port d'ecoute du serveur. Valeur par defaut : 7777.

=back

=head1 METHODS

=over 8

=item B<new>

Initialise le serveur avec l'option de port d'ecoute. Par defaut, le port est 7777.

=item B<handle_time_sync>

Synchronise l'heure avec un client en envoyant le timestamp du serveur.

=item B<handle_client_connection>

Accepte une connexion client, synchronise l'heure si necessaire et enregistre les timestamps recus dans le fichier.

=item B<process_data>

Traite et enregistre les timestamps recus, en eliminant les doublons et en triant les valeurs.

=item B<create_server_socket>

Cree et retourne un socket d'ecoute pour accepter les connexions des clients.

=item B<run>

Lance le serveur, accepte les connexions et traite les donnees recues.

=back

=cut
