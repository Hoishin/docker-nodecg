FROM node:10-alpine AS fetch

ARG NODECG_TAG

RUN set -u && echo ${NODECG_TAG}
ADD https://github.com/nodecg/nodecg/archive/${NODECG_TAG}.tar.gz ./nodecg.tar.gz

RUN mkdir -p extracted \
	&& tar xzf ./nodecg.tar.gz -C ./extracted \
	&& mv ./extracted/* /nodecg

WORKDIR /nodecg

RUN apk add git \
	&& npm i -g bower \
	&& npm i --production \
	&& bower i --production --allow-root


FROM node:10-alpine AS image

ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini-muslc-amd64 /tini
RUN chmod +x /tini

RUN apk --no-cache add git

WORKDIR /nodecg

COPY --from=fetch /nodecg/build ./build
COPY --from=fetch /nodecg/lib ./lib
COPY --from=fetch /nodecg/schemas ./schemas
COPY --from=fetch /nodecg/src ./src
COPY --from=fetch /nodecg/bower.json /nodecg/index.js /nodecg/package.json ./
COPY --from=fetch /nodecg/node_modules ./node_modules
COPY --from=fetch /nodecg/bower_components ./bower_components

CMD ["/tini", "--", "node", "."]
