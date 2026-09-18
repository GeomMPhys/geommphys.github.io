---
title: Publications
section: Research
description: 
permalink: /publications/
---

{% assign publications = site.data.publications.selected %}

{% if publications and publications.size > 0 %}
  {%- assign all_people = site.data.people.researchers_madrid
      | concat: site.data.people.students_madrid
      | concat: site.data.people.international_collaborators
      | concat: site.data.people.visitors -%}
  {% include publication-list.html publications=publications people=all_people %}
{% else %}
  <p class="empty">Selected publications will be added here.</p>
{% endif %}
