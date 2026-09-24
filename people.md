---
title: People and collaborators
section: Group
description: Researchers and students in Madrid, and collaborators at institutions abroad.
lead_include: people-standfirst.html
permalink: /people/
---

{%- assign all_people = site.data.people.researchers_madrid
      | concat: site.data.people.students_madrid
      | concat: site.data.people.international_collaborators
      | concat: site.data.people.visitors -%}
{%- assign lines = site.data.research_lines.lines -%}

{% include discipline-tally.html %}

<h2>In Madrid</h2>

{%- comment -%}
  Every name in plain text, with the research lines each person is on in the
  right margin. No photographs and no cards: most of the "photos" are the four
  discipline icons, which the tally above now carries once instead of twenty
  times, and the name is what a reader came for. Each name goes to that
  person's own page.
{%- endcomment -%}
{%- assign madrid = site.data.people.researchers_madrid | concat: site.data.people.students_madrid -%}
{% if madrid.size > 0 %}
<ul class="name-list">
{%- for person in madrid -%}
  {%- assign marks = "" -%}
  {%- for line in lines -%}
    {%- if line.people contains person.id -%}
      {%- assign marks = marks | append: ", §" | append: forloop.index -%}
    {%- endif -%}
  {%- endfor -%}
  <li class="name-list__row">
    <a href="{{ '/people/' | append: person.id | append: '/' | relative_url }}">{{ person.name }}</a>
    {%- if marks != "" %}<span class="name-list__marks" aria-hidden="true">{{ marks | remove_first: ", " }}</span>{% endif -%}
  </li>
{%- endfor -%}
</ul>
{% else %}
<p class="empty">No one is listed in this group yet.</p>
{% endif %}

<h2>Elsewhere</h2>

{%- comment -%}
  Every collaborator in plain text. The map on the home page labels only
  Madrid and opens the rest on hover, which fails on touch and in a
  screenshot, so this list is the readable copy of the same data — read from
  network.yml, with member ids resolved through people.yml. A name given
  inline there (someone with no person record) renders as plain text.
{%- endcomment -%}
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
