# Collecteur de Timestamps

## Présentation

Un projet de communication client-serveur en Perl permettant la collecte et la synchronisation de timestamps entre plusieurs clients et un serveur central.

## Fonctionnalités Principales

- Serveur TCP recevant des timestamps de multiples clients
- Clients envoyant des timestamps à intervalles réguliers
- Stockage des timestamps sans doublons
- Gestion de la synchronisation temporelle

## Prérequis

- Perl 5.20+
- Modules Perl :
  - `IO::Socket::INET`
  - `Time::HiRes`
  - `Config::Tiny`
  - `Test::More`

### Installation des Dépendances

```bash
cpan install IO::Socket::INET Time::HiRes Config::Tiny Test::More
```

## Utilisation

### Options Communes

Pour `client.pl`, `server.pl`, et `launcher.pl`, les options suivantes sont disponibles :

- `--port` : Port de communication (défaut : 7777)
- `--host` : Adresse IP (défaut : localhost)
- `--interval` : Intervalle entre les envois (défaut : 10ms pour le client)

### Démarrage Manuel

1. Démarrer le serveur :

```bash
perl bin/server.pl
# ou avec des options personnalisées
perl bin/server.pl --port=8888 --host=127.0.0.1
```

2. Démarrer un client :

```bash
perl bin/client.pl
# ou avec des options personnalisées
perl bin/client.pl --port=8888 --interval=20
```

### Lancement Automatisé

Le script `launcher.pl` permet de démarrer simultanément un serveur et plusieurs clients :

```bash
perl bin/launcher.pl --nb_clients=5
# ou avec des options personnalisées
perl bin/launcher.pl --nb_clients=5 --port=8888 --interval=15
```

## Tests

Exécuter les tests :

```bash
prove -l t/
```

## Configuration

Le fichier `config/config.ini` permet de paramétrer :

- Paramètres par défaut du serveur et des clients
- Chemins de fichiers
- Options de logging

## Développement

- Langage : Perl
- Développement en cours
- Contributions bienvenues

## Améliorations Futures

- **Envoi de plusieurs requêtes pour une meilleure estimation de l'offset** :
  Afin d'améliorer la précision des timestamps collectés, il serait intéressant d'envoyer plusieurs requêtes par client et de calculer une moyenne ou une estimation plus robuste des temps de réponse. Cela permettrait de compenser les variations dues aux latences réseau ou à des instabilités temporaires, améliorant ainsi la synchronisation globale.

- **Gestion dynamique des fichiers de log**
  Le nom du fichier de log utilisé pour stocker les timestamps est actuellement statique. Une amélioration serait de permettre une gestion dynamique des fichiers de log, par exemple en générant des fichiers différents en fonction de la date ou d'autres paramètres (comme l'ID du serveur ou du client). Cela faciliterait la gestion et l'archivage des données collectées.

- **Gestion des erreurs avec eval**

Actuellement, le code utilise des die pour signaler des erreurs, ce qui provoque l'arrêt immédiat du programme. Une amélioration future consisterait à encapsuler ces die dans des blocs eval, permettant ainsi de capturer les erreurs sans arrêter brutalement le programme. Cela offrirait une gestion des erreurs plus souple et pourrait inclure des actions de récupération ou des messages d'erreur plus détaillés.

## Lien vers l'énoncé

Vous pouvez consulter l'énoncé du projet [ici](docs/enonce_timestamp_collector.pdf).

## Licence

MIT
