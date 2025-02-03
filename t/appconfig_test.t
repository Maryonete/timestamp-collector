use strict;
use warnings;
use Test::More tests => 5;

# Chargement du module
require_ok('AppConfig');

my $file_test = "t/datas/config.json";

# Fonctions utilitaires pour les tests
sub setup_test_env {
    open my $fh, '>', $file_test or die "Impossible de creer config.json: $!";
    print $fh <<'END_CONFIG';
{
  "value": 123,
  "name": "marion"
}
END_CONFIG
    close $fh;
}

sub cleanup_test_env {
    unlink $file_test;
}

# Environnement de test
setup_test_env();

AppConfig::load_config($file_test);

subtest 'Le fichier de configuration n\'existe pas' => sub {
    eval { AppConfig::load_config('invalid_file') };
    like($@, qr/Impossible de lire le fichier de configuration/, 'Erreur fichier invalide');
};
subtest 'Le fichier de configuration absent' => sub {
    eval { AppConfig::load_config() };
    like($@, qr/Erreur : Pas de fichier de configuration/, 'AppConfig: Erreur fichier inexistant');
};
# Test des valeurs valides
subtest 'Lecture des valeurs valides' => sub {
    AppConfig::load_config($file_test);
    my $value = AppConfig::get('value') ;
    is($value, '123', 'Lecture de value') ;

    my $name = eval { AppConfig::get('name') };
    is($name, 'marion', 'Lecture de name') or diag($@);
};

# Test des erreurs
subtest 'Gestion des erreurs' => sub {
    
    eval { AppConfig::get('invalid') };
    like($@, qr/Cle 'invalid' non trouvee/, 'Erreur cle invalide');
};

# Nettoyage
cleanup_test_env();

done_testing();

