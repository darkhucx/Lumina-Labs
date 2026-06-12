# Lumina Labs — Docker jekyll (system ruby is too old; no local ruby install).
# Runs the official jekyll/jekyll image via colima's docker.

IMAGE := jekyll/jekyll:4
PORT  := 4000

.PHONY: build serve shell clean

build:        ## one-off build into _site/
	docker run --rm -v "$(PWD)":/srv/jekyll -w /srv/jekyll $(IMAGE) \
		sh -c "bundle install --quiet && jekyll build"

serve:        ## live preview at http://localhost:$(PORT)
	docker run --rm -it -p $(PORT):4000 -v "$(PWD)":/srv/jekyll -w /srv/jekyll $(IMAGE) \
		sh -c "bundle install --quiet && jekyll serve --host 0.0.0.0 --watch --force_polling"

clean:        ## remove build output
	rm -rf _site .jekyll-cache .jekyll-metadata
