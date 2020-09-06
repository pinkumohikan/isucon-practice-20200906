.PHONY: gogo

gogo: stop-services build truncate-logs start-services bench

build:
	make -C webapp/go/ isucari

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop isucari.golang
	sudo systemctl stop mysql

start-services:
	sudo systemctl start mysql
	sudo systemctl start isucari.golang
	sudo systemctl start nginx

overwrite-server-conf:
	sudo cp -f /home/isucon/isucari/servers/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.confreload-server-conf:

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log

kataribe:
	sudo cat /var/log/nginx/access.log | ../kataribe -f "../kataribe.toml"

bench:
	ssh isucon@18.183.88.60 \
		"cd ~/isucari && ./bin/benchmarker -target-url=http://172.31.12.14:80 --payment-url=http://172.31.0.9:5555 --shipment-url=http://172.31.0.9:7000"

init:
	curl -XPOST http://127.0.0.1:8000/initialize \
		-H 'Content-Type: application/json' \
		-d @initialize.json
