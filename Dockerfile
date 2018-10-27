FROM node:10.12.0-alpine AS fetch

ENV NODECG_TAG v1.1.3

ADD https://github.com/nodecg/nodecg/archive/${NODECG_TAG}.tar.gz ./nodecg.tar.gz

RUN mkdir -p extracted \
	&& tar xzf ./nodecg.tar.gz -C ./extracted \
	&& mv ./extracted/* /nodecg

FROM node:10.12.0-alpine AS image

RUN apk --no-cache add git

WORKDIR /nodecg

COPY --from=fetch /nodecg/lib /nodecg/lib
COPY --from=fetch /nodecg/src /nodecg/src
COPY --from=fetch /nodecg/schemas /nodecg/schemas
COPY --from=fetch /nodecg/build /nodecg/build
COPY --from=fetch /nodecg/bower.json /nodecg/index.js /nodecg/package.json /nodecg/

RUN npm install --global bower \
	&& npm install --production \
	&& bower install --production --allow-root

CMD [ "node", "/nodecg/index.js" ]
