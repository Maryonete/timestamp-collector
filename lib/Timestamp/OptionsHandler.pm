package Timestamp::OptionsHandler;

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Timestamp::Util qw(validate_port validate_host validate_interval validate_clients_number);
use AppConfig;

sub handle_options {
    my ($script_type, $default_options) = @_;
    
    # Récupère les options par défaut du fichier de configuration
    my %options = (
        host       => AppConfig::get('host'),
        port       => AppConfig::get('port'),
        interval   => AppConfig::get('interval'),
        nb_clients => AppConfig::get('nb_clients'),
    );

    # Surcharge avec les options passées en paramètre
    %options = (%options, %$default_options) if $default_options;

    # Définit les options de ligne de commande selon le type de script
    my %option_specs = (
        server => {
            options => {
                "port=i" => \$options{port},
            },
            validate => sub {
                die "Port invalide\n" unless validate_port($options{port});
            }
        },
        client => {
            options => {
                "host=s"     => \$options{host},
                "port=i"     => \$options{port},
                "interval=i" => \$options{interval},
            },
            validate => sub {
                die "Hôte invalide\n" unless validate_host($options{host});
                die "Port invalide\n" unless validate_port($options{port});
                die "Intervalle invalide\n" unless validate_interval($options{interval});
            }
        },
        launcher => {
            options => {
                "clients=i" => \$options{nb_clients},
                "port=i"    => \$options{port},
                "host=s"    => \$options{host},            
                "interval=i"=> \$options{interval},
            },
            validate => sub {
                die "Nombre de clients invalide\n" unless validate_clients_number($options{nb_clients});
                die "Hôte invalide\n" unless validate_host($options{host});
                die "Port invalide\n" unless validate_port($options{port});
                die "Intervalle invalide\n" unless validate_interval($options{interval});
            }
        }
    );

    # Vérifie que le type de script est valide
    die "Type de script invalide\n" unless exists $option_specs{$script_type};

    # Récupère les spécifications d'options pour ce type de script
    my $spec = $option_specs{$script_type};

    # Parse les options de ligne de commande
    GetOptions(%{$spec->{options}}) 
        or die "Erreur dans les options pour $script_type\n";

    # Valide les options
    $spec->{validate}->();

    return %options;
}

1;

=head1 NOM

Timestamp::OptionsHandler - Gestion des options pour les scripts du projet

=head1 SYNOPSIS

    use Timestamp::OptionsHandler;
    my %options = Timestamp::OptionsHandler::handle_options('client', { interval => 5 });

=head1 DESCRIPTION

Gère le chargement, la validation et la surcharge des options pour les scripts (serveur, client, launcher).

=head1 FONCTION

=head2 handle_options($script_type, $default_options)

Charge et valide les options en fonction du type de script (C<server>, C<client>, C<launcher>).

=over 4

=item * Fusionne les options par défaut avec celles du fichier de configuration.

=item * Analyse les options de ligne de commande via C<Getopt::Long>.

=item * Valide les options avec C<Timestamp::Util>.

=item * Retourne une hash des options valides.

=back


=cut
