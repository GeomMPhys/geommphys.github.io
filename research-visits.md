---
title: Research Visits
section: Research
description: Publicly listed research visits hosted by the group.
permalink: /research-visits/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.visitors %}
{% if site.data.research_visits.visits and site.data.research_visits.visits.size > 0 %}
{% assign groups = site.data.research_visits.visits | group_by_exp: "v", "v.arrival | date: '%Y'" | sort: "name" | reverse %}
{% for group in groups %}
<h2>{{ group.name }}</h2>
<div class="record-list">
{% for visit in group.items %}{% include research-visit.html visit=visit people=all_people %}{% endfor %}
</div>
{% endfor %}
{% else %}
<p class="empty">Research visits will be listed here.</p>
{% endif %}
