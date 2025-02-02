package Timestamp::OptionsHandler;

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long qw(GetOptions);

use Timestamp::Util qw(validate_port validate_host validate_interval validate_clients_number);

use AppConfig;

sub handle_options {
    my ($script_type) = @_;
    
    # Récupère les options par défaut du fichier de configuration
    my %options = (
        host       => AppConfig::get('host'),
        port       => AppConfig::get('port'),
        interval   => AppConfig::get('interval'),
        nb_clients => AppConfig::get('nb_clients'),
    );
    my %options_spe = (
        'server' => {
            options=> {
                'port=i' => \$options{port},
            },
            validate => sub{ die "Port [$options{port}] invalide" unless validate_port($options{port}); }
        },
        'client' => {
            options=> {
                "port=i"      => \$options{port},
                "host=s"      => \$options{host},
                "interval=i"  => \$options{interval},
            },
            validate => sub{ 
                die "Port [$options{port}] invalide" unless validate_port($options{port}); 
                die "Host invalide" unless validate_host($options{host}); 
                die "Interval invalide" unless validate_interval($options{interval}); 
            }
        },
        'launcher' => {
            options=> {
                "port=i"      => \$options{port},
                "host=s"      => \$options{host},
                "interval=i"  => \$options{interval},
                "clients=i"   => \$options{nb_clients},
            },
            validate => sub{ 
                die "Port [$options{port}] invalide" unless validate_port($options{port}); 
                die "Host invalide" unless validate_host($options{host}); 
                die "Interval invalide" unless validate_interval($options{interval}); 
                die "Nombre de clients invalide" unless validate_clients_number($options{nb_clients}); 
            }
        },
    );
    die 'Option [$script_type] non valide, Options valides : server, client, launcher' 
        unless exists $options_spe{$script_type};

    my $options_script =  $options_spe{$script_type};

    # options de la ligne de commande
    GetOptions(%{$options_script->{options}}) 
        or die "Options incorrectes\n";
    
    # valide options passees en param
    $options_script->{validate}->();
    
    return %options;
}
1;

=pod

=head1 NAME

Timestamp::OptionsHandler - Gère les otpions de ligne de commande pour différents types de scripts,
                            dont serveur, client et launcher.


=head1 SYNOPSIS

    use Timestamp::OptionsHandler;

    my %options = Timestamp::OptionsHandler::handle_options($script_type);

=head1 DESCRIPTION

Ce module permet de gérer les options de ligne de commande pour les scripts de type 'server', 'client' ou 'launcher'. 
Les options sont récupérées depuis un fichier de configuration et validées avant d'être retournées.

=head1 FUNCTIONS

=head2 handle_options($script_type)

Gère les options en fonction du type de script ('server', 'client', 'launcher').

=over 4

=item * $script_type : Le type de script (server, client, launcher).

Retourne un hash avec les options récupérées et validées.

=back


=cut
