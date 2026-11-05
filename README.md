# Poke Atlas

Um catálogo Pokemon simples para consultar informaçõees pelo nome ou número da Pokedex. Cada ficha mostra imagem, tipos, altura, peso e alguns atributos básicos.

## Executar

1. Instale o [Flutter](https://docs.flutter.dev/get-started/install).
2. Na pasta do projeto, execute `flutter pub get`.
3. Execute `flutter run` com um emulador ou dispositivo conectado. Tambem é possi­vel iniciar no navegador com `flutter run -d chrome`.

O app abre com a ficha do Pikachu. Digite outro nome ou número e pressione Enter ou a seta de busca.

## API

O app utiliza a **PokeAPI**, uma API pública que não exige chave:

- Endereço usado: https://pokeapi.co/api/v2/pokemon/{nome-ou-numero}
- Documentação: https://pokeapi.co/docs/v2

O app faz uma requisição HTTP GET, a resposta JSON e apresenta os dados na ficha do Pokemon. A busca é assí­ncrona e a interface informa carregamento e erros de conexão.

## Repositório

https://github.com/AlissonnSilva/AtividadeAPIpokemon



