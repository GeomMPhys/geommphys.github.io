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
<p class="empty">No one is listed in this group yet.</p>
{% endif %}
{% endfor %}

{%- comment -%}
  Every collaborator in plain text. The map's labels are hover-only, which fails
  on touch and in a screenshot, so this list is the accessible copy of the same
  data — read from network.yml, with member ids resolved through people.yml.
  A name given inline in network.yml (someone with no person record) renders as
  plain text rather than a link.
{%- endcomment -%}
{%- assign all_people = site.data.people.researchers_madrid
      | concat: site.data.people.students_madrid
      | concat: site.data.people.international_collaborators
      | concat: site.data.people.visitors -%}
<h2>Elsewhere</h2>

<div class="place-list">
{% for location in site.data.network.locations %}
  <article class="place">
    <h3>{{ location.subtitle }}</h3>
    <p class="place__who"><span class="place__where">{{ location.label }}</span> &mdash;
      {% for m in location.members -%}
        {%- if m.name -%}{{ m.name }}
        {%- else -%}{% include person-name.html id=m people=all_people link=true %}{%- endif -%}
        {%- unless forloop.last %}, {% endunless -%}
      {%- endfor %}
    </p>
  </article>
{% endfor %}
</div>
