# Collecteur de Timestamps

## Présentation

Ce projet implémente une communication client-serveur en Perl permettant la collecte et la synchronisation de timestamps entre plusieurs clients et un serveur central.

## Fonctionnalités Principales

- Serveur TCP recevant des timestamps de multiples clients
- Clients envoyant des timestamps à intervalles réguliers
- Stockage des timestamps sans doublons
- Gestion de la synchronisation temporelle entre clients et serveur

## Prérequis

- Perl 5.20+
- Modules Perl requis :
  - `IO::Socket::INET` : Communication réseau
  - `Time::HiRes` : Gestion précise du temps
  - `Test::More` : Tests unitaires
  - `Test::Exception` : Tests des exceptions
  - `Devel::Cover` : Couverture de code

### Installation des Dépendances

Les modules Perl nécessaires peuvent être installés avec les commandes suivantes :

```bash
cpan IO::Socket::INET Time::HiRes Test::More Test::Exception Devel::Cover
```

## Utilisation

### Options Communes

Pour `client.pl`, `server.pl`, et `launcher.pl`, les options suivantes sont disponibles :

- `--port` : Port de communication (défaut : 7777)
- `--host` : Adresse IP du serveur (défaut : localhost)
- `--interval` : Intervalle entre les envois (défaut : 10ms pour le client)

### Démarrage Manuel

1. **Démarrer le serveur** :

```bash
perl bin/server.pl
# ou avec une option personnalisée
perl bin/server.pl --port=8888
```

2. **Démarrer un client** :

```bash
perl bin/client.pl
# ou avec des options personnalisées
perl bin/client.pl --host=127.0.0.1 --port=8888 --interval=20
```

### Lancement Automatisé

Le script `launcher.pl` permet de démarrer simultanément un serveur et plusieurs clients :

```bash
perl bin/launcher.pl --nb_clients=5
# ou avec des options personnalisées
perl bin/launcher.pl --nb_clients=5 --port=8888 --interval=15
```

## Configuration

Le fichier `config/config.ini` permet de personnaliser :

- Les paramètres par défaut du serveur et des clients

## Tests

Pour exécuter les tests unitaires :

```bash
prove -l -r t/
```

### Couverture des Tests

Pour analyser la couverture des tests avec **Devel::Cover**, utilisez les commandes suivantes :

```powershell
$env:PERL5OPT = "-MDevel::Cover=-db,t/cover_db"
prove -l -r t/
$env:PERL5OPT = ""
cover -report html t/cover_db
```

Le rapport HTML sera généré et accessible dans `t/cover_db/coverage.html`.

## Développement

- **Langage** : Perl
- **Statut** : Développement en cours
- **Contributions** : Bienvenues !

## Améliorations Futures

- **Meilleure estimation de l'offset** :
  Envoyer plusieurs requêtes par client et calculer une moyenne permettrait d'améliorer la précision des timestamps en réduisant l'impact des latences réseau.

- **Gestion dynamique des fichiers de log** :
  Actuellement, le fichier de log est statique. Générer des fichiers différents selon la date ou l'ID du client/serveur faciliterait l'organisation et l'archivage des données.

- **Gestion des erreurs avec eval** :
  Remplacer les `die` par des `eval` permettrait d'éviter l'arrêt brutal du programme et d'améliorer la gestion des erreurs avec des actions de récupération.

- **Arrêt propre des clients et du serveur** :
  Implémenter une gestion correcte de la fermeture des connexions et de l'arrêt du programme éviterait de devoir utiliser `CTRL+C` et garantirait la libération des ressources.

- **Sécurisation de la connexion** :
  Utiliser IO::Socket::SSL au lieu de IO::Socket::INET

## Lien vers l'énoncé

Vous pouvez consulter l'énoncé du projet [ici](docs/enonce_timestamp_collector.pdf).

## Licence

MIT
