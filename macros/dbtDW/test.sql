{% macro test(items, delimiter='||') %}
  {{ items | join(delimiter) }}{{ delimiter }}
{% endmacro %}

