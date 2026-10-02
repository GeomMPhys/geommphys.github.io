---
title: Research Lines
section: Research
description: An experimental, interactive view of how our research lines connect geometry, mathematics, and physics.
permalink: /research-lines-experiment/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.former_members | concat: site.data.people.visitors %}
{% assign group_members = site.data.people.researchers_madrid | concat: site.data.people.students_madrid %}
{% assign external_collaborators = site.data.people.international_collaborators %}
{% assign geometry_group = group_members | where_exp: "person", "person.photo contains 'geom_icon.png'" %}
{% assign geometry_collaborators = external_collaborators | where_exp: "person", "person.photo contains 'geom_icon.png'" %}
{% assign mathematics_group = group_members | where_exp: "person", "person.photo contains 'math_icon.png'" %}
{% assign mathematics_collaborators = external_collaborators | where_exp: "person", "person.photo contains 'math_icon.png'" %}
{% assign physics_group = group_members | where_exp: "person", "person.photo contains 'physics_icon.png'" %}
{% assign physics_collaborators = external_collaborators | where_exp: "person", "person.photo contains 'physics_icon.png'" %}
{% assign initial_line = site.data.research_lines.lines | first %}
{% assign initial_placement = initial_line.placement %}

<section class="research-map" aria-label="Interactive map of research disciplines and lines">
  <div class="research-map__visual">
    <div class="research-map__diagram">
    <svg class="research-map__bubbles" viewBox="250 70 1000 900" role="img" aria-labelledby="research-map-title research-map-description">
      <title id="research-map-title">Three overlapping research disciplines</title>
      <desc id="research-map-description">Geometry, Mathematics, and Physics overlap. Select a research line marker to see its description and researchers.</desc>
      <defs>
        <radialGradient id="geometry-field-fade" gradientUnits="userSpaceOnUse" cx="580" cy="530" r="405">
          <stop offset="64%" stop-color="#46698f" stop-opacity="0" />
          <stop offset="74%" stop-color="#46698f" stop-opacity="0.01" />
          <stop offset="86%" stop-color="#46698f" stop-opacity="0.065" />
          <stop offset="95%" stop-color="#46698f" stop-opacity="0.025" />
          <stop offset="100%" stop-color="#46698f" stop-opacity="0" />
        </radialGradient>
        <radialGradient id="math-field-fade" gradientUnits="userSpaceOnUse" cx="840" cy="380" r="405">
          <stop offset="64%" stop-color="#8263a0" stop-opacity="0" />
          <stop offset="74%" stop-color="#8263a0" stop-opacity="0.01" />
          <stop offset="86%" stop-color="#8263a0" stop-opacity="0.065" />
          <stop offset="95%" stop-color="#8263a0" stop-opacity="0.025" />
          <stop offset="100%" stop-color="#8263a0" stop-opacity="0" />
        </radialGradient>
        <radialGradient id="physics-field-fade" gradientUnits="userSpaceOnUse" cx="840" cy="680" r="405">
          <stop offset="64%" stop-color="#b96528" stop-opacity="0" />
          <stop offset="74%" stop-color="#b96528" stop-opacity="0.01" />
          <stop offset="86%" stop-color="#b96528" stop-opacity="0.065" />
          <stop offset="95%" stop-color="#b96528" stop-opacity="0.025" />
          <stop offset="100%" stop-color="#b96528" stop-opacity="0" />
        </radialGradient>
      </defs>
      <circle cx="580" cy="530" r="405" fill="url(#geometry-field-fade)" aria-hidden="true" />
      <circle cx="840" cy="380" r="405" fill="url(#math-field-fade)" aria-hidden="true" />
      <circle cx="840" cy="680" r="405" fill="url(#physics-field-fade)" aria-hidden="true" />
      <circle class="research-map__bubble research-map__bubble--geometry" cx="580" cy="530" r="260" />
      <circle class="research-map__bubble research-map__bubble--math" cx="840" cy="380" r="260" />
      <circle class="research-map__bubble research-map__bubble--physics" cx="840" cy="680" r="260" />
      <g class="research-map__discipline-badge research-map__discipline-badge--geometry">
        <rect x="430" y="610" width="270" height="70" rx="5" />
        <image class="research-map__discipline-icon" href="{{ '/assets/images/people-icons/geom_icon.png' | relative_url }}" x="438" y="613" width="78" height="64" aria-hidden="true" />
        <text class="research-map__discipline" x="593" y="654">Geometry</text>
      </g>
      <g class="research-map__discipline-badge research-map__discipline-badge--math">
        <rect x="700" y="130" width="280" height="70" rx="5" />
        <image class="research-map__discipline-icon" href="{{ '/assets/images/people-icons/math_icon.png' | relative_url }}" x="708" y="133" width="78" height="64" aria-hidden="true" />
        <text class="research-map__discipline" x="860" y="174">Mathematics</text>
      </g>
      <g class="research-map__discipline-badge research-map__discipline-badge--physics">
        <rect x="700" y="860" width="280" height="70" rx="5" />
        <image class="research-map__discipline-icon" href="{{ '/assets/images/people-icons/physics_icon.png' | relative_url }}" x="708" y="863" width="78" height="64" aria-hidden="true" />
        <text class="research-map__discipline" x="860" y="904">Physics</text>
      </g>
    </svg>

      {% for line in site.data.research_lines.lines %}
        {% case line.placement %}
          {% when "geometry" %}{% assign marker_x = "25%" %}{% assign marker_y = "51%" %}
          {% when "math-physics" %}{% assign marker_x = "65%" %}{% assign marker_y = "51%" %}
          {% when "physics-geometry" %}{% assign marker_x = "45%" %}{% assign marker_y = "68%" %}
        {% endcase %}
        <button class="research-map__marker research-map__marker--{{ line.placement }}{% if line.id == initial_line.id %} is-selected{% endif %}"
          type="button" style="--marker-x: {{ marker_x }}; --marker-y: {{ marker_y }}"
          data-line-id="{{ line.id }}" aria-label="{{ line.name }}" aria-pressed="{% if line.id == initial_line.id %}true{% else %}false{% endif %}">
          <span class="research-map__marker-number" aria-hidden="true">{{ forloop.index }}</span>
        </button>
      {% endfor %}

    </div>

    <nav class="research-map__line-list" aria-label="Research lines">
      {% for line in site.data.research_lines.lines %}
        <button class="research-map__line-button{% if line.id == initial_line.id %} is-selected{% endif %}"
          type="button" data-line-id="{{ line.id }}" aria-pressed="{% if line.id == initial_line.id %}true{% else %}false{% endif %}">
          <span class="research-map__line-number research-map__line-number--{{ line.placement }}" aria-hidden="true">{{ forloop.index }}</span>
          <span>{{ line.name }}</span>
        </button>
      {% endfor %}
    </nav>

    <details class="research-map__people">
      <summary>People by discipline</summary>
      <div class="research-map__member-ring" aria-label="Current group members and collaborators by discipline">
        {% include research-map-members.html group=geometry_group collaborators=geometry_collaborators field="geometry" %}
        {% include research-map-members.html group=mathematics_group collaborators=mathematics_collaborators field="math" %}
        {% include research-map-members.html group=physics_group collaborators=physics_collaborators field="physics" %}
      </div>
    </details>
  </div>

  <article class="research-map__detail" aria-live="polite" aria-atomic="true">
    <p class="eyebrow" id="research-map-placement">
      {% case initial_placement %}
        {% when "geometry" %}Geometry
        {% when "math-physics" %}Mathematics · Physics
        {% when "physics-geometry" %}Physics · Geometry
      {% endcase %}
    </p>
    <h2 id="research-map-line-title">{{ initial_line.name }}</h2>
    {% if initial_line.keywords %}<p class="research-map__keywords" id="research-map-keywords">{{ initial_line.keywords | join: " · " }}</p>{% else %}<p class="research-map__keywords" id="research-map-keywords"></p>{% endif %}
    <p id="research-map-description-text">{{ initial_line.description }}</p>
    <div class="research-map__contributors">
      <h3>Researchers</h3>
      <ul id="research-map-people">
        {% for pid in initial_line.people %}
          {% assign person = all_people | where: "id", pid | first %}
          {% if person %}<li><a href="{{ '/people/' | relative_url }}#{{ pid }}">{{ person.name }}</a></li>{% endif %}
        {% endfor %}
      </ul>
    </div>
  </article>
</section>

<script type="application/json" id="research-map-lines">{{ site.data.research_lines.lines | jsonify }}</script>
<script type="application/json" id="research-map-people-data">{{ all_people | jsonify }}</script>
<script src="{{ '/assets/js/research-lines-map.js' | relative_url }}" defer></script>
