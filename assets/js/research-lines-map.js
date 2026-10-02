(() => {
  const linesNode = document.getElementById("research-map-lines");
  const peopleNode = document.getElementById("research-map-people-data");
  if (!linesNode || !peopleNode) return;

  const lines = JSON.parse(linesNode.textContent);
  const people = JSON.parse(peopleNode.textContent);
  const peopleUrl = "/people/";
  const placementLabels = {
    geometry: "Geometry",
    "math-physics": "Mathematics · Physics",
    "physics-geometry": "Physics · Geometry"
  };
  const title = document.getElementById("research-map-line-title");
  const placement = document.getElementById("research-map-placement");
  const keywords = document.getElementById("research-map-keywords");
  const description = document.getElementById("research-map-description-text");
  const contributors = document.getElementById("research-map-people");
  const markers = [...document.querySelectorAll(".research-map [data-line-id]")];

  function selectLine(id) {
    const line = lines.find((item) => item.id === id);
    if (!line) return;

    title.textContent = line.name;
    placement.textContent = placementLabels[line.placement] || "Research line";
    keywords.textContent = (line.keywords || []).join(" · ");
    description.textContent = line.description;
    contributors.replaceChildren();

    (line.people || []).forEach((personId) => {
      const person = people.find((item) => item.id === personId);
      if (!person) return;
      const listItem = document.createElement("li");
      const link = document.createElement("a");
      link.href = `${peopleUrl}#${encodeURIComponent(personId)}`;
      link.textContent = person.name;
      listItem.append(link);
      contributors.append(listItem);
    });

    markers.forEach((marker) => {
      const selected = marker.dataset.lineId === id;
      marker.classList.toggle("is-selected", selected);
      marker.setAttribute("aria-pressed", String(selected));
    });
  }

  markers.forEach((marker) => {
    marker.addEventListener("click", () => selectLine(marker.dataset.lineId));
  });
})();
