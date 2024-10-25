# google-sheet-apps-script

[![MIT license](https://img.shields.io/github/license/quarties/eu4-grandest-lan-party.svg)](../../LICENSE)

Google Apps Script to automate the setup of a [EU4 Grandest LAN](https://www.paradoxinteractive.com/games/europa-universalis-iv/grandest-lan) party.

#### Features
- handle POST requests
  - authorization based on token provided in the request body
  - find sheet row based PC ID
  - update the row's `MAC` column
  - error handling
- handle GET requests with dummy response

You can find more information about Google Apps Scripts in the [official documentation](https://developers.google.com/apps-script/guides/web).

You can find the example Google Sheet [here](https://docs.google.com/spreadsheets/d/1OJMf61VobK8V_CqIfnPudNxqYjOYZCTCWobqUdf9s7k/edit?usp=sharinggid=821057122#gid=821057122).

TODO: Explain DHCP and TODO sheets

## Usage

1. Open `Extensions` dropdown and select `Apps Script`. This will open a new tab with the script editor.
2. Copy the content of the [`main.gs`](./main.gs) file and paste it into the editor.
3. Click `Deploy` button and select `New deployment`.
4. Set the deployment type to `Web app`.
5. Set `Who has access` to `Anyone`.
6. Click `Deploy` button to confirm the deployment.
7. Copy the `Web app URL` and save it for later use in [`setup-script`](../setup-script/README.md).


## Author's note

This project was created as part of a larger project to automate the setup of the [EU4 Grandest LAN party](https://github.com/quarties/eu4-grandest-lan-party).
Feel free to open an issue if you have any questions.