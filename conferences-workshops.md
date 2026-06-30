---
title: Conferences and Workshops
section: Research
description: Conferences, workshops, and schools organized with members of the group.
permalink: /conferences-workshops/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.visitors %}

{% if site.data.workshops.events and site.data.workshops.events.size > 0 %}
<div class="publication-list">
  {% assign current_year = "" %}
  {% for event in site.data.workshops.events %}
    {% assign event_year = event.start | date: "%Y" %}
    {% if event_year != current_year %}
      <h2 class="publication-year">{{ event_year }}</h2>
      {% assign current_year = event_year %}
    {% endif %}
    {% include workshop.html event=event people=all_people %}
  {% endfor %}
</div>
{% else %}
<p class="empty">Conferences and workshops will be listed here.</p>
{% endif %}
