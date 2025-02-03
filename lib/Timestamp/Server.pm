package Timestamp::Server;
use strict;
use warnings;
use Time::HiRes qw(time);
use IO::Socket::INET;
use Timestamp::Util;
use Timestamp::OptionsHandler;

sub new {
    my ($class, %options) = @_;
    my $self  = {};
    bless $self, $class;

     # Si aucune option n'est passée, utilise le gestionnaire d'options
    unless (%options) {
        %options = Timestamp::OptionsHandler::handle_options('server');
    }

    $self->{server_host} = '0.0.0.0';
    $self->{server_port} = $options{port} || '7777';
    $self->{output_file} = './datas/timestamps.log'; # TODO mettre en config
    $self->{datas_file} = []; # données contenues dans le fichier
    $self->{server_socket} = undef;  # Socket serveur pour l'écoute
    $self->{connexion} = undef;  # Connexion cliente active
    
    return $self;
}

sub create_server_socket {
    my $self = shift;

    # Crée le socket serveur s'il n'existe pas
    unless ($self->{server_socket}) {
        $self->{server_socket} = IO::Socket::INET->new(
            LocalHost => $self->{server_host},
            LocalPort => $self->{server_port},
            Proto     => 'tcp',
            Listen    => 5,
            Reuse     => 1
        ) or die "Cannot create server socket: $!";
    }

    # Accepte une nouvelle connexion cliente
    my $client_connection = $self->{server_socket}->accept();
    
    return if !$client_connection;

    $self->{connexion} = $client_connection;
    return $client_connection;
}

# Envoie le timestamp du serveur
sub handle_time_sync {
    my $self = shift;
    
    my $server_time = sprintf("%.3f", time());
    $self->{connexion}->send($server_time . "\n");
}

sub handle_client_connection {
    my $self = shift;

    # Premiere connexion : synchronisation du temps
    my $client_message = '';
    my $bytes_read = $self->{connexion}->recv($client_message, 1024);
    
    if (!defined $bytes_read) {
        die "Erreur de recption donnees du Client : $!";
        return;
    }
    if ($client_message eq "SYNC") {
        $self->handle_time_sync();
        return;
    }
    return $client_message;
}

sub init_datas_file {
    my $self = shift;

    # Vérifier si le fichier existe, sinon le créer
    unless (-e $self->{output_file}) {
        open(my $fh, '>', $self->{output_file}) 
            or die "Impossible de créer le fichier [$self->{output_file}]: $!";
        close($fh);
    }

    # Ouvrir en lecture pour charger les données dans la mémoire
    open(my $log_file, '<', $self->{output_file}) 
        or die "Impossible d'ouvrir le fichier [$self->{output_file}]: $!";

    # Lire et nettoyer les données
    while (my $line = <$log_file>) {
        chomp $line;
        next unless $line =~ /\S/;  # Ignore les lignes vides
        push @{$self->{datas_file}}, $line;
    }
    close($log_file);
}

sub process_data {
    my ($self, $data) = @_;
    # Vérification de l'absence de doublons
    unless(grep { $_ eq $data } @{$self->{datas_file}}) {
        # Ajout du nouveau timestamp à la liste
        push(@{$self->{datas_file}}, $data);  
        
        # Trie
        my @sorted_timestamps = sort @{$self->{datas_file}};
        
        open(my $log_file, '>', $self->{output_file}) 
            or die "Impossible d'ouvrir le fichier [$self->{output_file}]: $!";
        
        print $log_file join("\n", @sorted_timestamps); # . "\n";
        close($log_file);
    }
}

sub run {
    my $self = shift;

    $| = 1; # pas de bufferisation console
    
    # # Creating a listening socket
    $self->create_server_socket();
    return unless $self->{connexion};
    $self->init_datas_file();

    while(1) {
        if ($self->{connexion} && $self->{connexion}->connected()) {
            my $message = $self->handle_client_connection();
            next unless $message;
            next unless Timestamp::Util::validate_timestamp($message);
            $self->process_data($message);
            print "-";
        }
        else {
            warn "Connexion perdue, reconnexion en cours ...";
            $self->create_server_socket();
        }
    }
}
sub DESTROY {
    my $self = shift;
    $self->{connexion}->close() if $self->{connexion};
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
