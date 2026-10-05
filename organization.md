---
title: Organization
section: Group
description: Roles and responsibilities within the GeomMPhys research group.
permalink: /organization/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.former_members | concat: site.data.people.visitors %}

<div class="record-list">
{% for item in site.data.organization.roles %}
  {% include organization-role.html item=item people=all_people %}
{% endfor %}
</div>
