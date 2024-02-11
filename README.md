# tortuga

Uma versão em Ruby puro da [rinha do backend 2ª edição](https://github.com/zanfranceschi/rinha-de-backend-2024-q1) 2024/Q1, sem frameworks.

```
                                                                          
  ,d                            ,d                                        
  88                            88                                        
MM88MMM ,adPPYba,  8b,dPPYba, MM88MMM 88       88  ,adPPYb,d8 ,adPPYYba,  
  88   a8"     "8a 88P'   "Y8   88    88       88 a8"    `Y88 ""     `Y8  
  88   8b       d8 88           88    88       88 8b       88 ,adPPPPP88  
  88,  "8a,   ,a8" 88           88,   "8a,   ,a88 "8a,   ,d88 88,    ,88  
  "Y888 `"YbbdP"'  88           "Y888  `"YbbdP'Y8  `"YbbdP"Y8 `"8bbdP"Y8  
                                                   aa,    ,88             
                                                    "Y8bbdP"
```

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
