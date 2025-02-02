package Timestamp::Util;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(validate_timestamp 
                    validate_port 
                    validate_clients_number 
                    validate_host 
                    validate_interval);

sub validate_timestamp {
    my ($timestamp) = @_;
    return $timestamp =~ /^\d+\.\d{3}$/;
}

sub is_number{
    my ($number) = @_;
    return $number =~ /^\d+$/;
}

sub validate_port {
    my ($port) = @_;
    # print "\nvalidate_port [$port]\n";
    # Vérifie que le port est un nombre
    return 0 unless defined $port && is_number($port);
    
    # Vérifie que le port est dans la plage valide
    return ($port > 0 && $port < 65536);
}

sub validate_clients_number {
    my ($nb_clients) = @_;
    
    # Vérifie que le nombre de clients est un nombre positif
    return 0 unless defined $nb_clients && is_number($nb_clients);
    
    return ($nb_clients > 0 && $nb_clients <= 1000);
}

sub validate_host {
    my ($host) = @_;
    
    # Vérifie que l'hôte n'est pas vide
    return 0 unless defined $host && length($host) > 0;
    
    # Validation basique d'un nom d'hôte ou d'une IP
    # Expression régulière pour les noms d'hôte et les adresses IP
    return $host =~ /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$|^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/;
}

sub validate_interval {
    my ($interval) = @_;
    
    # Vérifie que l'intervalle est un nombre positif
    return 0 unless defined $interval && is_number($interval);
    
    return ($interval > 0 && $interval <= 3600);  # Max 1 heure
}
1;

=head1 NAME

Timestamp::Util - Utilitaire de validation pour les timestamps, ports, clients, hôtes et intervalles.

=head1 SYNOPSIS

  use Timestamp::Util qw(validate_timestamp 
                        validate_port 
                        validate_clients_number 
                        validate_host 
                        validate_interval);

  # Exemple d'utilisation :
  if (validate_timestamp($timestamp)) {
      print "Timestamp valide\n";
  }

=head1 FUNCTIONS

=over 4

=item validate_timestamp($timestamp)

Vérifie si le timestamp est valide (format : nombre suivi de 3 décimales).

=item validate_port($port)

Vérifie si le port est un entier entre 1 et 65535.

=item validate_clients_number($nb_clients)

Vérifie si le nombre de clients est entre 1 et 1000.

=item validate_host($host)

Vérifie si l'hôte est un nom d'hôte ou une adresse IP valide.

=item validate_interval($interval)

Vérifie si l'intervalle est un nombre entre 1 et 3600 (secondes).

=back


=cut
