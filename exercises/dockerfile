FROM ruby:3.1.7-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libncurses5-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

CMD ["ruby", "main.rb"]