---
title: Publications
section: Research
description: Publications listed on the public Google Sites page.
permalink: /publications/
---

{% assign publications = site.data.publications.selected %}

{% if publications and publications.size > 0 %}
  {% include publication-list.html publications=publications %}
{% else %}
  <p class="empty">Selected publications will be added here.</p>
{% endif %}
