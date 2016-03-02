## How To

Test Nginx `.conf` file syntax

	docker exec <CONTAINER NAME> nginx -t

should print

```shell
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Restart Nginx after `.conf` file changes

	docker exec <CONTAINER NAME> nginx -s reload

## Tests

Currently there are acceptance tests shipped with this package. The specs 
are run using Ruby and the following Gems:

 * rspec
 * serverspec
 * docker-api

To run tests, you need Ruby and the listed Gems installed. The test can 
be run on the command line:

```shell
$ Print progress bar/dots while running tests
$ rspec --format progress Dockspec.rb
# Short notation
$ rspec -f p Dockspec.rb
# Verbose output (Print spec titles) while running tests
$ rspec --format documentation Dockspec.rb
# Short notation
$ rspec -f d Dockspec.rb
```