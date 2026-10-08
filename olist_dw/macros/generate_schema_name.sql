-- File:        generate_schema_name.sql
-- Description: Use the custom schema name as-is (marts, not staging_marts)
--
-- Created at:  2026-10-08
-- Created by:  claude
-- Updated at:  2026-10-08
-- Updated by:  claude

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
