# TODO

## Bugs à corriger

- [ ] Revoir la gestion des signaux SIGINT et SIGNTERM

## À améliorer

- [ ] Vérifier la connexion au serveur avant chaque envoi client
- [ ] Mettre le lien vers config/config.json dans variable de config (voir Timestamp::OptionsHandler)
- [ ] Traduire Perldoc et commentaires en anglis
- [ ] Remplacer IO::Socket::INET par IO::Socket::SSL
- [ ] Meilleure estimation de l'offset (moyenne sur plusieurs requêtes)
- [ ] Gestion dynamique des fichiers de log (par date/ID)
- [ ] Remplacer les `die` par des `eval`
- [ ] Arrêt propre des clients/serveur sans CTRL+C
- [ ] Augmenter la couverture de test
