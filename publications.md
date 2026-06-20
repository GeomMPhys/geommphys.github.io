---
title: Publications
section: Output
description: Publications listed on the public Google Sites page.
permalink: /publications/
---

{% assign publications = site.data.publications.selected %}

{% if publications and publications.size > 0 %}
  {% include publication-list.html publications=publications %}
{% else %}
  <p class="empty">Selected publications will be added here.</p>
{% endif %}

{% if site.data.publications.profiles %}
  <h2>Bibliography Profiles</h2>
  <p class="links links--large">
    {% for profile in site.data.publications.profiles %}
      <a href="{{ profile.url }}">{{ profile.label }}</a>
    {% endfor %}
  </p>
{% endif %}
