# tortuga

Uma versão em Ruby puro da [rinha do backend 2ª edição](https://github.com/zanfranceschi/rinha-de-backend-2024-q1) 2024/Q1, sem frameworks.

<img width="780" alt="Screenshot 2024-02-11 at 15 55 22" src="https://github.com/leandronsp/tortuga/assets/385640/c9d9c08d-199b-4fd4-b2bf-7a8f5085e754">

## Requisitos

* [Docker](https://docs.docker.com/get-docker/)
* [Gatling](https://gatling.io/open-source/), a performance testing tool
* Make (optional)

## Stack

* 2 Ruby 3.3 [+YJIT](https://shopify.engineering/ruby-yjit-is-production-ready) apps
* 1 PostgreSQL
* 1 NGINX

## Usage

```bash
$ make help

Usage: make <target>
  help                       Prints available commands
  start.dev                  Start the rinha in Dev
  start.prod                 Start the rinha in Prod
  docker.stats               Show docker stats
  health.check               Check the stack is healthy
  stress.it                  Run stress tests
  docker.build               Build the docker image
  docker.push                Push the docker image
```

## Inicializando a aplicação

```bash
$ docker compose up -d nginx

# Ou então utilizando Make...
$ make start.dev
```

Testando a app:

```bash
$ curl -v http://localhost:9999/clientes/1/extrato

# Ou então utilizando Make...
$ make health.check
```

## Unleash the madness

Colocando Gatling no barulho:

```bash
$ make stress.it 
$ open stress-test/user-files/results/**/index.html
```

----

[ASCII art generator](http://www.network-science.de/ascii/)
