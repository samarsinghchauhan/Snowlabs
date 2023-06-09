{% macro sap_translate_cols(from, relation_alias=False, except=[], prefix='', suffix='') -%}
    {%- do dbt_utils._is_relation(from, 'star') -%}
    {%- do dbt_utils._is_ephemeral(from, 'star') -%}

    {#-- Prevent querying of db in parsing mode. This works because this macro does not create any new refs. #}
    {%- if not execute -%}
        {{ return('') }}
    {% endif %}

    {%- set include_cols = [] %}
    {%- set cols = adapter.get_columns_in_relation(from) -%}
    {%- set except = except | map("lower") | list %}
    {%- for col in cols -%}

        {%- if col.column|lower not in except -%}
            {% do include_cols.append(col.column) %}

        {%- endif %}
    {%- endfor %}

    {%- for col in include_cols %}
        {%- set alias = sap_lookup_table()[col] %}
        {%- if relation_alias %}{{ relation_alias }}.{% else %}{%- endif -%}{{ adapter.quote(col)|trim }}{% if alias %} as {{ adapter.quote(prefix ~ alias ~ suffix)|trim }}{%- endif -%}
        {%- if not loop.last %},{{ '\n  ' }}{% endif %}
    {%- endfor -%}
{%- endmacro %}
