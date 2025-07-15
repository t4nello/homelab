FROM fluent/fluentd:v1.16-1

USER root

# Instalacja pluginów
RUN gem install fluent-plugin-elasticsearch fluent-plugin-filter-docker_metadata
USER fluent