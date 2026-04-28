const sections = document.querySelectorAll('.content section[id]');
const links = document.querySelectorAll('.sidebar a');

function setActiveLink() {
  let current = '';
  sections.forEach(section => {
    const rect = section.getBoundingClientRect();
    if (rect.top <= 140 && rect.bottom >= 140) {
      current = section.id;
    }
  });

  links.forEach(link => {
    const href = link.getAttribute('href').replace('#', '');
    link.classList.toggle('is-active', href === current);
  });
}

document.addEventListener('scroll', setActiveLink);
window.addEventListener('load', setActiveLink);
