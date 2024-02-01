## [Build an image from a Dockerfile](https://docs.docker.com/engine/reference/commandline/build/)
```sh
docker build -t <image_name>:<tag> .
docker build -t zsh-nvim:latest .
```

## [Create and run a new container from an image](https://docs.docker.com/engine/reference/commandline/run/)
- Use `-h <hostname>` to set hostname
```sh
docker run -dit --hostname <hostname> --name <container_name> <image_name>
docker run -dit --hostname ubuntu-container --name zsh-nvim zsh-nvim
```

## [Execute a command in a running container](https://docs.docker.com/engine/reference/commandline/exec/)
- Specify `-u root` to use root user
```sh
docker exec -it <container_name> zsh
docker exec -it zsh-nvim zsh
```
- To set password for users
	- Use root user and run `passwd`
