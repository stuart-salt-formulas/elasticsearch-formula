include:
  - elasticsearch.pkg

{%- if salt['pillar.get']('elasticsearch:config') %}
elasticsearch_cfg:
  file.serialize:
    - name: /etc/elasticsearch/elasticsearch.yml
    - dataset_pillar: elasticsearch:config
    - formatter: yaml
    - user: root
    - require:
      - sls: elasticsearch.pkg
{%- endif %}

{% set data_dir = salt['pillar.get']('elasticsearch:config:path.data') %}
{% set log_dir = salt['pillar.get']('elasticsearch:config:path.logs') %}

{% for dir in (data_dir, log_dir) %}
{% if dir %}
{{ dir }}:
  file.directory:
    - user: elasticsearch
    - group: elasticsearch
    - mode: 0700
    - makedirs: True
{% endif %}
{% endfor %}


/etc/elasticsearch/jvm.options:
  file.replace:
    - pattern: ^-Xms.*$
    - repl: -Xms{{ salt['pillar.get']('elasticsearch:jvm_heapsize', "2g") }}
    - prepend_if_not_found: true
    - watch_in:
      - service: elasticsearch
