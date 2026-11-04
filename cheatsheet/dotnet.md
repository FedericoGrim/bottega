# .NET

## Progetto

| Comando | Cosa fa |
| --- | --- |
| `dotnet --version` | versione dell'SDK |
| `dotnet --list-sdks` | SDK installati |
| `dotnet new list` | template disponibili |
| `dotnet new webapi -n MiaApi` | crea una Web API |
| `dotnet new console -n MiaApp` | crea un'app console |
| `dotnet new sln -n MiaSoluzione` | crea una solution |
| `dotnet sln add MiaApi/MiaApi.csproj` | aggiunge un progetto alla solution |
| `dotnet add reference ../Lib/Lib.csproj` | riferimento a un altro progetto |

## Esecuzione e build

| Comando | Cosa fa |
| --- | --- |
| `dotnet run` | compila e avvia |
| `dotnet watch run` | riavvia a ogni modifica |
| `dotnet build` | compila |
| `dotnet clean` | cancella i file compilati |
| `dotnet publish -c Release -o out` | pubblica la versione di produzione |
| `dotnet dev-certs https --trust` | si fida del certificato HTTPS di sviluppo |

## Test e pacchetti

| Comando | Cosa fa |
| --- | --- |
| `dotnet test` | esegue i test |
| `dotnet test --filter "FullyQualifiedName~Nome"` | esegue solo i test che contengono Nome |
| `dotnet add package Nome` | installa un pacchetto NuGet |
| `dotnet remove package Nome` | rimuove un pacchetto |
| `dotnet restore` | scarica i pacchetti |
| `dotnet list package --outdated` | pacchetti da aggiornare |
| `dotnet format` | formatta il codice |

## Entity Framework Core

| Comando | Cosa fa |
| --- | --- |
| `dotnet tool install --global dotnet-ef` | installa lo strumento dotnet-ef |
| `dotnet ef migrations add NomeMigrazione` | crea una migrazione |
| `dotnet ef migrations remove` | annulla l'ultima migrazione non applicata |
| `dotnet ef database update` | applica le migrazioni al database |
| `dotnet ef database update NomeMigrazione` | torna a una migrazione precedente |
| `dotnet ef migrations list` | elenca le migrazioni |
| `dotnet ef dbcontext scaffold "stringa" Npgsql.EntityFrameworkCore.PostgreSQL` | genera le classi da un database esistente |
