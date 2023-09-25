docker build -f ./docker-multi-test/Dockerfile -t docker-multi-test  --platform linux/arm .
docker inspect docker-multi-test -f "{{.Os}}/{{.Architecture}}"
# docker run docker-multi-test -d -p 4242:80