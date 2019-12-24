FROM python:3-alpine as development

RUN pip install pipenv

ADD ./Pipfile ./Pipfile
ADD ./Pipfile.lock ./Pipfile.lock

RUN pipenv install --deploy --system

ADD ./hostthedocs/ ./hostthedocs/
ADD ./runserver.py ./runserver.py

ENV HTD_HOST "0.0.0.0"
ENV HTD_PORT 5000

EXPOSE 5000

CMD [ "python", "runserver.py" ]

FROM python:3-alpine AS builder

RUN apk add build-base libffi-dev
RUN pip install gevent

FROM development AS production

COPY --from=builder /usr/local/lib/python3.8/site-packages/greenlet.*.so /usr/local/lib/python3.8/site-packages/
COPY --from=builder /usr/local/lib/python3.8/site-packages/greenlet-*.dist-info /usr/local/lib/python3.8/site-packages/
COPY --from=builder /usr/local/lib/python3.8/site-packages/gevent/ /usr/local/lib/python3.8/site-packages/gevent/