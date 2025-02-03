package AppConfig;
use Data::Dumper;
use strict;
use warnings;
use JSON qw(decode_json);

our $config;

# Charge le fichier de configuration
sub load_config{
    my($config_file) = @_;
    
    return die 'Erreur : Pas de fichier de configuration' unless $config_file;

    open(my $fh, '<', $config_file) 
            or die "Impossible de lire le fichier de configuration [$config_file]: $!";

    my $json_text = do { local $/; <$fh> };
    close $fh;

    # Décoder le JSON
    $config = decode_json($json_text);
}

sub get {
    my ($key) = @_;
    
    # Verifier si la cle existe dans la section
    die "Cle '$key' non trouvee"
        unless exists $config->{$key};
 
    return $config->{$key};
}

1;

__END__

=head1 NAME

AppConfig - Gestionnaire de configuration pour charger et recuperer des parametres a 
partir d'un fichier INI

=head1 SYNOPSIS

    use AppConfig;

    my $value = AppConfig::get('key_name');

=head1 DESCRIPTION

Le module AppConfig lit le fichier de configuration et fournit une methode simple pour acceder aux valeurs des cles.

=head1 EXAMPLE

    use AppConfig;

    my $server_host = AppConfig::get('host');

=head1 METHODS

=over 4

=item B<get($section, $key)>

Recupere la valeur associee a la cle specifiee donnee du fichier de configuration. Leve une exception si la cle n'existe pas.

=back

=head1 CONFIGURATION

Le fichier de configuration est un fichier INI situe dans le repertoire 'config' sous le nom 'config.ini'. Il doit suivre la structure suivante :

    [section_name]
    key_name = value

=cut
