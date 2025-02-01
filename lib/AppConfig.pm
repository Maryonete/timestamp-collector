package AppConfig;
use strict;
use warnings;
use Config::Tiny;

our $config;

BEGIN {
    # Charge le fichier de configuration au demarrage
    my $config_file = 'config/config.ini';
    $config = Config::Tiny->read($config_file)
        or die "Impossible de lire le fichier de configuration: $config_file";
}

sub get {
    my ($section, $key) = @_;
    
    # Verifier si la section existe
    die "Section '$section' non trouvee" unless exists $config->{$section};
    
    # Verifier si la cle existe dans la section
    die "Cle '$key' non trouvee dans la section '$section'"
        unless exists $config->{$section}->{$key};
    
    return $config->{$section}->{$key};
}

1;

__END__

=head1 NAME

AppConfig - Gestionnaire de configuration pour charger et recuperer des parametres a partir d'un fichier INI

=head1 SYNOPSIS

    use AppConfig;

    my $value = AppConfig::get('section_name', 'key_name');

=head1 DESCRIPTION

Le module AppConfig permet de charger et de recuperer des parametres de configuration a partir d'un fichier INI. Il utilise le module L<Config::Tiny> pour lire le fichier de configuration et fournit une methode simple pour acceder aux valeurs des sections et des cles.

=head1 EXAMPLE

    use AppConfig;

    my $server_host = AppConfig::get('server', 'host');
    my $server_port = AppConfig::get('server', 'port');

=head1 METHODS

=over 4

=item B<get($section, $key)>

Recupere la valeur associee a la cle specifiee dans la section donnee du fichier de configuration. Leve une exception si la section ou la cle n'existe pas.

=back

=head1 CONFIGURATION

Le fichier de configuration est un fichier INI situe dans le repertoire 'config' sous le nom 'config.ini'. Il doit suivre la structure suivante :

    [section_name]
    key_name = value

=head1 ERRORS

Si le fichier de configuration ne peut pas être lu ou si une section ou une cle est introuvable, une erreur sera generee et le programme s'arrêtera.

=cut
