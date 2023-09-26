docker run -p 4242:4242 --rm -it $(docker build -q -f ./Dockerfile -t docker-multi-test  --platform linux/arm64 .)
#docker inspect docker-multi-test -f "{{.Os}}/{{.Architecture}}"
#docker run docker-multi-test -p 4242:4242