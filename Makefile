.PHONY: serve build deploy

serve:
	mkdocs serve

build:
	mkdocs build

deploy:
	netlify deploy --dir=site --prod
