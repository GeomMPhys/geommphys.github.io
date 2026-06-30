---
title: Awards and Honours
section: Research
description: Publicly listed awards, fellowships, and professional recognition received by group members.
permalink: /awards-honours/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.visitors %}

{% if site.data.awards.awards and site.data.awards.awards.size > 0 %}
<div class="publication-list">
  {% assign current_year = "" %}
  {% for award in site.data.awards.awards %}
    {% assign award_year = award.year | append: "" %}
    {% if award_year != current_year %}
      <h2 class="publication-year">{{ award.year }}</h2>
      {% assign current_year = award_year %}
    {% endif %}
    {% assign p = all_people | where: "id", award.person | first %}
    <article class="publication">
      <h3>{% if p %}{{ p.name }}{% else %}{{ award.person }}{% endif %}</h3>
      <p class="meta">{{ award.award }}{% if award.category %} &middot; {{ award.category }}{% endif %}</p>
    </article>
  {% endfor %}
</div>
{% else %}
<p class="empty">Awards and honours will be listed here.</p>
{% endif %}
