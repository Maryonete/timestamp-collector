package Timestamp::Util;

use strict;
use warnings;
use Exporter 'import';
use Scalar::Util qw(looks_like_number);

our @EXPORT_OK = qw(validate_timestamp validate_port validate_clients_number validate_host validate_interval);

sub validate_timestamp {
    my ($timestamp) = @_;
    return $timestamp =~ /^\d+\.\d{3}$/;
}

sub validate_port {
    my ($port) = @_;
    
    # Vérifie que le port est un nombre
    return 0 unless defined $port && looks_like_number($port);
    
    # Vérifie que le port est dans la plage valide
    return ($port > 0 && $port < 65536);
}

sub validate_clients_number {
    my ($nb_clients) = @_;
    
    # Vérifie que le nombre de clients est un nombre positif
    return 0 unless defined $nb_clients && looks_like_number($nb_clients);
    
    return ($nb_clients > 0 && $nb_clients <= 1000);  # Limite raisonnable
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
    return 0 unless defined $interval && looks_like_number($interval);
    
    return ($interval > 0 && $interval <= 3600);  # Max 1 heure
}
1;