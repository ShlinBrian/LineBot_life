include .env

.PHONY: clean init

init: clean
	pipenv install --dev
	pipenv run pre-commit install

service_up:
	docker-compose up -d postgres

service_down:
	docker-compose down

analysis: bandit

bandit:
	pipenv run bandit api/

reformat: isort black

black:
	pipenv run black api/

isort:
	pipenv run isort .

lint: flake8 pylint

flake8:
	pipenv run flake8 api/ --max-line-length=120

pylint:
	pipenv run pylint --rcfile=setup.cfg api/*

test:
	pipenv run pytest -vv\
	 --cov-report=term-missing\
	 --cov=api/endpoints\
	 --cov=api/common\
	 --cov=api/machine api/tests

ci-bundle: analysis reformat lint test

clean:
	find . -type f -name '*.py[co]' -delete
	find . -type d -name '__pycache__' -delete
	rm -rf dist
	rm -rf build
	rm -rf *.egg-info
	rm -rf .hypothesis
	rm -rf .pytest_cache
	rm -rf .tox
	rm -f report.xml
	rm -f coverage.xml

run-dev:
	cd api/ && pipenv run uvicorn --port $(API_PORT) --host 0.0.0.0 --log-level error app:APP --reload