---
title: Research Lines
section: Research
description: An experimental, interactive view of the group's research lines across geometry, mathematics, and physics.
permalink: /research-lines-experiment/
---

{% assign current_members = site.data.people.researchers_madrid | concat: site.data.people.students_madrid %}
{% assign researcher_ids = site.data.people.researchers_madrid | map: "id" %}
{% assign phd_student_ids = site.data.people.students_madrid | map: "id" %}
{% assign geometry_ids = "manuel-de-leon,jordi-gaset-rifa,manuel-lainz,ruben-izquierdo-lopez,matteo-dellacqua,oscar-carballal,paula-alba-san-miguel" | split: "," %}
{% assign physics_ids = "saskia-demulder,veronica-errasti-diez,david-trillo,victor-jimenez,marco-maceda" | split: "," %}
{% assign mathematics_ids = "alberto-ruiz-de-alarcon,victor-jimenez" | split: "," %}
{% assign initial_line = site.data.research_lines.lines | first %}
{% assign initial_researcher_ids = "" | split: "," %}
{% assign initial_phd_student_ids = "" | split: "," %}
{% for pid in initial_line.people %}
  {% if researcher_ids contains pid %}{% assign initial_researcher_ids = initial_researcher_ids | push: pid %}{% endif %}
  {% if phd_student_ids contains pid %}{% assign initial_phd_student_ids = initial_phd_student_ids | push: pid %}{% endif %}
{% endfor %}

<section class="research-lines-experiment" aria-label="Interactive map of research lines">
  <div class="research-lines-experiment__workspace">
    <div class="research-lines-experiment__diagram" aria-label="Research disciplines and group members">
      <svg class="research-lines-experiment__grid" viewBox="0 0 1000 850" preserveAspectRatio="none" aria-hidden="true">
        <defs>
          <pattern id="research-lines-dot-grid" width="125" height="141.67" patternUnits="userSpaceOnUse">
            <circle cx="62.5" cy="70.835" r="2.1" />
          </pattern>
          <mask id="research-lines-grid-mask" maskUnits="userSpaceOnUse" x="0" y="0" width="1000" height="850">
            <rect width="1000" height="850" fill="black" />
            <rect x="10" y="25.5" width="640" height="518.5" rx="17" fill="white" />
            <rect x="380" y="170" width="610" height="493" rx="17" fill="white" />
            <rect x="230" y="408" width="600" height="442" rx="17" fill="white" />
          </mask>
        </defs>
        <rect width="1000" height="850" fill="url(#research-lines-dot-grid)" mask="url(#research-lines-grid-mask)" />
      </svg>
      <div class="research-lines-experiment__field research-lines-experiment__field--geometry" aria-label="Geometry">
        <h2>Geometry</h2>
        <ul>
          {% for id in geometry_ids %}
            {% assign person = current_members | where: "id", id | first %}
            {% if person %}<li><a href="{{ '/people/' | relative_url }}#{{ id }}">{{ person.name }}</a></li>{% endif %}
          {% endfor %}
        </ul>
      </div>
      <div class="research-lines-experiment__field research-lines-experiment__field--physics" aria-label="Physics">
        <h2>Physics</h2>
        <ul>
          {% for id in physics_ids %}
            {% assign person = current_members | where: "id", id | first %}
            {% if person %}<li><a href="{{ '/people/' | relative_url }}#{{ id }}">{{ person.name }}</a></li>{% endif %}
          {% endfor %}
        </ul>
      </div>
      <div class="research-lines-experiment__field research-lines-experiment__field--mathematics" aria-label="Mathematics">
        <h2>Mathematics</h2>
        <ul>
          {% for id in mathematics_ids %}
            {% assign person = current_members | where: "id", id | first %}
            {% if person %}<li><a href="{{ '/people/' | relative_url }}#{{ id }}">{{ person.name }}</a></li>{% endif %}
          {% endfor %}
        </ul>
      </div>

      <div class="research-lines-experiment__points" aria-label="Select a research line">
        {% for line in site.data.research_lines.lines %}
          {% case line.id %}
            {% when "Multisymplectic-field-theory" %}{% assign point_x = "54.5%" %}{% assign point_y = "40%" %}
            {% when "Higher-order-systems" %}{% assign point_x = "48.5%" %}{% assign point_y = "40%" %}
            {% when "beyond-integrability" %}{% assign point_x = "44%" %}{% assign point_y = "56%" %}
            {% when "quantum-systems" %}{% assign point_x = "66.5%" %}{% assign point_y = "68.5%" %}
          {% endcase %}
          <button class="research-lines-experiment__point{% if line.id == initial_line.id %} is-selected{% endif %} research-lines-experiment__point--{{ line.placement }}"
            type="button" style="--point-x: {{ point_x }}; --point-y: {{ point_y }}"
            data-line-id="{{ line.id }}" aria-label="Show {{ line.name }}" aria-pressed="{% if line.id == initial_line.id %}true{% else %}false{% endif %}">
            <span class="research-lines-experiment__point-core" aria-hidden="true"></span>
          </button>
        {% endfor %}
      </div>
    </div>

    <svg class="research-lines-experiment__connector" aria-hidden="true" preserveAspectRatio="none">
      <path></path>
    </svg>

    <article class="research-lines-experiment__detail" aria-live="polite" aria-atomic="true">
      <header>
        <p id="research-lines-experiment-placement">
          {% case initial_line.placement %}
            {% when "geometry-physics" %}Geometry · Physics
            {% when "geometry-math" %}Geometry · Mathematics
            {% when "math-physics" %}Mathematics · Physics
          {% endcase %}
        </p>
        <h2 id="research-lines-experiment-title">{{ initial_line.name }}</h2>
      </header>
      <div class="research-lines-experiment__detail-body">
        <p class="research-lines-experiment__keywords" id="research-lines-experiment-keywords">{{ initial_line.keywords | join: " · " }}</p>
        <p id="research-lines-experiment-description">{{ initial_line.description }}</p>
        <div class="research-lines-experiment__members">
          <h3>Group members</h3>
          <div id="research-lines-experiment-members" class="research-lines-experiment__member-groups">
            {% if initial_researcher_ids.size > 0 %}
              <section class="research-lines-experiment__member-group">
                <h4>Researchers</h4>
                <ul>
                  {% for pid in initial_researcher_ids %}
                    {% assign person = current_members | where: "id", pid | first %}
                    {% if person %}<li><a href="{{ '/people/' | relative_url }}#{{ pid }}">{{ person.name }}</a></li>{% endif %}
                  {% endfor %}
                </ul>
              </section>
            {% endif %}
            {% if initial_phd_student_ids.size > 0 %}
              <section class="research-lines-experiment__member-group">
                <h4>PhD students</h4>
                <ul>
                  {% for pid in initial_phd_student_ids %}
                    {% assign person = current_members | where: "id", pid | first %}
                    {% if person %}<li><a href="{{ '/people/' | relative_url }}#{{ pid }}">{{ person.name }}</a></li>{% endif %}
                  {% endfor %}
                </ul>
              </section>
            {% endif %}
          </div>
        </div>
      </div>
    </article>
  </div>
</section>

<script type="application/json" id="research-lines-experiment-data">{{ site.data.research_lines.lines | jsonify }}</script>
<script type="application/json" id="research-lines-experiment-people">{"researchers":{{ site.data.people.researchers_madrid | jsonify }},"students":{{ site.data.people.students_madrid | jsonify }}}</script>
<script src="{{ '/assets/js/research-lines-experiment.js' | relative_url }}" defer></script>
