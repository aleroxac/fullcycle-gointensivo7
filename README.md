# fullcycle-gointensivo7
Projeto desenvolvido duranto o evento Go Intensivo da FullCycle.



## Como rodar o projeto: localmente
``` shell
docker-compose -f docker/docker-compose.yaml up -d postgresql migrate
go run cmd/books/main.go
```

## Como rodar o projeto: via docker-compose
``` shell
docker build -t aleroxac/fullcycle-gointensivo7:gobook .
docker run -d --name gobook --port 8080:8080 aleroxac/fullcycle-gointensivo7:gobook
```