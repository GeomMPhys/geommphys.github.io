---
title: People
section: Group
description: Researchers in Madrid, students in Madrid, and international collaborators.
permalink: /people/
---

{% assign groups = "researchers_madrid|Researchers in Madrid,students_madrid|Students in Madrid,international_collaborators|International Collaborators" | split: "," %}

<h2>International network</h2>

<p>Collaborations at {{ site.data.network.locations | size }} institutions worldwide, from the group's base in Madrid.</p>

{% include network-map.html class="network-map--feature" %}

{% for group in groups %}
  {% assign parts = group | split: "|" %}
  {% assign key = parts[0] %}
  {% assign label = parts[1] %}
  {% assign entries = site.data.people[key] %}

<h2>{{ label }}</h2>
{% if entries and entries.size > 0 %}
<div class="people-grid">
{% for person in entries %}
{% include person-card.html person=person %}
{% endfor %}
</div>
{% else %}
<p class="empty">TODO: Add public entries for this section.</p>
{% endif %}
{% endfor %}
