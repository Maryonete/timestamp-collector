use strict;
use warnings;
use Test::More tests => 3;
use lib './lib';
use Config::Tiny;

# Fonctions utilitaires pour les tests
sub setup_test_env {
    mkdir 'config' unless -d 'config';
    open my $fh, '>', 'config/config.ini' or die "Impossible de créer config.ini: $!";
    print $fh <<'END_CONFIG';
[test]
value=123
name=marion
END_CONFIG
    close $fh;
}

sub cleanup_test_env {
    unlink 'config/config.ini';
    rmdir 'config';
}

# Mise en place de l'environnement de test
setup_test_env();

# Chargement du module
require_ok('AppConfig');

# Test des valeurs valides
subtest 'Lecture des valeurs valides' => sub {
    my $value = eval { AppConfig::get('test', 'value') };
    is($value, '123', 'Lecture de value') or diag($@);

    my $name = eval { AppConfig::get('test', 'name') };
    is($name, 'marion', 'Lecture de name') or diag($@);
};

# Test des erreurs
subtest 'Gestion des erreurs' => sub {
    eval { AppConfig::get('invalid', 'key') };
    like($@, qr/Section 'invalid' non trouvee/, 'Erreur section invalide');

    eval { AppConfig::get('test', 'invalid') };
    like($@, qr/Cle 'invalid' non trouvee/, 'Erreur clé invalide');
};

# Nettoyage
cleanup_test_env();

done_testing();

=head1 NOM

Tests pour AppConfig

=head1 TESTS

=over 4

=item * Vérification du chargement du module C<AppConfig>.

=item * Lecture de valeurs valides depuis le fichier de configuration.

=item * Vérification de la gestion des erreurs pour les sections et clés inexistantes.

=back

=head1 FONCTIONNEMENT

=over 4

=item * C<setup_test_env()> : crée un fichier de configuration test C<config/config.ini>.

=item * C<cleanup_test_env()> : supprime le fichier de test après exécution.

=item * Vérification des valeurs attendues dans la section [test] du fichier.

=item * Test de gestion d'erreurs pour une section ou clé inexistante.

=back

=cut
