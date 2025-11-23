/* assets/js/main.js
   Replace the API_BASE placeholder with your API Gateway url (no trailing slash)
   Example API_BASE = "https://abc123.execute-api.eu-west-1.amazonaws.com/prod"
*/
const API_BASE = "https://REPLACE_WITH_YOUR_API.execute-api.YOUR-REGION.amazonaws.com/prod";

document.addEventListener('DOMContentLoaded', () => {
  // See More toggle
  const seeMoreToggle = document.getElementById('seeMoreToggle');
  const seeMoreSection = document.getElementById('seeMoreSection');
  seeMoreToggle.addEventListener('click', (e) => {
    e.preventDefault();
    if (seeMoreSection.style.display === 'block') {
      seeMoreSection.style.display = 'none';
      seeMoreToggle.textContent = 'See More';
    } else {
      seeMoreSection.style.display = 'block';
      seeMoreToggle.textContent = 'See Less';
      window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
    }
  });

  // Fetch dynamic content
  fetchEvents();
  fetchTestimonials();
});

// helpers
function showFlash(message, category = 'info') {
  const flashContainer = document.getElementById('flash-messages');
  flashContainer.style.display = 'block';
  flashContainer.innerHTML = `<div class="flash ${category}">${message}</div>`;
  setTimeout(() => { flashContainer.style.display = 'none'; }, 8000);
}

async function fetchEvents() {
  const eventsList = document.getElementById('eventsList');
  eventsList.innerHTML = '<p>Loading events…</p>';
  try {
    const res = await fetch(`${API_BASE}/events`);
    if (!res.ok) throw new Error(`Server returned ${res.status}`);
    const data = await res.json();
    renderEvents(data.events || []);
  } catch (err) {
    console.error('Failed to fetch events', err);
    eventsList.innerHTML = '<p>Could not load events.</p>';
    showFlash('Could not load events. Check backend or API URL.', 'error');
  }
}

async function fetchTestimonials() {
  const testimonialsList = document.getElementById('testimonialsList');
  testimonialsList.innerHTML = '<p>Loading testimonials…</p>';
  try {
    const res = await fetch(`${API_BASE}/testimonials`);
    if (!res.ok) throw new Error(`Server returned ${res.status}`);
    const data = await res.json();
    renderTestimonials(data.testimonials || []);
  } catch (err) {
    console.error('Failed to fetch testimonials', err);
    testimonialsList.innerHTML = '<p>Could not load testimonials.</p>';
    showFlash('Could not load testimonials. Check backend or API URL.', 'error');
  }
}

function renderEvents(events) {
  const container = document.getElementById('eventsList');
  if (!events.length) {
    container.innerHTML = '<p>No upcoming events.</p>';
    return;
  }
  container.innerHTML = '';
  events.forEach(ev => {
    const div = document.createElement('div');
    div.className = 'event';
    const imgPath = ev.image ? ev.image : '/assets/images/party1.jpg';
    div.innerHTML = `
      <img src="${escapeHtml(imgPath)}" alt="${escapeHtml(ev.name || 'Event')}" />
      <p class="event-title">${escapeHtml(ev.name || 'Untitled')}</p>
      <p class="event-date">${escapeHtml(ev.date || '')}</p>
      <p class="event-location">${escapeHtml(ev.location || '')}</p>
    `;
    container.appendChild(div);
  });
}

function renderTestimonials(items) {
  const container = document.getElementById('testimonialsList');
  if (!items.length) {
    container.innerHTML = '<p>No testimonials available at the moment.</p>';
    return;
  }
  container.innerHTML = '';
  items.forEach(t => {
    const div = document.createElement('div');
    div.className = 'testimonial';
    div.innerHTML = `<p>"${escapeHtml(t.content || '')}" - ${escapeHtml(t.user_name || 'Anonymous')}</p>`;
    container.appendChild(div);
  });
}

// basic sanitizer for insertion into attribute/text
function escapeHtml(str = '') {
  return String(str).replace(/[&<>"']/g, (m) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[m]);
}