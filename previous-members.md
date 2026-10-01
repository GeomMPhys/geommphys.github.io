---
title: Previous Members
section: Group
description: Former members and their time with the group.
permalink: /previous-members/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.former_members | concat: site.data.people.visitors %}
{% assign groups = site.data.previous_members.members | group_by_exp: "member", "member.end | date: '%Y'" | sort: "name" | reverse %}
{% for group in groups %}
<h2>{{ group.name }}</h2>
<div class="record-list">
{% for member in group.items %}{% include previous-member.html member=member people=all_people %}{% endfor %}
</div>
{% endfor %}
