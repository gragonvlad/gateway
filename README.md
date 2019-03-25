# gateway

This repository contains code of gateway service which passes events from Discord shards to the message queue.  

Since our microservice stuff shouldn't be used by regular users and is hard to set up you are very likely not looking for this.

If you wish to have your own instance of Kyoko please check out following repositories:

- [kyoko](https://github.com/KyokoBot/kyoko) - monolithic (single process) version of Kyoko, made for self-hosters in mind.
- [updater](https://github.com/KyokoBot/updater) - "one-click" Kyoko installer and updater, tries to automatically migrate and update stuff.
