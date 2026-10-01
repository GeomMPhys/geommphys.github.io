---
title: Research Lines
section: Research
description: An experimental, interactive view of how our research lines connect geometry, mathematics, and physics.
permalink: /research-lines-experiment/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.former_members | concat: site.data.people.visitors %}
{% assign initial_line = site.data.research_lines.lines | first %}
{% assign initial_placement = initial_line.placement %}

<section class="research-map" aria-label="Interactive map of research disciplines and lines">
  <div class="research-map__diagram">
    <svg class="research-map__bubbles" viewBox="0 0 900 560" role="img" aria-labelledby="research-map-title research-map-description">
      <title id="research-map-title">Three overlapping research disciplines</title>
      <desc id="research-map-description">Geometry, Mathematics, and Physics overlap. Select a research line marker to see its description and researchers.</desc>
      <circle class="research-map__bubble research-map__bubble--geometry" cx="300" cy="300" r="205" />
      <circle class="research-map__bubble research-map__bubble--math" cx="500" cy="220" r="205" />
      <circle class="research-map__bubble research-map__bubble--physics" cx="610" cy="350" r="205" />
      <text class="research-map__discipline research-map__discipline--geometry" x="170" y="385">Geometry</text>
      <text class="research-map__discipline research-map__discipline--math" x="470" y="95">Mathematics</text>
      <text class="research-map__discipline research-map__discipline--physics" x="750" y="330">Physics</text>
    </svg>

    {% for line in site.data.research_lines.lines %}
      {% case line.placement %}
        {% when "geometry" %}{% assign marker_x = "25%" %}{% assign marker_y = "54%" %}
        {% when "math-physics" %}{% assign marker_x = "65%" %}{% assign marker_y = "34%" %}
        {% when "physics-geometry" %}{% assign marker_x = "51%" %}{% assign marker_y = "77%" %}
      {% endcase %}
      <button class="research-map__marker{% if line.id == initial_line.id %} is-selected{% endif %}"
        type="button" style="--marker-x: {{ marker_x }}; --marker-y: {{ marker_y }}"
        data-line-id="{{ line.id }}" aria-pressed="{% if line.id == initial_line.id %}true{% else %}false{% endif %}">
        <span class="research-map__marker-dot" aria-hidden="true"></span>
        <span class="research-map__marker-label">{{ line.name }}</span>
      </button>
    {% endfor %}
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
