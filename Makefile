NAME = jancajthaml/wrk
VERSION = latest

.PHONY: all
all: image

.PHONY: image
image:
	docker build -t $(NAME):stage .
	docker run -it $(NAME):stage -v || :
	docker export $$(docker ps -a | awk '$$2=="$(NAME):stage" { print $$1 }'| head -1) | docker import - $(NAME):stripped
	docker tag $(NAME):stripped $(NAME):$(VERSION)
	docker rmi -f $(NAME):stripped
	docker rmi -f $(NAME):stage

.PHONY: tag
tag: image
	git checkout -B release/$(VERSION)
	git add --all
	git commit -a --allow-empty-message -m '' 2> /dev/null || :
	git rebase --no-ff --autosquash release/$(VERSION)
	git pull origin release/$(VERSION) 2> /dev/null || :
	git push origin release/$(VERSION)
	git checkout -B master

.PHONY: run
run:
	docker run --rm -it --log-driver none \
		-p 8080:8080 \
		-p 443:443 \
		$(NAME):$(VERSION) wrk

.PHONY: upload
upload:
	docker login -u jancajthaml https://index.docker.io/v1/
	docker push $(NAME)

.PHONY: publish
publish: image tag upload
