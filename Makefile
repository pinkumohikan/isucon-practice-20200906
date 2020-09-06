.PHONY: gogo

gogo: stop-services stop-services-app2 stop-services-app3 build sync-build-file-app2 sync-build-file-app3 truncate-logs start-services-app2 start-services-app3 start-services bench

build:
	make -C webapp/go/ isucari

sync-build-file-app2:
	scp -C webapp/go/isucari isucon@18.179.19.193:~/isucari/webapp/go

sync-build-file-app3:
	scp -C webapp/go/isucari isucon@103.4.14.236:~/isucari/webapp/go

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop isucari.golang
	sudo systemctl stop mysql

stop-services-app2:
	ssh isucon@18.179.19.193 sudo systemctl stop isucari.golang

stop-services-app3:
	ssh isucon@103.4.14.236 sudo systemctl stop isucari.golang

start-services:
	sudo systemctl start mysql
	sudo systemctl start isucari.golang
	sudo systemctl start nginx

start-services-app2:
	ssh isucon@18.179.19.193 sudo systemctl start isucari.golang

start-services-app3:
	ssh isucon@103.4.14.236 sudo systemctl start isucari.golang

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log

kataribe:
	sudo cat /var/log/nginx/access.log | ../kataribe -f "../kataribe.toml"

overwrite-server-conf:	start-services-app2:
	sudo cp -f /home/isucon/isucari/servers/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

bench:
	ssh isucon@18.183.88.60 \
		"cd ~/isucari && ./bin/benchmarker -target-url=http://172.31.12.14:80 --payment-url=http://172.31.0.9:5555 --shipment-url=http://172.31.0.9:7000"

init:
	curl -XPOST http://127.0.0.1:8000/initialize \
		-H 'Content-Type: application/json' \
		-d @initialize.json
