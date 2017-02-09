include:
  - elasticsearch.service

{% if grains.get('os_family') == 'Debian' %}
{% set sysconfig_file = '/etc/default/elasticsearch' %}
{% else %}
{% set sysconfig_file = '/etc/sysconfig/elasticsearch' %}
{% endif %}

{% set sysconfig_data = salt['pillar.get']('elasticsearch:sysconfig') %}
{% if sysconfig_data %}
{{ sysconfig_file }}:
  file.managed:
    - source: salt://elasticsearch/files/sysconfig
    - owner: elasticsearch
    - group: elasticsearch
    - mode: 0600
    - template: jinja
    - watch_in:
      - service: elasticsearch_service
    - context:
        sysconfig: {{ salt['pillar.get']('elasticsearch:sysconfig') }}
{% endif %}


Config java heap min:
  file.replace:
    - name: /etc/elasticsearch/jvm.options
    - pattern: ^-Xms.*$
    - repl: -Xms{{ salt['pillar.get']('elasticsearch:jvm_heapsize', "2g") }}
    - prepend_if_not_found: true
    - watch_in:
      - service: elasticsearch

Config java heap max:
  file.replace:
    - name: /etc/elasticsearch/jvm.options
    - pattern: ^-Xmx.*$
    - repl: -Xmx{{ salt['pillar.get']('elasticsearch:jvm_heapsize', "2g") }}
    - prepend_if_not_found: true
    - watch_in:
      - service: elasticsearch
