---
title: Research Visits
section: Research
description: Publicly listed research visits hosted by the group.
permalink: /research-visits/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.visitors %}

{% if site.data.research_visits.visits and site.data.research_visits.visits.size > 0 %}
<div class="publication-list">
  {% assign current_year = "" %}
  {% for visit in site.data.research_visits.visits %}
    {% assign visit_year = visit.arrival | date: "%Y" %}
    {% if visit_year != current_year %}
      <h2 class="publication-year">{{ visit_year }}</h2>
      {% assign current_year = visit_year %}
    {% endif %}
    {% include research-visit.html visit=visit people=all_people %}
  {% endfor %}
</div>
{% else %}
<p class="empty">Research visits will be listed here.</p>
{% endif %}
