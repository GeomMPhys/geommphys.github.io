---
title: Outreach
section: Engagement
description: Public engagement activities by members of the group.
permalink: /outreach/
---


{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.former_members | concat: site.data.people.visitors %}
{% if site.data.outreach.activities and site.data.outreach.activities.size > 0 %}
{% assign groups = site.data.outreach.activities | group_by_exp: "a", "a.date | append: '' | slice: 0, 4" | sort: "name" | reverse %}
{% for group in groups %}
<h2>{{ group.name }}</h2>
<div class="record-list">
{% for activity in group.items %}{% include outreach-item.html activity=activity people=all_people %}{% endfor %}
</div>
{% endfor %}
{% else %}
<p class="empty">Outreach activities will be listed here.</p>
{% endif %}
