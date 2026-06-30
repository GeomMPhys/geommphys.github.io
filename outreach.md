---
title: Outreach
section: Engagement
description: Public engagement activities by members of the group.
permalink: /outreach/
---

We are available for outreach events. Estamos disponibles para eventos de divulgación.

Contact us at [geom.mphys@gmail.com](mailto:geom.mphys@gmail.com).

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.visitors %}

{% if site.data.outreach.activities and site.data.outreach.activities.size > 0 %}
<div class="publication-list">
  {% assign current_year = "" %}
  {% for activity in site.data.outreach.activities %}
    {% assign activity_year = activity.year | append: "" %}
    {% if activity_year != current_year %}
      <h2 class="publication-year">{{ activity.year }}</h2>
      {% assign current_year = activity_year %}
    {% endif %}
    {% include outreach-item.html activity=activity people=all_people %}
  {% endfor %}
</div>
{% else %}
<p class="empty">Outreach activities will be listed here.</p>
{% endif %}
